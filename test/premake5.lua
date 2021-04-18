workspacename = "test-workspace"
startprojectname = "test-project"
include "../scripts/workspace.lua"
outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"
project "testproject"
    location "testproject"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++17"
    staticruntime "on"
    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")
    files {
        "%{prj.name}/src/**.cpp",
        "%{prj.name}/src/**.h",
    }
    filter "configurations:Debug"
        symbols "on"
    filter "configurations:Release"
        optimize "on"