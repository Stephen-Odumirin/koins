# Assets

Every file in `assets/` and every third-party asset used by the app is listed here with its source and license. Files that were removed are listed as removed.

| File | What it is | Source | License |
|---|---|---|---|
| `assets/fonts/Manrope-Regular.ttf` | Manrope, weight 400 | Static instance cut from the Manrope variable font (google/fonts, `ofl/manrope`) using fontTools | SIL Open Font License 1.1 (`assets/fonts/OFL-Manrope.txt`) |
| `assets/fonts/Manrope-SemiBold.ttf` | Manrope, weight 600 | Same as above | SIL Open Font License 1.1 |
| `assets/fonts/Manrope-Bold.ttf` | Manrope, weight 700 | Same as above | SIL Open Font License 1.1 |
| `assets/fonts/Manrope-ExtraBold.ttf` | Manrope, weight 800 | Same as above | SIL Open Font License 1.1 |
| `assets/fonts/OFL-Manrope.txt` | Font license text | https://github.com/google/fonts/tree/main/ofl/manrope | SIL Open Font License 1.1 |
| `assets/onboarding/illustration_1.svg`, `illustration_2.svg`, `illustration_3.svg` | Onboarding illustrations: saving toward a goal, plans and progress, security and the PIN | Original work, drawn by hand for this project | Project's own license (original; no third-party material) |
| Material icons | Icons used across screens | Flutter SDK `Icons` class | Flutter SDK license (BSD-3-Clause) |

### Koins Bank asset bundle

Copied from `koinsbank-flutter-assets` (a built `flutter_assets` bundle from the Koins Bank app), provided by the project owner for use in this project. The copied files keep their original names. The owner is responsible for confirming the right to use them; no license has been verified.

| File or folder | Status | Contents | Source | License |
|---|---|---|---|---|
| `assets/icons/app_icon2.png` | Used | Launcher icon source (flutter_launcher_icons) | Koins Bank app bundle | Owner to confirm |
| `assets/icons/app_icon_foreground.png` | Used | Adaptive launcher icon foreground: the white mark on a transparent background (500x500 RGBA) | Derived from `app_icon2.png` by making the green background transparent | Same as the Koins Bank bundle (owner to confirm) |
| `assets/icons/login_logo.svg` | Used | Brand mark on splash and login | Koins Bank app bundle | Owner to confirm |
| `assets/images/onboard1.png`, `onboard2.png`, `onboard3.png` | No longer used (not in `pubspec.yaml`, not referenced; files kept on disk) | Former onboarding slide images, replaced by the SVGs below | Koins Bank app bundle | Owner to confirm |

### Removed Koins assets

The rest of the Koins Bank bundle was unused and has been removed (removed; restore from 8886ca6, e.g. `git checkout 8886ca6 -- <path>`). Removed: 155 other files in `assets/icons/` (SVG and PNG icons, `app_icon.png`, `app_icon3.png`, `Frame%204.png`); `assets/images/` `bin.gif`, `clap.gif`, `employ.gif`, `notificationoutline.png`, `onboard_left_img1-3.png`, `onboard_phone1-3.png`, `onboard_right_img1-3.png`; `assets/animation_icon/` `Loading.json` (removed when the drawn `BrandLoader` replaced the Lottie animation), `OTP.json`, `password.json`, `successful.json`; `assets/pdf/koins_mfb_compliance.pdf`; `assets/scripts/event_listener.js`; and `assets/fonts/AvenirLTStd-*.otf` (commercial font, also dropped from `pubspec.yaml`).

Registered in `pubspec.yaml`: the used files above are listed individually as assets, and the Manrope family with its four weights as fonts.
