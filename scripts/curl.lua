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
    }
    links {
        "ws2_32.lib",
        "crypt32.lib",
        "wldap32.lib",
    }
    filter { "system:windows", "options:encryptionlib=openssl" }
        links {
            (os.findlib("libssl.lib") or "C:/Program Files/OpenSSL/lib/libssl.lib"),
            (os.findlib("libcrypto.lib") or "C:/Program Files/OpenSSL/lib/libcrypto.lib")
        }
        sysincludedirs {
            (os.findheader("ssl.h") or "C:/Program Files/OpenSSL/include")
        }
        defines {
            "USE_OPENSSL"
        }
    filter "configurations:Debug"
        symbols "on"
    filter "configurations:Release"
        optimize "on"
