include "openssl.lua"
newoption {
    trigger = "ssl",
    value = "LIBRARY",
    description = "Encryption library to use with libcurl",
    default = "openssl",
    allowed = {
        { "openssl", "OpenSSL" }
    }
}
-- this is mainly used for curl_config.h
newoption {
    trigger = "curlcmakeconfigdir",
    value = "DIR",
    description = "Directory to pass into CMake for configuration",
    default = curldir .. "/build"
}
local function config_libcurl(dir)
    print("configuring libcurl...")
    os.execute("cmake " .. dir .. " -B " .. _OPTIONS["curlcmakeconfigdir"])
    print("libcurl config finished!")
end
function unix_libcurl_links()
    filter "system:macosx or linux"
        links {
            "ssl",
            "crypto"
        }
    filter "system:macosx"
        libdirs {
            "/usr/local/opt/zlib/lib",
            "/usr/local/opt/libssh2/lib",
            "/usr/local/opt/openldap/lib"
        }
        links {
            "z",
            "ssh2",
            "ldap",
            "lber"
        }
end
project "curl"
    config_libcurl(curldir)
    kind "StaticLib"
    language "C"
    cdialect "C11"
    staticruntime "on"
    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")
    includedirs {
        (curldir .. "/include"),
        (curldir .. "/lib"),
        (_OPTIONS["curlcmakeconfigdir"] .. "/lib"),
    }
    defines {
        "BUILDING_LIBCURL",
        "CURL_STATICLIB",
        "HAVE_CONFIG_H",
    }
    files {
        (curldir .. "/lib/**.c"),
        (curldir .. "/lib/**.h"),
        (curldir .. "/include/**.h"),
        _SCRIPT
    }
    filter "system:windows"
        links {
            "ws2_32.lib",
            "crypt32.lib",
            "wldap32.lib",
        }
    filter "options:ssl=openssl" 
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
