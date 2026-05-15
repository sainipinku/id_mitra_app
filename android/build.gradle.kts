allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix for isar_flutter_libs missing namespace with AGP 8.x
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                val namespaceMethod = androidExt.javaClass.methods.find { it.name == "getNamespace" }
                val currentNamespace = namespaceMethod?.invoke(androidExt) as? String
                if (currentNamespace.isNullOrEmpty()) {
                    val setNamespace = androidExt.javaClass.methods.find { it.name == "setNamespace" }
                    setNamespace?.invoke(androidExt, "com.isar.${project.name.replace("-", "_").replace(".", "_")}")
                }
            }
        }
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
