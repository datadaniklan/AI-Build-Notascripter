-- AI Build by Notascripter public launcher. No API keys or private pairing data.
-- ForgeAI globals, bundle identifiers and forgeai storage remain compatible.
local ROOT="https://raw.githubusercontent.com/datadaniklan/AI-Build-Notascripter/main/"
local env=(type(getgenv)=="function" and getgenv()) or _G
if env.ForgeAILoaderBusy then warn("AI Build is already loading.");return end
env.ForgeAILoaderBusy=true
local ok,err=pcall(function()
    local send
    local candidates={request,http_request,type(syn)=="table" and syn.request,type(http)=="table" and http.request}
    for index=1,4 do if type(candidates[index])=="function" then send=candidates[index];break end end
    assert(send and type(loadstring)=="function","Your executor needs HTTP request and loadstring support.")
    assert(type(readfile)=="function" and type(writefile)=="function","Your executor needs workspace file access.")
    if type(makefolder)=="function" then pcall(makefolder,"forgeai") end
    local probe="AI Build file check";writefile("forgeai/workspace-check.txt",probe)
    assert(readfile("forgeai/workspace-check.txt")==probe,"AI Build cannot verify workspace writes.")
    if type(delfile)=="function" then pcall(delfile,"forgeai/workspace-check.txt") end
    local function get(file,limit)
        local result=send({Url=ROOT..file,Method="GET",Timeout=30})
        assert(type(result)=="table","GitHub did not respond.")
        local code=tonumber(result.StatusCode or result.Status or result.status_code) or 0
        assert(code==200,"AI Build download failed (HTTP "..code..").")
        local body=result.Body or result.body
        assert(type(body)=="string" and #body>0 and #body<=limit,"Invalid or oversized download.")
        return body
    end
    local httpService=game:GetService("HttpService")
    local manifest=httpService:JSONDecode(get("manifest.json",4096))
    assert(manifest.format==1 and type(manifest.build)=="string" and #manifest.build==20 and manifest.build:match("^[a-f0-9]+$"),"Invalid release manifest.")
    assert(type(manifest.bytes)=="number" and manifest.bytes>0 and manifest.bytes<=2*1024*1024,"Invalid release size.")
    local config=httpService:JSONDecode(get("config.json",4096))
    assert(type(config)=="table" and type(config.apiBase)=="string","Invalid service configuration.")
    local source=get("dist/forgeai_"..manifest.build..".lua",2*1024*1024)
    assert(#source==manifest.bytes and source:match("^%-%- ForgeAI release ([a-f0-9]+)\n")==manifest.build,"Release does not match its manifest.")
    local run,compileError=loadstring(source,"AI Build/"..manifest.build)
    assert(run,"AI Build did not compile: "..tostring(compileError))
    local cache="forgeai/client_"..manifest.build..".lua"
    writefile(cache,source);assert(readfile(cache)==source,"Could not verify the client cache.")
    writefile("forgeai/start.lua",'loadstring(game:HttpGet("'..ROOT..'loader.lua"))()\n')
    run(config)
end)
env.ForgeAILoaderBusy=nil
if not ok then
    local message="AI Build: "..tostring(err):gsub("sk%-[%w_%-]+","[key removed]"):sub(1,600)
    warn(message)
    pcall(function()game:GetService("StarterGui"):SetCore("SendNotification",{Title="AI Build by Notascripter",Text=message:sub(1,200),Duration=12})end)
    error(message,0)
end
