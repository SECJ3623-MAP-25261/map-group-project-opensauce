// 1. ADD THIS BLOCK AT THE VERY TOP
plugins {
    // This defines the plugin for the whole project but doesn't apply it yet (apply false)
    id("com.google.gms.google-services") version "4.4.2" apply false
}

// 2. YOUR EXISTING CODE STARTS HERE
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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