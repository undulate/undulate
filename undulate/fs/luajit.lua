error("NYI: LuaJIT FS Interface")

local getcwd
do
	if (jit.os == "Windows") then
		ffi.cdef([[
			char *_getcwd(char *buf, size_t size);
		]])
		getcwd = ffi.C._getcwd
	else
		ffi.cdef([[
			char *getcwd(char *buf, size_t size);
		]])
		getcwd = ffi.C.getcwd
	end

	local cwd = ffi.new("char[1024]")
	if (getcwd(cwd, ffi.sizeof(cwd)) == null) then
		print("Couldn't get current directory!")
	end

	installDirectory = ffi.string(cwd)
end

local isDirectory
do

	ffi.cdef([[
		typedef struct stat;
		int stat(const char *pathname, struct stat *out);
	]])
end