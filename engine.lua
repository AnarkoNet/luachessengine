-- engine.lua
-- Minimal UCI engine connector for LuaJIT on Linux/WSL.
-- Requires a UCI-compatible chess engine executable.

local ffi = require("ffi")

ffi.cdef[[
typedef int pid_t;
int pipe(int pipefd[2]);
pid_t fork(void);
int dup2(int oldfd, int newfd);
int close(int fd);
int execvp(const char *file, char *const argv[]);
long read(int fd, void *buf, unsigned long count);
long write(int fd, const void *buf, unsigned long count);
pid_t waitpid(pid_t pid, int *status, int options);
int kill(pid_t pid, int sig);
int open(const char *pathname, int flags, ...);
void _exit(int status);
]]

local C = ffi.C
local O_RDONLY = 0
local O_WRONLY = 1
local SIGTERM = 15

local engine = {}
local child, input_fd, output_fd
local read_buffer = ""

local function write_all(fd, data)
    local offset = 0
    while offset < #data do
        local chunk = data:sub(offset + 1)
        local n = C.write(fd, chunk, #chunk)
        if n <= 0 then
            error("Failed writing to chess engine.")
        end
        offset = offset + tonumber(n)
    end
end

local function read_line()
    while true do
        local newline = read_buffer:find("\n", 1, true)
        if newline then
            local line = read_buffer:sub(1, newline - 1)
            read_buffer = read_buffer:sub(newline + 1)
            return line:gsub("\r$", "")
        end

        local buf = ffi.new("char[1]")
        local n = C.read(output_fd, buf, 1)
        if n <= 0 then
            error("Chess engine closed its output.")
        end
        read_buffer = read_buffer .. ffi.string(buf, 1)
    end
end

local function send(command)
    write_all(input_fd, command .. "\n")
end

local function wait_for(token)
    while true do
        local line = read_line()
        if line == token then return end
    end
end

function engine.START(path)
    if child then
        error("Engine is already running.")
    end
    path = path or "./engine"

    local to_child = ffi.new("int[2]")
    local from_child = ffi.new("int[2]")

    if C.pipe(to_child) ~= 0 or C.pipe(from_child) ~= 0 then
        error("Could not create pipes for chess engine.")
    end

    child = C.fork()
    if child < 0 then
        error("Could not start chess engine process.")
    elseif child == 0 then
        C.dup2(to_child[0], 0)
        C.dup2(from_child[1], 1)

        local devnull = C.open("/dev/null", O_WRONLY)
        if devnull >= 0 then C.dup2(devnull, 2) end

        C.close(to_child[0])
        C.close(to_child[1])
        C.close(from_child[0])
        C.close(from_child[1])
        if devnull > 2 then C.close(devnull) end

        local argv = ffi.new("char *[2]")
        argv[0] = path
        argv[1] = nil
        C.execvp(path, argv)
        C._exit(127)
    end

    C.close(to_child[0])
    C.close(from_child[1])
    input_fd = to_child[1]
    output_fd = from_child[0]
    read_buffer = ""

    send("uci")
    wait_for("uciok")
    send("isready")
    wait_for("readyok")

    return true
end

-- position must be a UCI command, e.g.
-- "position startpos moves e2e4 e7e5"
-- or "position fen <FEN>"
function engine.BESTMOVE(position, depth)
    if not child then error("Call engine.START() first.") end
    if type(position) ~= "string" or not position:match("^position%s") then
        error("Expected a UCI position command.")
    end

    depth = depth or 8
    send(position)
    send("go depth " .. tostring(math.max(1, math.floor(depth))))

    while true do
        local line = read_line()
        local move = line:match("^bestmove%s+(%S+)")
        if move then
            if move == "(none)" or move == "0000" then
                return nil
            end

            local from_file, from_rank, to_file, to_rank, promotion =
                move:match("^([a-h])([1-8])([a-h])([1-8])([qrbn]?)$")

            if not from_file then
                return move
            end

            local pos = {
                x = from_file:byte() - 96,
                y = 9 - tonumber(from_rank)
            }
            local mov = {
                x = to_file:byte() - 96,
                y = 9 - tonumber(to_rank)
            }

            return {
                uci = move,
                pos = pos,
                mov = mov,
                promotion = promotion ~= "" and promotion or nil
            }
        end
    end
end

function engine.STOP()
    if not child then return end

    pcall(send, "quit")
    C.close(input_fd)
    C.close(output_fd)

    local status = ffi.new("int[1]")
    C.waitpid(child, status, 0)

    child = nil
    input_fd = nil
    output_fd = nil
    read_buffer = ""
end

return engine
