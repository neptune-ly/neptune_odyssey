// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// Root build for the Compose Multiplatform package (packages/neptune_kmp_ui).
// Publishable modules: :odyssey-tokens (pure Kotlin) and :odyssey-compose-ui.
// Coordinates: ly.neptune.odyssey:<module>:<version>.
//
// Maven Central: the release path is prepped, waiting only on credentials.
// `./gradlew centralBundle` stages every publication (signed when the
// `signingInMemoryKey`/`signingInMemoryKeyPassword` properties are present —
// CI passes them as ORG_GRADLE_PROJECT_* env vars) into build/staging-deploy
// and zips it for the Central Portal upload API; .github/workflows/
// release-kmp.yml does the upload on a kmp-v* tag. Without the signing
// properties everything still publishes unsigned (publishToMavenLocal, CI
// smoke) — no credentials ever live in the repo.

plugins {
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.androidKmpLibrary) apply false
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.composeMultiplatform) apply false
    alias(libs.plugins.composeCompiler) apply false
}

allprojects {
    group = "ly.neptune.odyssey"
    version = "0.4.0"
}

subprojects {
    plugins.withId("maven-publish") {
        // Central requires a javadoc artifact; an empty jar is the accepted
        // convention for Kotlin Multiplatform publications.
        val javadocJar = tasks.register<Jar>("javadocJar") {
            archiveClassifier.set("javadoc")
        }
        extensions.configure<PublishingExtension> {
            // File repo the Central bundle is staged into. Publishing to a
            // file repo makes Gradle emit the .md5/.sha1 checksums the
            // Portal validates; the signing plugin adds the .asc files.
            repositories {
                maven {
                    name = "staging"
                    url = uri(rootProject.layout.buildDirectory.dir("staging-deploy").get().asFile.toURI())
                }
            }
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

        // Sign every publication when the in-memory key is provided (release
        // CI); local/unsigned publishing keeps working when it is not.
        apply(plugin = "signing")
        extensions.configure<org.gradle.plugins.signing.SigningExtension>("signing") {
            val key = providers.gradleProperty("signingInMemoryKey").orNull
            if (key != null) {
                useInMemoryPgpKeys(key, providers.gradleProperty("signingInMemoryKeyPassword").getOrElse(""))
                sign(extensions.getByType<PublishingExtension>().publications)
            }
        }
        // KMP publications share output directories — publish tasks must wait
        // for every sign task or Gradle 8+ fails the implicit-dependency check.
        tasks.withType<org.gradle.api.publish.maven.tasks.AbstractPublishToMaven>().configureEach {
            dependsOn(tasks.withType<org.gradle.plugins.signing.Sign>())
        }
        // The bundle zips whatever is in staging-deploy — stale artifacts from
        // an earlier run must be gone before this run publishes into it. Every
        // per-publication publish task writes there, not just the umbrella.
        tasks.matching { it.name.endsWith("ToStagingRepository") }.configureEach {
            mustRunAfter(":cleanStaging")
        }
    }
}

// --- Maven Central release bundle (Central Portal upload API) ---------------

tasks.register<Delete>("cleanStaging") {
    delete(layout.buildDirectory.dir("staging-deploy"))
}

tasks.register<Zip>("centralBundle") {
    group = "publishing"
    description = "Stage (and sign, when keys are present) all publications, " +
        "then zip them for https://central.sonatype.com/api/v1/publisher/upload"
    dependsOn(":cleanStaging")
    dependsOn(":odyssey-tokens:publishAllPublicationsToStagingRepository")
    dependsOn(":odyssey-compose-ui:publishAllPublicationsToStagingRepository")
    from(layout.buildDirectory.dir("staging-deploy"))
    // The Portal rejects repository-level metadata files in upload bundles.
    exclude("**/maven-metadata.xml*")
    archiveFileName.set("central-bundle.zip")
    destinationDirectory.set(layout.buildDirectory.dir("central"))
}
