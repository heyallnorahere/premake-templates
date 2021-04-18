workspace (workspacename)
    architecture "x64"
    targetdir "bin"
    configurations {
        "Debug",
        "Release"
    }
    flags {
        "MultiProcessorCompile"
    }
    startproject (startprojectname)
    filter "system:windows"
        defines {
            "_CRT_SECURE_NO_WARNINGS",
            "SYSTEM_WINDOWS"
        }
    filter "system:linux"
        defines {
            "SYSTEM_LINUX"
        }
    filter "system:macosx"
        defines {
            "SYSTEM_MACOSX"
        }