// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Thin Android launcher for the gallery — all UI (including the activity)
// lives in :gallery's androidMain; this module only packages the APK.

plugins {
    alias(libs.plugins.androidApplication)
}

android {
    namespace = "ly.neptune.odyssey.gallery.app"
    compileSdk = 36

    defaultConfig {
        applicationId = "ly.neptune.odyssey.gallery"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "0.1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation(project(":gallery"))
}
