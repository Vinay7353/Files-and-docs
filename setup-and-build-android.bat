@echo off
REM ============================================================
REM BlackBoxApp Android Build Setup Script
REM This script sets up all required fixes and builds the app
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo BlackBoxApp Android Build Setup
echo ============================================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo [1/8] Checking Node.js installation...
node --version
npm --version
echo.

REM Check if Android SDK is set up
if not defined ANDROID_SDK_ROOT (
    echo WARNING: ANDROID_SDK_ROOT not set. Checking common locations...
    if exist "%APPDATA%\Local\Android\Sdk" (
        set ANDROID_SDK_ROOT=%APPDATA%\Local\Android\Sdk
        echo Found Android SDK at: !ANDROID_SDK_ROOT!
    ) else (
        echo ERROR: Android SDK not found
        echo Please set ANDROID_SDK_ROOT environment variable
        pause
        exit /b 1
    )
)

echo [2/8] Setting up Android SDK environment...
set ANDROID_HOME=%ANDROID_SDK_ROOT%
echo ANDROID_SDK_ROOT=%ANDROID_SDK_ROOT%
echo.

REM Install npm dependencies
echo [3/8] Installing npm dependencies...
call npm install
if errorlevel 1 (
    echo ERROR: npm install failed
    pause
    exit /b 1
)
echo.

REM Fix cordova.gradle to support newer build tools
echo [4/8] Patching cordova.gradle for build-tools compatibility...
set CORDOVA_GRADLE=platforms\android\CordovaLib\cordova.gradle

if exist "!CORDOVA_GRADLE!" (
    REM Check if already patched
    findstr /M "isLowerThan(maxVersion)" "!CORDOVA_GRADLE!" >nul
    if errorlevel 1 (
        echo Patching cordova.gradle...
        REM Create backup
        copy "!CORDOVA_GRADLE!" "!CORDOVA_GRADLE!.bak" >nul
        
        REM Patch the file using PowerShell
        powershell -Command "
            \$content = Get-Content '!CORDOVA_GRADLE!' -Raw
            \$content = \$content -replace 'def maxVersion = new Version\(\(minBuildToolsVersion\.getMajor\(\) \+ 1\) \+ \"\.0\.0\"\)', 'def maxVersion = new Version(\"37.0.0\")'
            \$content = \$content -replace '\.findAll \{ it\.isHigherThan\(''0\.0\.0''\) && it\.isLowerThan\(maxVersion\) \}', '.findAll { it.isHigherThan(\"0.0.0\") && !it.isLowerThan(minBuildToolsVersionString) && it.isLowerThan(maxVersion) }'
            \$content = \$content -replace 'if \(highestBuildToolsVersion\.isLowerThan\(minBuildToolsVersionString\)\) \{[^}]+\}', ''
            Set-Content '!CORDOVA_GRADLE!' \$content
        " 2>nul
        echo cordova.gradle patched successfully
    ) else (
        echo cordova.gradle already patched
    )
) else (
    echo WARNING: cordova.gradle not found - platforms/android may not be initialized
    echo Building will initialize cordova platforms
)
echo.

REM Set up D8 instead of DX for newer build tools
echo [5/8] Setting up D8 compiler support...
set BUILD_TOOLS_DIR=%ANDROID_SDK_ROOT%\build-tools
if exist "!BUILD_TOOLS_DIR!\36.1.0\lib\d8.jar" (
    if not exist "!BUILD_TOOLS_DIR!\36.1.0\lib\dx.jar" (
        echo Creating dx.jar as symlink to d8.jar...
        cd "!BUILD_TOOLS_DIR!\36.1.0\lib"
        mklink dx.jar d8.jar >nul 2>&1
        if errorlevel 1 (
            echo Copying d8.jar to dx.jar (symlink failed)...
            copy d8.jar dx.jar >nul
        )
        cd %CD%
        echo D8 setup complete
    ) else (
        echo dx.jar already exists
    )
) else (
    echo WARNING: Build-tools 36.1.0 not found in !BUILD_TOOLS_DIR!
)
echo.

REM Configure gradle.properties
echo [6/8] Configuring gradle.properties...
set GRADLE_PROPS=platforms\android\gradle.properties
if exist "!GRADLE_PROPS!" (
    REM Check if D8 is already enabled
    findstr /C:"android.enableD8=true" "!GRADLE_PROPS!" >nul
    if errorlevel 1 (
        echo Enabling D8 in gradle.properties...
        echo android.enableD8=true >> "!GRADLE_PROPS!"
    else
        echo D8 already enabled in gradle.properties
    )
) else (
    echo WARNING: gradle.properties not found
)
echo.

REM Configure app/build.gradle with dexOptions
echo [7/8] Configuring app/build.gradle...
set APP_GRADLE=platforms\android\app\build.gradle
if exist "!APP_GRADLE!" (
    findstr /C:"dexOptions {" "!APP_GRADLE!" >nul
    if errorlevel 1 (
        echo Adding dexOptions to app/build.gradle...
        REM Backup
        copy "!APP_GRADLE!" "!APP_GRADLE!.bak" >nul
        
        powershell -Command "
            \$content = Get-Content '!APP_GRADLE!' -Raw
            \$dexOptions = @'
            
    dexOptions {
        usePreDex false
    }
'@
            \$content = \$content -replace '(compileOptions \{[^}]+targetCompatibility JavaVersion\.VERSION_1_8\s*\})', \"`$1\$dexOptions\"
            Set-Content '!APP_GRADLE!' \$content
        " 2>nul
        echo dexOptions added to app/build.gradle
    ) else
        echo dexOptions already present in app/build.gradle
    )
) else (
    echo WARNING: app/build.gradle not found - will be created during build
)
echo.

REM Clean previous builds
echo [8/8] Cleaning previous builds...
if exist "platforms\android\build" (
    rmdir /s /q "platforms\android\build" >nul 2>&1
    echo Build directory cleaned
)
echo.

REM Build the Android app
echo ============================================================
echo Starting Android Build...
echo ============================================================
echo.

call npm run android

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: Android build failed
    echo ============================================================
    echo.
    echo Please check the error messages above
    pause
    exit /b 1
) else (
    echo.
    echo ============================================================
    echo SUCCESS: Android build completed!
    echo ============================================================
    echo.
    echo The APK has been built and should be running on your device/emulator
    pause
)

endlocal
exit /b 0
