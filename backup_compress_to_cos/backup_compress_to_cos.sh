#!/bin/bash
# 이 스크립트는 지정된 백업 디렉토리를 압축하여 COS(Cloud Object Storage)로 업로드하고,
# 업로드 완료 후 로컬 데이터를 삭제합니다.

# 로그 파일 경로 설정 (필요에 따라 경로 수정)
LOG_FILE="/path/to/your/log/backup_script.log"

# 로그 기록 함수: 메시지와 타임스탬프를 함께 출력 및 기록
log() {
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "${TIMESTAMP} $1" | tee -a "$LOG_FILE"
}

# 파일 크기를 사람이 읽기 좋은 형식으로 변환하는 함수
human_readable_size() {
    bytes=$1
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes}B"
    elif [ "$bytes" -lt 1048576 ]; then
        awk "BEGIN {printf \"%.2fKB\", $bytes/1024}"
    elif [ "$bytes" -lt 1073741824 ]; then
        awk "BEGIN {printf \"%.2fMB\", $bytes/1048576}"
    else
        awk "BEGIN {printf \"%.2fGB\", $bytes/1073741824}"
    fi
}

# 원본 디렉토리 및 COS 대상 버킷 설정
SOURCE_DIR="/path/to/your/backup_directory"
TARGET_COS_BUCKET="cos://your_bucket"

# 현재 호스트명과 1일 전 날짜 (YYYYMMDD)
HOST_NAME=$(hostname)
DATE=$(date -d '-1 day' '+%Y%m%d')

# 백업 디렉토리 및 압축 파일 경로 설정
LOCAL_BACKUP_DIR="$SOURCE_DIR/$DATE"
COMPRESSED_FILE="$SOURCE_DIR/${DATE}.tar.gz"

# COS 업로드 대상 경로 설정 (예: cos://your_bucket/hostname/20250310.tar.gz)
REMOTE_TARGET_FILE="$TARGET_COS_BUCKET/$HOST_NAME/${DATE}.tar.gz"

log "==== Backup process started ===="
log "HOST_NAME: $HOST_NAME, DATE: $DATE"
log "LOCAL_BACKUP_DIR: $LOCAL_BACKUP_DIR"
log "COMPRESSED_FILE: $COMPRESSED_FILE"
log "REMOTE_TARGET_FILE: $REMOTE_TARGET_FILE"

# 백업 디렉토리 존재 여부 확인
if [ ! -d "$LOCAL_BACKUP_DIR" ]; then
    log "Error: Local backup directory '$LOCAL_BACKUP_DIR' does not exist."
    exit 1
fi

# 백업 디렉토리 압축 (SOURCE_DIR내의 DATE 디렉토리를 압축)
log "Compressing directory..."
tar -czf "$COMPRESSED_FILE" -C "$SOURCE_DIR" "$DATE"
if [ $? -ne 0 ]; then
    log "Error: Failed to compress $LOCAL_BACKUP_DIR."
    exit 1
fi
log "Compression completed: $COMPRESSED_FILE"

# 압축 파일 크기 확인 및 로그 출력
if [ -f "$COMPRESSED_FILE" ]; then
    FILE_SIZE=$(stat -c%s "$COMPRESSED_FILE")
    HUMAN_SIZE=$(human_readable_size "$FILE_SIZE")
    log "Compressed file size: $HUMAN_SIZE"
fi

# 압축 파일을 COS에 업로드
log "Uploading compressed file to COS..."
coscli cp "$COMPRESSED_FILE" "$REMOTE_TARGET_FILE"
if [ $? -ne 0 ]; then
    log "Error: coscli cp command failed for $COMPRESSED_FILE."
    exit 1
fi
log "Upload completed: $REMOTE_TARGET_FILE"

# 업로드 성공 시 압축 파일과 원본 백업 디렉토리 삭제
log "Deleting local compressed file: $COMPRESSED_FILE"
rm -f "$COMPRESSED_FILE"
if [ $? -ne 0 ]; then
    log "Error: Failed to delete compressed file $COMPRESSED_FILE."
    exit 1
fi
log "Compressed file deleted."

log "Deleting local backup directory: $LOCAL_BACKUP_DIR"
rm -rf "$LOCAL_BACKUP_DIR"
if [ $? -ne 0 ]; then
    log
