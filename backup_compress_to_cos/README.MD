# cos_hash

## 기능
- Tencent Cloud COS 내 파일들의 MD5 해시값을 계산하여 중복을 제거한 고유 목록을 생성합니다.
- 재귀적으로 지정된 COS 경로의 모든 파일을 탐색합니다.

## 사용 방법
1. 실행 권한 부여
```bash
chmod +x cos_md5_generator.sh
```

2. 스크립트 설정
```bash
COS_PATH="cos://your-bucket-name/path/"
OUTPUT_FILE="output_hashes.txt"
TEMP_FILE="temp_hashes.txt"
```

3. 스크립트 실행
```bash
./cos_md5_generator.sh
```

## 주요 변수 및 설정
- `COS_PATH`: MD5 해시값을 생성할 파일들이 있는 COS 경로
- `OUTPUT_FILE`: 최종 해시값이 저장될 출력 파일
- `TEMP_FILE`: 작업 시 임시로 사용할 중간 저장 파일 (작업 완료 후 삭제됨)

## 보안 고려사항
- COS 접근을 위한 인증 정보 및 권한을 안전하게 관리하세요.
- 스크립트 내에서 민감한 정보를 하드코딩하지 마세요.
- 임시 파일은 작업 완료 후 자동 삭제됩니다.

## 예제 로그 출력
```
$ ./cos_md5_generator.sh
$ cat output_hashes.txt
a1b2c3d4e5f678901234567890abcdef
abcdef1234567890abcdef1234567890
...
```

---