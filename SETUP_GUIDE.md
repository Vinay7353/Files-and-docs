# BlackBoxApp - Setup and Build Guide

## Quick Start (One-Click Setup)

### Windows (Android Development)

1. **Download and Install Prerequisites:**
   - **Node.js**: Download from https://nodejs.org/ (Latest LTS version)
   - **Android SDK**: Download from https://developer.android.com/studio
   - **Java JDK**: Download from https://www.oracle.com/java/technologies/downloads/
   - **Git**: Download from https://git-scm.com/

2. **Set Environment Variables:**
   - Set `ANDROID_SDK_ROOT` = `C:\Users\[YourUsername]\AppData\Local\Android\Sdk` (or your Android SDK installation path)
   - Set `JAVA_HOME` = Your Java installation path (e.g., `C:\Program Files\Java\jdk-11.0.x`)
   - Add `%ANDROID_SDK_ROOT%\platform-tools` to your PATH

3. **Run the Setup Script:**
   - Open Command Prompt (cmd.exe)
   - Navigate to the BlackBoxApp folder
   - Run: `setup-and-build-android.bat`
   - The script will automatically:
     - Install npm dependencies
     - Apply necessary gradle patches
     - Set up D8 compiler support (for newer Android SDK)
     - Configure build settings
     - Build and deploy the Android app

### macOS (iOS Development)

1. **Download and Install Prerequisites:**
   - **Xcode**: Open App Store → Search "Xcode" → Install
   - **Node.js**: `brew install node`
   - **CocoaPods**: `sudo gem install cocoapods`

2. **Run the Build:**
   ```bash
   npm install
   npm run ios
   ```

### Linux (Android Development)

Use the Windows Android setup steps but run commands in terminal:
```bash
npm install
npm run android
```

---

## What Each Script Does

### `setup-and-build-android.bat`

This comprehensive script handles:

1. ✅ Verifies Node.js and npm are installed
2. ✅ Sets up Android SDK environment variables
3. ✅ Installs npm dependencies
4. ✅ **Patches cordova.gradle** - Fixed to recognize build-tools versions 36+
5. ✅ **Sets up D8 compiler** - Creates dx.jar symlink to d8.jar (enables newer build tools)
6. ✅ **Configures gradle.properties** - Enables D8 for dex compilation
7. ✅ **Configures app/build.gradle** - Adds dexOptions for compatibility
8. ✅ Cleans previous builds
9. ✅ Builds the Android app
10. ✅ Deploys to connected device or emulator

**Why These Fixes Are Needed:**

- **Old Cordova with New Android SDK**: The original Cordova configuration requires the `DX` tool, which was removed in Android Build Tools 31+. Our fixes enable `D8` (the modern replacement).
- **Build-Tools Version Detection**: We patch the version detection logic to find the latest available build tools instead of being limited to a specific major version.
- **Gradle Compatibility**: We configure gradle to use modern Java bytecode compilation while maintaining compatibility with older Cordova packages.

---

## Manual Build Commands

If you prefer to run commands manually:

### Install Dependencies
```bash
npm install
```

### Build Only (No Installation)
```bash
npm run build
```

### Build and Deploy to Android
```bash
npm run android
```

### Build for Production
```bash
npm run build --env prod
cordova build android
```

### Deploy to iOS
```bash
npm run ios
```

---

## Troubleshooting

### Issue: "ANDROID_SDK_ROOT not set"
**Solution:** Set the environment variable:
- Windows: Right-click "This PC" → Properties → Advanced system settings → Environment Variables
- Add: `ANDROID_SDK_ROOT` = `C:\Users\[You]\AppData\Local\Android\Sdk`

### Issue: "No Java compiler found"
**Solution:** Set `JAVA_HOME` environment variable:
- Windows: Add environment variable `JAVA_HOME` = `C:\Program Files\Java\jdk-11.0.x`

### Issue: "No emulator found"
**Solution:** Launch Android emulator before building:
```bash
# From Android SDK tools
emulator -avd YourEmulatorName
```

Or connect a physical Android device via USB with USB debugging enabled.

### Issue: "Build-tools version not found"
**Solution:** The script automatically handles this by:
1. Creating a symlink from d8.jar to dx.jar
2. Enabling D8 compiler in gradle.properties
3. Patching the gradle script to find available build tools

If this fails, manually install build-tools:
```bash
# Using Android SDK Manager
sdkmanager "build-tools;36.0.0"
```

### Issue: Permission Denied on dx.jar symlink
**Solution:** Run Command Prompt as Administrator, then run the batch file.

---

## Directory Structure

```
blackboxApp/
├── setup-and-build-android.bat    ← Run this to build for Android
├── setup-and-build-ios.bat        ← Instructions for iOS
├── package.json                   ← npm configuration
├── app/                           ← Application source code
├── platforms/
│   └── android/                   ← Generated Android project
│       ├── build.gradle           ← Main gradle config
│       ├── gradle.properties       ← Gradle properties (D8 config)
│       ├── CordovaLib/
│       │   └── cordova.gradle      ← Patched to support new build-tools
│       └── app/
│           ├── build.gradle        ← App-specific gradle config
│           │   (has dexOptions)
│           └── src/                ← Java source code
└── plugins/                        ← Cordova plugins
```

---

## Configuration Files Modified

The setup script modifies these files automatically:

### 1. `platforms/android/CordovaLib/cordova.gradle`
- **Fix**: Changed build-tools version detection to support 36+ versions
- **Reason**: Older Cordova was limited to finding versions within next major version

### 2. `platforms/android/gradle.properties`
- **Added**: `android.enableD8=true`
- **Reason**: Enable D8 bytecode compiler (replacement for DX)

### 3. `platforms/android/app/build.gradle`
- **Added**: `dexOptions { usePreDex false }`
- **Reason**: Disable pre-dex optimization for compatibility

---

## Development Workflow

### Hot Reload (Dev Mode)
For live development changes:
```bash
npm run watch
# In another terminal:
npm run android
```

### Production Build
```bash
npm run build --env prod
cordova build android --release
```

### Testing
```bash
npm run test
```

### Linting
```bash
npm run lint
npm run lint-fix
```

---

## Next Steps

1. **First Time Setup**: Run `setup-and-build-android.bat` on your new laptop
2. **Connect Device or Emulator**: Plug in an Android device or start an emulator
3. **Build & Deploy**: The script will automatically deploy to your device
4. **Monitor Logs**: Check the device output in the terminal

---

## Contact & Support

For issues or questions:
- Check the troubleshooting section above
- Review error messages in the build output
- Ensure all prerequisites are properly installed
- Verify environment variables are set correctly

---

## Version Information

- **Cordova Version**: 10.1.2
- **Cordova-Android**: 10.1.2
- **Android SDK**: API 30 (minimum), API 30+ recommended
- **Build Tools**: 36.0.0+ (automatically detected)
- **Node.js**: 14.0.0 or newer
- **Java JDK**: 11 or newer

---

**Last Updated**: March 30, 2026
