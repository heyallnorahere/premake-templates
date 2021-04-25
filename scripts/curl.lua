newoption {
    trigger = "ssl",
    value = "LIBRARY",
    description = "Encryption library to use with libcurl",
    default = "openssl",
    allowed = {
        { "openssl", "OpenSSL" }
    }
}
include "openssl.lua"
project "curl"
    kind "StaticLib"
    language "C"
    cdialect "C11"
    staticruntime "on"
    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")
    includedirs {
        (curldir .. "/include"),
        (curldir .. "/lib"),
    }
    defines {
        "BUILDING_LIBCURL",
        "CURL_STATICLIB",
    }
    files {
        (curldir .. "/lib/**.c"),
        (curldir .. "/lib/**.h"),
        (curldir .. "/include/**.h"),
        _SCRIPT
    }
    links {
        "ws2_32.lib",
        "crypt32.lib",
        "wldap32.lib",
    }
    filter { "system:windows", "options:ssl=openssl" }
        links {
            "ssl",
            "crypto"
        }
        sysincludedirs {
            "openssl_include"
        }
        defines {
            "USE_OPENSSL",
            "OPENSSL_NO_ENGINE"
        }
    filter "configurations:Debug"
        symbols "on"
    filter "configurations:Release"
        optimize "on"
