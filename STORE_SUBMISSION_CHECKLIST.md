# Store Submission Checklist

Repository changes now cover the native pieces that belong in source control:

- iOS camera usage string is present for QR scanning.
- Android camera permission and camera feature declarations are explicit.
- Release builds can no longer ship with localhost Supabase defaults.
- Android release signing is wired to `android/key.properties` instead of the debug key.
- Placeholder package identifiers and app labels were replaced with store-safe defaults.

Manual steps still required outside the repo before submission:

1. Create the Android upload keystore and fill in `android/key.properties` from `android/key.properties.example`.
2. Build with production Supabase values:
   `--dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=...`
3. Replace the current launcher/app icons if they are still temporary.
4. Provide a privacy policy URL in both App Store Connect and Play Console.
5. Complete the App Privacy questionnaire in App Store Connect.
6. Complete the Data safety form in Play Console.
7. Upload store screenshots, descriptions, support URL, and contact details.
8. Verify the export compliance answer in App Store Connect. The project currently declares `ITSAppUsesNonExemptEncryption = false`.
9. Run a final device pass on iPhone and Android to confirm camera permission prompts, denied-permission behavior, and login against production.
