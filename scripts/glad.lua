project "glad"
    kind "StaticLib"
    language "C"
    staticruntime "on"
    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")
    files {
        (gladdir .. "/src/glad.c"),
        (gladdir .. "/include/glad/glad.h")
    }
    sysincludedirs {
        (gladdir .. "/include")
    }
    filter "configurations:Debug"
        symbols "on"
    filter "configurations:Release"
        optimize "on"