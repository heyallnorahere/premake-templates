workspace "test-workspace"
    architecture "x64"
    targetdir "bin"
    configurations {
        "Debug",
        "Release"
    }
    flags {
        "MultiProcessorCompile"
    }
    startproject "testproject"
    filter "system:windows"
        defines {
            "_CRT_SECURE_NO_WARNINGS"
        }
outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"
curldir = "../test/curl"
group "dependencies"
include "../scripts/curl.lua"
group ""
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
    unix_libcurl_links()
    filter "configurations:Debug"
        symbols "on"
    filter "configurations:Release"
        optimize "on"