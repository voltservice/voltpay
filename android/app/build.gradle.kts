import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "net.metalbrain.voltpay"
    compileSdk = 36
    ndkVersion = "27.0.12077973"
    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_21)
        }
    }

    signingConfigs {
        create("release") {
            // read from gradle.properties
            storeFile = file(findProperty("RELEASE_STORE_FILE") as String)
            storePassword = findProperty("RELEASE_STORE_PASSWORD") as String?
            keyAlias = findProperty("RELEASE_KEY_ALIAS") as String?
            keyPassword = findProperty("RELEASE_KEY_PASSWORD") as String?
        }
    }

    defaultConfig {
        applicationId = "net.metalbrain.voltpay"
        minSdk = 24
        targetSdk = 36
        versionCode = 3
        versionName = "1.0.0"
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
        // ✅ Kotlin DSL: use getByName or create; do not use Groovy-style blocks
        getByName("release") {
            // For now, sign like debug so `flutter run --release` works
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
//    // Play Integrity
    implementation("com.google.android.play:integrity:1.5.0")
    implementation("com.google.firebase:firebase-appcheck-playintegrity")

    // Lottie
    implementation("com.github.LottieFiles:dotlottie-android:0.11.0")

    // Google Maps
    implementation("com.google.android.gms:play-services-maps:19.2.0")

    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
    implementation("com.google.firebase:firebase-auth:24.0.1")
    implementation("com.google.firebase:firebase-analytics")
    // Google Sign-In
    implementation("com.google.android.gms:play-services-auth:21.4.0")

    // Facebook login
    implementation("com.facebook.android:facebook-login:latest.release")

    // AndroidX Credentials (your versions)
    implementation("androidx.credentials:credentials:1.6.0-alpha05")
    implementation("androidx.credentials:credentials:1.3.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.3.0")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.1")
    implementation("androidx.credentials:credentials-play-services-auth:1.6.0-alpha05")
}

flutter {
    source = "../.."
}
