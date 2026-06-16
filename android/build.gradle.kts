allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Some older plugins (e.g. connectivity_plus 4.x) pin an old compileSdk that is
// too low for their transitive AndroidX deps. Raise compileSdk to 36 for any
// Android subproject. Registered before evaluationDependsOn(":app") so the
// afterEvaluate hook is in place before :app is force-evaluated, and runs after
// each plugin's own build script so it overrides their lower value.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            (ext as com.android.build.gradle.BaseExtension).apply {
                if (compileSdkVersion?.removePrefix("android-")?.toIntOrNull()
                        ?.let { it < 36 } != false
                ) {
                    compileSdkVersion(36)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
