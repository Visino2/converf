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
subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val extension = project.extensions.getByName("android")
            try {
                // Set Namespace if missing
                val nsMethod = extension.javaClass.getMethod("getNamespace")
                if (nsMethod.invoke(extension) == null) {
                    val packageName = "com.converf.fallback.${project.name.replace("-", "_")}"
                    val setNsMethod = extension.javaClass.getMethod("setNamespace", String::class.java)
                    setNsMethod.invoke(extension, packageName)
                }
                
                // Set compileSdkVersion to 36
                try {
                    val setCompileSdk = extension.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    setCompileSdk.invoke(extension, 36)
                } catch (e: Exception) {
                    try {
                        val setCompileSdkStr = extension.javaClass.getMethod("setCompileSdkVersion", String::class.java)
                        setCompileSdkStr.invoke(extension, "android-36")
                    } catch (e2: Exception) {}
                }
                
                // Set Java Compatibility to 17
                val getCompileOptions = extension.javaClass.getMethod("getCompileOptions")
                val compileOptions = getCompileOptions.invoke(extension)
                val setSource = compileOptions.javaClass.getMethod("setSourceCompatibility", org.gradle.api.JavaVersion::class.java)
                val setTarget = compileOptions.javaClass.getMethod("setTargetCompatibility", org.gradle.api.JavaVersion::class.java)
                setSource.invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
                setTarget.invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
            } catch (e: Exception) {
                // Ignore if methods not found
            }

            // Set Kotlin Compatibility to 17
            project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                kotlinOptions.jvmTarget = "17"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
