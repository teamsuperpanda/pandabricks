plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.teamsuperpanda.pandabricks"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
    applicationId = "com.teamsuperpanda.pandabricks"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Load keystore properties from a file (try 'key.properties' or 'keystore.properties')
    // or from environment variables. This mirrors common Flutter project conventions
    // and the working `fox` project. CI (Codemagic) should provide either a
    // properties file or environment variables.
    import java.util.Properties
    import java.io.FileInputStream

    val possibleProps = listOf("key.properties", "keystore.properties")
    val keystoreProperties = Properties()
    val keystorePropertiesFile = possibleProps.map { rootProject.file(it) }.firstOrNull { it.exists() }
    if (keystorePropertiesFile != null) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    fun prop(key: String): String? {
        val fromFile = if (keystoreProperties.isEmpty) null else keystoreProperties.getProperty(key)
        if (!fromFile.isNullOrBlank()) return fromFile
        val envKey = System.getenv(key.uppercase())
        if (!envKey.isNullOrBlank()) return envKey
        return null
    }

    signingConfigs {
        create("release") {
            // Prefer explicit configuration via properties file or environment variables.
            val storeFilePath = prop("storeFile") ?: prop("KEYSTORE_PATH")

            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }

            val storePwd = prop("storePassword") ?: prop("KEYSTORE_PASSWORD")
            val alias = prop("keyAlias") ?: prop("KEY_ALIAS")
            val keyPwd = prop("keyPassword") ?: prop("KEY_PASSWORD")

            if (storePwd != null) storePassword = storePwd
            if (alias != null) keyAlias = alias
            if (keyPwd != null) keyPassword = keyPwd
        }
    }

    buildTypes {
        release {
            // Use the release signing config only when key properties or env vars are
            // provided; otherwise fall back to debug signing (local dev). This prevents
            // accidental use of an unchecked repo keystore.
            val envKeystore = System.getenv("KEYSTORE_PATH")
            val propsFileExists = possibleProps.map { rootProject.file(it) }.any { it.exists() }

            signingConfig = if (envKeystore != null || propsFileExists) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
