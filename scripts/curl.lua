newoption {
    trigger = "encryptionlib",
    value = "LIBRARY",
    description = "Encryption library to use with libcurl",
    default = "openssl",
    allowed = {
        { "openssl", "OpenSSL" }
    }
}
project "curl"
    kind "StaticLib"
    language "C"
    cdialect "C11"
    staticruntime "on"
    targetdir ("bin/%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}/%{prj.name}")
    objdir ("bin-int/%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}/%{prj.name}")
    includedirs {
        (curldir .. "/include"),
        (curldir .. "/lib"),
    }
    defines {
        "BUILDING_LIBCURL"
    }
    files {
        (curldir .. "/lib/**.c"),
        (curldir .. "/lib/**.h"),
        (curldir .. "/include/**.h"),
    }
    filter { "system:windows", "options:encryptionlib=openssl" }
        links {
            "ws2_32.lib",
            "libssl.lib",
            "libcrypto.lib",
            "wldap32.lib",
            "crypt32.lib",
        }
        libdirs {
            "C:/Progam Files/OpenSSL/lib"
        }
        sysincludedirs {
            "C:/Program Files/OpenSSL/include"
        }
    filter "configurations:Debug"
        symbols "on"
    filter "configurations:Release"
        optimize "on"
