# MT Alchemy Flutter UI Prototype — Checkpoint 1

This bundle contains the `lib/` source, `pubspec.yaml`, and the image assets used by the Home screen and other pages.

## Run
1. Back up your existing Flutter project.
2. Extract this ZIP into the Flutter project root (the same folder that contains `android/`, `ios/`, and `web/`).
3. Run `flutter pub get`.
4. Run `flutter run`.

## Journey C — Employer (UI prototype only)
From Home, select **Explore Corporate Learning**. The Employer Portal has four connected steps:
1. Register organisation
2. Add employees
3. Assign a course to selected employees
4. View sample learning progress

This checkpoint uses local demo data only; it does not connect to Firebase or a backend. The employer form and employee form validate required fields. Added employees and course selections are held in memory while the screen is open.

## Note
No Flutter SDK/compiler was available in the preparation environment, so run the app locally and check `flutter analyze` before presenting.
