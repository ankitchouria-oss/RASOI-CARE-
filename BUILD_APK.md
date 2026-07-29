# Getting a real .apk file

I can't compile one from inside this chat — no Flutter/Android toolchain and
no network access here. Two real ways to get one, pick whichever is less
friction for you.

## Option A — GitHub builds it for you (no local install)

The project now includes `.github/workflows/build-apk.yml`, which builds a
real APK on GitHub's own servers every time you push.

1. Create a new **empty** repo on GitHub (don't add a README there — you
   already have one).
2. From inside the unpacked `careplus_flutter/` folder:
   ```bash
   git init
   git add .
   git commit -m "Rasoi Care Flutter app"
   git branch -M main
   git remote add origin https://github.com/<you>/<repo>.git
   git push -u origin main
   ```
3. On GitHub, open the **Actions** tab. A "Build APK" run starts automatically
   (takes 3–6 minutes). When it finishes, open the run and scroll to
   **Artifacts** at the bottom — you'll see two downloadable zips:
   - `care-plus-debug-apk` — installs on any Android phone immediately,
     no signing needed. Start here.
   - `care-plus-release-apk` — smaller, optimized (minified/shrunk), signed
     with the debug key until you add your own (see the main README §1b).
4. Download, unzip, copy the `.apk` to your phone, and install it (you'll
   need to allow "install from unknown sources" the first time).

You can also trigger a rebuild anytime without a new commit: **Actions → Build
APK → Run workflow**.

## Option B — build it yourself, if you have Flutter installed anywhere

On your own Windows machine, or any machine with the Flutter SDK:

```bash
cd careplus_flutter
flutter pub get
flutter build apk --debug      # fastest, unsigned-key, good for testing
# or
flutter build apk --release    # smaller/optimized, needs android/key.properties
                                # to be properly signed (see main README §1b)
```

The output lands at `build/app/outputs/flutter-apk/app-debug.apk` (or
`app-release.apk`), which you can copy straight to a phone.

## If either build fails

Send me the exact error — GitHub Actions shows the failing step's full log,
click into it and copy the red text. Most likely culprits, in order: a
version mismatch in `pubspec.yaml` (a package needing a newer Dart SDK than
3.6), or a typo I introduced that a real compiler catches and my static
checks couldn't (see main README §6 for what I could and couldn't verify
without a toolchain).
