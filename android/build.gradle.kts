import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must come after Android and Kotlin.
    // Removed duplicate application of dev.flutter.flutter-gradle-plugin here; keep it in android/app/build.gradle.kts only.
}

android {
    namespace = "com.careplus.care_plus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Bump this if you already published under a different id.
        applicationId = "com.careplus.care_plus"
        minSdk = 23 // Android 6.0 — covers 99%+ of the Indian install base
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Wired up in §2 of the Android README — reads key.properties if
            // present, otherwise release builds fall back to the debug key
            // below so `flutter build apk --release` still succeeds locally.
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                // Use Kotlin's File.inputStream() extension instead of java.io.FileInputStream
                // to avoid unresolved reference issues in the Gradle Kotlin DSL.
                keystoreProperties.load(keystorePropertiesFile.inputStream())
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Falls back to the debug signing config until key.properties exists,
            // so `flutter build apk --release` works out of the box for testing.
            val keystorePropertiesFile = rootProject.file("key.properties")
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
