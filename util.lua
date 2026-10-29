local util = {}

function util.cc(x) -- Check Capitalization
    if type(x)=="string" then
        if string.match(x,"%u") then
            return 1
        elseif string.match(x,"%l") then
            return -1
        else
            return 0
        end
    else
        return nil
    end
end

function util.gi(a,y,x) -- Get Index
    if type(a)=="table" then
        if a[y]==nil then
            return nil
        else
            if type(a[y])=="table" then
                return a[y][x]
            else
                return nil
            end
        end
    end
end

function util.ct(a) -- concat table of tables, for debugging
    out="{"
    for _, i in ipairs(a) do
        out=out.."{y="..i.y..",x="..i.x.."},"
    end
    out=out.."}"
    return out
end

function util.pi(a,b) -- py in
    for _, i in ipairs(b) do
        if a.x == i.x and a.y == i.y then
            return true
        end
    end
end

function util.jt(a,b)
    for i=1,#b do
        a[#a+1]=b[i]
    end
    return a
end

if jit.os == "Windows" then
    function util.clear()
        os.execute("cls")
    end
    -- Windows implementation using LuaJIT FFI
    local ffi = require("ffi")
    ffi.cdef[[
        int _getch(void);
    ]]
    function util.getch()
        local c = ffi.C._getch()
        if c == 0 or c == 224 then
            local c2 = ffi.C._getch()
            return nil, c, c2
        end
        return string.char(c)
    end
elseif jit.os == "Linux" or jit.os == "OSX" or jit.os == "BSD" then
    function util.clear()
        os.execute("clear")
    end
    function util.getch()
        -- Save the current terminal settings
        local pipe = assert(io.popen("stty -g", "r"))
        local old = pipe:read("*l")
        local closed = pipe:close()
        assert(old and closed, "Failed to save terminal settings")
        -- Enable single-key kut without echo
        local status = os.execute("stty -icanon -echo min 1 time 0")
        assert(status == 0 or status == true,"Failed to configure terminal")
        -- Read the key, catching Lua errors
        local ok, key = pcall(io.read, 1)
        -- Always attempt to restore the original settings
        local restore_status = os.execute("stty '" .. old .. "'")
        if not restore_status then
            error("Failed to restore terminal settings", 0)
        end
        if not ok then
            error(key, 0)
        end
        return key
    end
else
    error("Unsupported operating system: " .. jit.os)
end

function util.promo()
    print("1/Q:Queen 2/R:Rook 3/B:Bishop 4/N:Knight")
    while true do
        local k=util.getch()
        if k=="1" or k=="q" then
            return "q"
        elseif k=="2" or k=="r" then
            return "r"
        elseif k=="3" or k=="b" then
            return "b"
        elseif k=="4" or k=="n" then
            return "n"
        elseif k=="Q" or k=="\n" then
            return "q"
        end
    end
end

return util