include "../modules/openssl/openssl.lua"
local openssl = premake.extensions.openssl
local function sslprojsettings()
    kind "StaticLib"
    language "C"
    staticruntime "on"
    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")
    files {
        _SCRIPT
    }
    filter "system:windows"
        defines {
            "OPENSSL_CPUID_OBJ"
        }
    filter {}
end
local function asmbuildsettings()
    local asmformat = ""
    local asmcommand = ""
    if os.istarget("windows") then
        asmformat = "nasm"
        asmcommand = 'nasm -f win64 -DNEAR -Ox'
    elseif os.istarget("linux") then
        asmformat = "elf"
        asmcommand = "gcc -c"
    elseif os.istarget("macosx") then
        asmformat = "macosx"
        asmcommand = "cc -arch x86_64 -c"
    end
    local out = "%{cfg.objdir}/%{file.basename}"
    local perlexecutable = "perl"
    if os.istarget("macosx") then
        perlexecutable = "perl5"
    end
    local outext = ""
    if os.istarget("windows") then
        outext = "obj"
    else
        outext = "o"
    end
    filter "files:**.pl"
        buildmessage "%{file.basename}.s"
        buildcommands {
            (perlexecutable .. ' "%{file.relpath}" ' .. asmformat .. ' "' .. out .. '.s"'),
            (asmcommand .. ' -o "' .. out .. '.' .. outext .. '" "' .. out .. '.s"')
        }
        cleancommands {
            'rm "' .. out .. '.' .. outext .. '"'
        }
        buildoutputs {
            (out .. "." .. outext)
        }
end
newoption {
    trigger = "openssl-version",
    value = "VERSION",
    description = "The version of OpenSSL to pull",
    default = "1.0.2"
}
newoption {
    trigger = "openssl-revision",
    value = "REVISION",
    description = "The revision of the specified OpenSSL version to pull",
    default = "none"
}
newoption {
    trigger = "change-skip-old-files",
    description = "Use -k instead of --skip-old-files in tar command"
}
local osslversion = _OPTIONS["openssl-version"]
local osslrevision = _OPTIONS["openssl-revision"]
if osslrevision == "none" then
    osslrevision = ""
end
local openssl_config = {
    src_dir = path.getdirectory(_SCRIPT) .. "/openssl_source/openssl-" .. osslversion .. osslrevision .. "/",
    include_dir = path.getdirectory(_SCRIPT) .. "/openssl_include/",
    excluded_libs = {
        "jpake",
        "md2",
        "rc5",
        "store",
        "engine"
    }
}
local function pull_openssl()
    local openssl_url = "https://www.openssl.org/source/old/" .. osslversion .. "/openssl-" .. osslversion .. osslrevision .. ".tar.gz"
    local scriptdir = path.getdirectory(_SCRIPT)
    print("pulling openssl")
    os.execute("curl " .. openssl_url .. " -o " .. scriptdir .. "/openssl_source/source.tar.gz")
    local extract_command = "tar -xf " .. "openssl_source/source.tar.gz -C " .. "openssl_source/"
    if _OPTIONS["change-skip-old-files"] then
        extract_command = extract_command .. " -k"
    else
        extract_command = extract_command .. " --skip-old-files"
    end
    os.execute(extract_command)
    local command = ""
    if os.istarget("windows") then
        command = "perl Configure"
    else
        local arg = ""
        if os.istarget("macosx") then
            arg = " darwin64-x86_64-cc"
        end
        command = "./Configure" .. arg
    end
    os.execute("cd openssl_source/openssl-" .. osslversion .. osslrevision .. " && " .. command)
end
project "crypto"
    pull_openssl()
    openssl.copy_public_headers(openssl_config)    
    sslprojsettings()
    openssl.crypto_project(openssl_config)
    files {
        (openssl_config.src_dir .. "crypto/**-x86_64.pl"),
        (openssl_config.src_dir .. "crypto/x86_64*.pl")
    }
    excludes {
        (openssl_config.src_dir .. "crypto/mem_clr.c")
    }
    asmbuildsettings()
project "ssl"
    sslprojsettings()
    openssl.ssl_project(openssl_config)
    files {
        (openssl_config.src_dir .. "ssl/**-x86_64.pl")
    }
    asmbuildsettings()
