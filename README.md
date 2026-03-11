# 우리의 기록 (Flutter Web/iOS MVP)

커플을 위한 감성 기록 앱 MVP입니다. (최대 5명 이하 소규모 테스트 가정)

주요 기능
- 초대코드 로그인 (현재 테스트용)
- 포토 앨범 (사진 업로드 + 메모 저장)
- 일정 캘린더 (약속 등록/조회)
- 편지 기능
  - 비밀 편지 (특정 날짜 이후 열람)
  - 편지 모아보기
  - 예쁜 문장 자동완성 선택
- 메인 디데이 카드 (기념일/생일)

## CI/CD

- **PR 생성 시** GitHub Actions에서 아래를 실행합니다.
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
  - `flutter build web`
- **main 브랜치 push 시** GitHub Pages로 웹 빌드를 배포합니다.

## 배포 주소

`https://<github-username>.github.io/realvibecodingapp/`

`<github-username>`를 실제 사용자/조직명으로 바꿔 접속하세요.

## 로컬 실행

```bash
flutter pub get
flutter run -d chrome
# iOS
flutter run -d ios
```
