// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// :gallery — the unpublished reference gallery (the Flutter example-app
// analog): every core component × 4 brands × light/dark × LTR/RTL, runnable
// on desktop (`:gallery:run`), Android (:gallery-android), and the browser
// (`:gallery:wasmJsBrowserDevelopmentRun` / `jsBrowserDevelopmentRun`); iOS
// embeds MainViewController() from iosMain. `:gallery:renderShots` is the
// SHOTS-analog headless pixel sweep (rulebook §5).

import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidKmpLibrary)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
}

kotlin {
    jvmToolchain(17)

    jvm()
    androidLibrary {
        namespace = "ly.neptune.odyssey.gallery"
        compileSdk = 36
        minSdk = 24
    }
    iosArm64()
    iosSimulatorArm64()
    js {
        browser()
        binaries.executable()
    }
    @OptIn(ExperimentalWasmDsl::class)
    wasmJs {
        browser()
        binaries.executable()
    }

    sourceSets {
        commonMain.dependencies {
            implementation(project(":odyssey-compose-ui"))
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
        }
        jvmMain.dependencies {
            implementation(compose.desktop.currentOs)
        }
        androidMain.dependencies {
            implementation(libs.androidx.activityCompose)
        }
    }
}

compose.desktop {
    application {
        mainClass = "ly.neptune.odyssey.gallery.MainKt"
    }
}

// SHOTS-analog: headless engine render of every gallery section × brand ×
// mode × direction into PNGs (then gated by tools/blank_check.py + eyes-on).
tasks.register<JavaExec>("renderShots") {
    group = "verification"
    description = "Render the gallery to PNGs (SHOTS analog): -PshotsDir=<out>"
    val jvmTarget = kotlin.targets.getByName("jvm") as org.jetbrains.kotlin.gradle.targets.jvm.KotlinJvmTarget
    val mainCompilation = jvmTarget.compilations.getByName("main")
    dependsOn(mainCompilation.compileTaskProvider)
    classpath(mainCompilation.output.allOutputs, mainCompilation.runtimeDependencyFiles)
    mainClass.set("ly.neptune.odyssey.gallery.RenderShotsKt")
    systemProperty("skiko.renderApi", "SOFTWARE")
    args(project.findProperty("shotsDir")?.toString() ?: "${layout.buildDirectory.get()}/shots")
}
