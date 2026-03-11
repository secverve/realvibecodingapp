# 우리의 기록 (Flutter Web/iOS MVP)

커플/소규모(최대 5명 내) 기록용 감성 앱 MVP입니다.

## 주요 기능
- 초대코드 로그인 (테스트용)
- 포토 앨범 (사진 업로드 + 메모 + 작성자 구분)
- 일정 캘린더 (날짜별 약속 등록 + 작성자 구분)
- 편지 보관함
  - 비밀 편지(열람 날짜 전 잠금)
  - 작성자(나/상대) 구분
- 내 정보 설정
  - 내 이름 / 상대 이름
  - 처음 만난 날
  - 각자 생일
- 메인 디데이 자동 반영
  - 처음 만난 날
  - 100일 / 200일
  - 각자 생일
  - 함께한 날짜 카운트

## CI/CD
- **PR**: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web`
- **main push**: GitHub Pages 배포

## 배포 URL
`https://<github-username>.github.io/realvibecodingapp/`

## 로컬 실행
```bash
flutter pub get
flutter run -d chrome
flutter run -d ios
```
