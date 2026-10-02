-- AI Build by Notascripter public launcher. No API keys or private pairing data.
-- Existing client caches and forgeai user journals are retained during upgrades.
local ROOT="https://raw.githubusercontent.com/datadaniklan/AI-Build-Notascripter/main/"
local MIN_VERSION={0,3,1}
local env=(type(getgenv)=="function" and getgenv()) or _G
if env.ForgeAILoaderBusy then warn("AI Build is already loading.");return end
env.ForgeAILoaderBusy=true
local ok,err=pcall(function()
    local send
    local candidates={request,http_request,type(syn)=="table" and syn.request,type(http)=="table" and http.request}
    for index=1,4 do if type(candidates[index])=="function" then send=candidates[index];break end end
    assert(send and type(loadstring)=="function","Your executor needs HTTP request and loadstring support.")
    assert(type(readfile)=="function" and type(writefile)=="function","Your executor needs workspace file access.")
    assert(type(bit32)=="table","Your executor needs bit32 support to verify releases.")
    if type(makefolder)=="function" then pcall(makefolder,"forgeai") end
    local httpService=game:GetService("HttpService")
    local nonce=tostring(httpService:GenerateGUID(false)):gsub("[^%w%-]","")
    assert(#nonce>=16 and #nonce<=80,"Could not create a fresh release request.")
    local function writeVerified(file,source)
        local hadPrevious,previous=pcall(readfile,file)
        local written=pcall(function()writefile(file,source);assert(readfile(file)==source)end)
        if not written then
            if hadPrevious and type(previous)=="string" then pcall(writefile,file,previous) end
            error("Could not verify "..file..". The running interface has not been replaced.",0)
        end
    end
    -- Repair the durable entrypoint even if a later metadata download fails.
    -- Each execution fetches the canonical launcher afresh; no version is pinned.
    local bootstrap=[=[-- AI Build canonical bootstrap; saved chats remain in forgeai.
local http=game:GetService("HttpService")
local nonce=tostring(http:GenerateGUID(false)):gsub("[^%w%-]","")
assert(#nonce>=16 and #nonce<=80,"Could not create a fresh launcher request.")
local source=game:HttpGet("https://raw.githubusercontent.com/datadaniklan/AI-Build-Notascripter/main/loader.lua?ai_build_refresh="..nonce)
assert(type(source)=="string" and #source>0 and #source<=128*1024,"Invalid AI Build launcher download.")
local run=loadstring(source,"AI Build launcher")
assert(run,"AI Build launcher did not compile.")
return run()
]=]
    writeVerified("forgeai/start.lua",bootstrap)
    local function get(file,limit,fresh)
        local requestOk,result=pcall(send,{Url=ROOT..file..(fresh and ("?ai_build_refresh="..nonce) or ""),Method="GET",Timeout=30,
            Headers={["Cache-Control"]="no-cache, no-store",Pragma="no-cache"}})
        assert(requestOk and type(result)=="table","GitHub did not respond. The current interface is retained.")
        local code=tonumber(result.StatusCode or result.Status or result.status_code) or 0
        assert(code==200,"AI Build download failed (HTTP "..code.."). The current interface is retained.")
        local body=result.Body or result.body
        assert(type(body)=="string" and #body>0 and #body<=limit,"Invalid or oversized download.")
        return body
    end
    local function decode(data,message)
        local valid,value=pcall(function()return httpService:JSONDecode(data)end)
        assert(valid and type(value)=="table",message)
        return value
    end
    local manifest=decode(get("manifest.json",4096,true),"Invalid release manifest JSON.")
    assert(manifest.format==1 and type(manifest.build)=="string" and #manifest.build==20 and manifest.build:match("^[a-f0-9]+$"),"Invalid release manifest.")
    assert(type(manifest.bytes)=="number" and manifest.bytes%1==0 and manifest.bytes>0 and manifest.bytes<=2*1024*1024,"Invalid release size.")
    assert(type(manifest.sha256)=="string" and #manifest.sha256==64 and manifest.sha256:match("^[a-f0-9]+$"),"Invalid release checksum.")
    local major,minor,patch
    if type(manifest.version)=="string" and #manifest.version<=32 then major,minor,patch=manifest.version:match("^(%d+)%.(%d+)%.(%d+)$") end
    assert(major and #major<=5 and #minor<=5 and #patch<=5,"Invalid release version.")
    local version={tonumber(major),tonumber(minor),tonumber(patch)}
    local newer=false
    for index=1,3 do
        assert(newer or version[index]>=MIN_VERSION[index],"The release metadata is stale. The current interface is retained; try the canonical launcher again.")
        if version[index]>MIN_VERSION[index] then newer=true end
    end
    local config=decode(get("config.json",4096,true),"Invalid service configuration JSON.")
    local apiBase=config.apiBase
    assert(type(apiBase)=="string" and #apiBase<=2048,"Invalid service configuration.")
    if apiBase~="" then
        local authority,path=apiBase:match("^https://([^/]+)(/?.*)$")
        assert(authority and path:match("^[%w/_%-]*$"),"Service configuration requires a valid HTTPS address.")
        local host,port=authority:match("^([%w%.%-]+):(%d+)$")
        if not host then host=authority;assert(not host:find(":",1,true),"Invalid service port.") end
        assert(#host<=253 and host:match("^[%w%.%-]+$") and not host:find("..",1,true)
            and not host:match("^[%.%-]") and not host:match("[%.%-]$"),"Invalid service hostname.")
        for label in host:gmatch("[^%.]+") do
            assert(#label<=63 and not label:match("^%-") and not label:match("%-$"),"Invalid service hostname.")
        end
        if port then local number=tonumber(port);assert(#port<=5 and number and number>=1 and number<=65535,"Invalid service port.") end
    end
    local source=get("dist/forgeai_"..manifest.build..".lua",2*1024*1024,false)
    assert(#source==manifest.bytes and source:match("^%-%- ForgeAI release ([a-f0-9]+)\n")==manifest.build,"Release does not match its manifest.")
    -- Portable SHA-256 verifies the actual downloaded bytes, independently of
    -- optional executor crypto APIs. HTTPS/GitHub remains the trust boundary.
    local function sha256(data)
        local K={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
            0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
            0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
            0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
            0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
            0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
            0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
            0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}
        local hash={0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}
        local rr,rs,bxor,band,bnot=bit32.rrotate,bit32.rshift,bit32.bxor,bit32.band,bit32.bnot
        local bits=#data*8
        local padded=data..string.char(128)..string.rep("\0",(55-#data)%64)..string.rep("\0",4)
            ..string.char(band(rs(bits,24),255),band(rs(bits,16),255),band(rs(bits,8),255),band(bits,255))
        local w={}
        for offset=1,#padded,64 do
            for i=1,16 do local a,b,c,d=padded:byte(offset+(i-1)*4,offset+(i-1)*4+3);w[i]=((a*256+b)*256+c)*256+d end
            for i=17,64 do
                local a,b=w[i-15],w[i-2]
                w[i]=(w[i-16]+bxor(rr(a,7),rr(a,18),rs(a,3))+w[i-7]+bxor(rr(b,17),rr(b,19),rs(b,10)))%4294967296
            end
            local a,b,c,d,e,f,g,h=table.unpack(hash)
            for i=1,64 do
                local t1=(h+bxor(rr(e,6),rr(e,11),rr(e,25))+bxor(band(e,f),band(bnot(e),g))+K[i]+w[i])%4294967296
                local t2=(bxor(rr(a,2),rr(a,13),rr(a,22))+bxor(band(a,b),band(a,c),band(b,c)))%4294967296
                h,g,f,e,d,c,b,a=g,f,e,(d+t1)%4294967296,c,b,a,(t1+t2)%4294967296
            end
            local values={a,b,c,d,e,f,g,h}
            for i=1,8 do hash[i]=(hash[i]+values[i])%4294967296 end
            if offset%16384==1 and offset>1 and task and type(task.wait)=="function" then task.wait() end
        end
        local hex={};for i=1,8 do hex[i]=string.format("%08x",hash[i]) end;return table.concat(hex)
    end
    assert(sha256(source)==manifest.sha256,"Release checksum mismatch. The current interface is retained.")
    local run=loadstring(source,"AI Build/"..manifest.build)
    assert(run,"AI Build did not compile. The current interface is retained.")
    writeVerified("forgeai/client_"..manifest.build..".lua",source)
    -- Only a fully checked release reaches its own client lifecycle/handoff.
    -- Never execute an older cache as a fallback after any download failure.
    run({apiBase=apiBase,releaseBuild=manifest.build,releaseVersion=manifest.version})
    env.ForgeAILastBuild=manifest.build
end)
env.ForgeAILoaderBusy=nil
if not ok then
    local message="AI Build: "..tostring(err):gsub("sk%-[%w_%-]+","[key removed]"):sub(1,600)
    warn(message)
    pcall(function()game:GetService("StarterGui"):SetCore("SendNotification",{Title="AI Build by Notascripter",Text=message:sub(1,200),Duration=12})end)
    error(message,0)
end
