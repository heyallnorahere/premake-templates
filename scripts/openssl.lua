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
end
local function asmbuildsettings()
    local format = ""
    if os.istarget("windows") then
        format = "win64"
    elseif os.istarget("linux") then
        format = "elf64"
    elseif os.istarget("macosx") then
        format = "macho64"
    end
    out = "%{cfg.objdir}/%{file.basename}"
    nasmcommand = 'nasm -f ' .. format .. ' -DNEAR -Ox'
    filter "files:**.pl"
        buildmessage "%{file.basename}.s"
        buildcommands {
            ('perl "%{file.relpath}" nasm "' .. out .. '.s"'),
            (nasmcommand .. ' -o "' .. out .. '.obj" "' .. out .. '.s"')
        }
        buildoutputs {
            (out .. ".obj")
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
    local extract_command = "tar -xvf " .. "openssl_source/source.tar.gz --skip-old-files -C " .. "openssl_source/"
    os.execute(extract_command)
    local command = ""
    if os.istarget("windows") then
        command = "perl Configure"
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
