workspacename = "test-workspace"
startprojectname = "testproject"
include "../scripts/workspace.lua"
outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"
curldir = "../test/curl"
include "../scripts/curl.lua"
project "testproject"
    location "testproject"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++17"
    staticruntime "on"
    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")
    sysincludedirs {
        "curl/include"
    }
    files {
        "%{prj.name}/src/**.cpp",
        "%{prj.name}/src/**.h",
    }
    defines {
        "CURL_STATICLIB",
    }
    links {
        "curl"
    }
    filter "system:windows"
        postbuildcommands {
            '{COPY} "C:/Program Files/OpenSSL/bin/*.dll" "%{cfg.targetdir}"'
        }
    filter "configurations:Debug"
        symbols "on"
    filter "configurations:Release"
        optimize "on"