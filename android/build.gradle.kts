allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// 🛠️ รวม afterEvaluate ทั้งหมดไว้ในบล็อกเดียว (วางไว้ก่อน evaluationDependsOn)
subprojects {
    afterEvaluate {
        // 1. FIX ISAR NAMESPACE ISSUE
        if (name == "isar_flutter_libs") {
            try {
                val androidExt = extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
                androidExt?.namespace = "dev.isar.isar_flutter_libs"
            } catch (e: Exception) {
                println("Could not set namespace for isar_flutter_libs: $e")
            }
        }

        // 2. บังคับ compileSdk 35 และแก้ Error: mergeDebugJavaResource
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            
            when (androidExt) {
                is com.android.build.gradle.LibraryExtension -> {
                    androidExt.compileSdk = 35
                    
                    // ใส่ Packaging Options ตรงนี้เลย
                    androidExt.packaging {
                        resources {
                            pickFirsts.add("META-INF/LICENSE.md")
                            pickFirsts.add("META-INF/LICENSE-notice.md")
                            pickFirsts.add("META-INF/NOTICE.md")
                            pickFirsts.add("META-INF/NOTICE.txt")
                            excludes.add("META-INF/DEPENDENCIES")
                            excludes.add("META-INF/LICENSE")
                            excludes.add("META-INF/NOTICE")
                            excludes.add("META-INF/*.kotlin_module")
                        }
                    }
                }
                is com.android.build.gradle.AppExtension -> {
                    androidExt.compileSdkVersion(35)
                }
            }
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// คำสั่งนี้ต้องอยู่ล่างสุด หลังจาก afterEvaluate ด้านบนทำงานเสร็จแล้ว
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}