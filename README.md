# Couple Diary (Flutter Web MVP)

A lightweight emotional couple diary app built with Flutter Web. Users can enter as guest, write diary entries, browse entries in a card-based list, and open detailed diary pages.

## CI/CD

- **Pull Requests** run validation checks via GitHub Actions:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
  - `flutter build web`
- **Pushes to `main`** build and deploy the web app to GitHub Pages.

## GitHub Pages URL

After deployment from `main`, access the app at:

`https://<your-github-username>.github.io/realvibecodingapp/`

Replace `<your-github-username>` with your GitHub account or org name.

## Local run

```bash
flutter pub get
flutter run -d chrome
```
