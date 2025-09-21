// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // ✅ Ensure correct version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10") // ✅ Kotlin plugin
        classpath("com.google.gms:google-services:4.4.1") // ✅ For Firebase (optional if used)
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Safely override build directory
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
