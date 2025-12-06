plugins {
    id("com.android.application") version "8.9.1" apply false // Use the actual version string
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false // Use the actual version string
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin") version "2.0.1" apply false
    // alias(libs.plugins.kotlin.compose) apply false
    // alias(libs.plugins.secrets.gradle.plugin) apply false
}

allprojects {
    repositories {
        gradlePluginPortal() // added 
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
