// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// :odyssey-compose-ui — the Compose Multiplatform implementation of the
// Odyssey design system: NeptuneTheme (three entry points), the identity
// layer (glass/motifs/elevation-glow/gradients/type), the full component set,
// the screen/onboarding templates + white-label demo shell, and the 94-icon
// set. Depends on :odyssey-tokens for all color math and brand data.

import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidKmpLibrary)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    `maven-publish`
}

kotlin {
    explicitApi()
    jvmToolchain(17)

    // Default hierarchy + a "skiko" intermediate source set shared by every
    // Skia-rendering target (desktop/iOS/web) — hosts the blur-mask actual.
    @OptIn(ExperimentalKotlinGradlePluginApi::class)
    applyDefaultHierarchyTemplate {
        common {
            group("skiko") {
                withJvm()
                withIos()
                withJs()
                withWasmJs()
            }
        }
    }

    jvm()
    androidLibrary {
        namespace = "ly.neptune.odyssey.ui"
        compileSdk = 36
        minSdk = 24
    }
    // No iosX64: CMP 1.11 publishes no Intel-simulator artifacts.
    iosArm64()
    iosSimulatorArm64()
    js {
        browser()
    }
    @OptIn(ExperimentalWasmDsl::class)
    wasmJs {
        browser()
    }

    sourceSets {
        commonMain.dependencies {
            api(project(":odyssey-tokens"))
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
            // api: the public Res class hands out FontResource, and web
            // consumers call preloadFont(Res.font.…) — both live here.
            api(compose.components.resources)
            implementation(libs.haze)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }

        // The skiko group (declared in the hierarchy template above) needs the
        // skiko API for MaskFilter — pinned to the version CMP 1.11.1 ships.
        named("skikoMain") {
            dependencies {
                implementation(libs.skiko)
            }
        }
    }
}

compose.resources {
    packageOfResClass = "ly.neptune.odyssey.ui.resources"
    // Public so web (wasm/js) consumers can `preloadFont(Res.font.…)` the
    // bundled brand faces and avoid the flash-of-default-font (README §Web).
    publicResClass = true
}
