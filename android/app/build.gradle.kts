plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must come after Android and Kotlin.
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
            val keystoreProperties = java.util.Properties()
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
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
-            isMinifyEnabled = true
-            isShrinkResources = true
+            // Temporarily disable shrinking to avoid R8 missing-class failure
+            // while keep rules / dependency are added. Re-enable for production.
+            isMinifyEnabled = false
+            isShrinkResources = false
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

// Play Core dependency needed so R8 can resolve com.google.android.play.core.*
// referenced by Flutter's PlayStoreDeferredComponentManager.
dependencies {
    implementation("com.google.android.play:core:1.10.3")
}
