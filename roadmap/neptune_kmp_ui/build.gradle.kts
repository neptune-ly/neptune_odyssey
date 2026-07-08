// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Root build for the Compose Multiplatform target (roadmap/neptune_kmp_ui).
// Publishable modules: :odyssey-tokens (pure Kotlin) and :odyssey-compose-ui.
// Coordinates: ly.neptune.odyssey:<module>:<version> — publish-ready metadata
// only; Maven Central credential wiring is deferred until this target meets
// the promotion bar in roadmap/ROADMAP.md.

plugins {
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.androidKmpLibrary) apply false
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.composeMultiplatform) apply false
    alias(libs.plugins.composeCompiler) apply false
}

allprojects {
    group = "ly.neptune.odyssey"
    version = "0.1.0"
}

subprojects {
    plugins.withId("maven-publish") {
        // Central requires a javadoc artifact; an empty jar is the accepted
        // convention for Kotlin Multiplatform publications.
        val javadocJar = tasks.register<Jar>("javadocJar") {
            archiveClassifier.set("javadoc")
        }
        extensions.configure<PublishingExtension> {
            publications.withType<MavenPublication>().configureEach {
                artifact(javadocJar)
                pom {
                    name.set("Neptune Odyssey — ${project.name}")
                    description.set(
                        "Neptune Odyssey white-label banking design system " +
                            "(Material 3) — Kotlin Multiplatform / Compose Multiplatform target.",
                    )
                    url.set("https://github.com/neptune-ly/neptune_odyssey")
                    licenses {
                        license {
                            name.set("Neptune Odyssey Community License v1.0")
                            url.set("https://github.com/neptune-ly/neptune_odyssey/blob/main/LICENSE")
                        }
                    }
                    developers {
                        developer {
                            id.set("neptune-fintech")
                            name.set("Neptune.Fintech")
                            url.set("https://neptune.ly")
                        }
                    }
                    scm {
                        url.set("https://github.com/neptune-ly/neptune_odyssey")
                        connection.set("scm:git:git://github.com/neptune-ly/neptune_odyssey.git")
                        developerConnection.set("scm:git:ssh://git@github.com/neptune-ly/neptune_odyssey.git")
                    }
                }
            }
        }
    }
}
