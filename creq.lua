-- Safely requires C library with the correct extension (.dll, .so ...)

local src_dir = ""
if arg and arg[1] and #arg[1] > 0 then
   src_dir = arg[1]
end

local fallback_exe_dir = (...):match("(.-)[^/]*$")
local function get_exe_dir()
   if love and love.filesystem and love.filesystem.getSourceBaseDirectory then
      return love.filesystem.getSourceBaseDirectory()
   else
      return fallback_exe_dir
   end
end

local function filename(path)
   local unix_path = path:gsub("\\", "/"):gsub("%.", "/")
   return unix_path:match("^.+/(.+)$") or unix_path
end

local function dirname(path)
   local slash = path:match("\\") and "\\" or "/"

   -- Remove trailing slash
   if path:sub(-1, -1) == slash then
      path = path:sub(1, -2)
   end

   return path:match("(.*)" .. slash .. ".-")
end

local function is_windows()
   local os_name = os.getenv("OS") or ""
   return os_name:match("Windows") or package.config:sub(1,1) == '\\'
end

local function is_osx()
   if is_windows() then return false end

   local os_name = os.getenv("OS") or io.popen("uname"):read("*l")
   return os_name and os_name:match("Darwin") or false
end

local function is_linux()
   if is_windows() then return false end

   local os_name = os.getenv("OS") or io.popen("uname"):read("*l")
   if (os_name and os_name:match("Linux")) or
      os.getenv("XDG_CURRENT_DESKTOP") then
      return true
   else
      return false
   end
end

local function creq(path)
   local file_name = filename(path)
   local exe_dir = love.filesystem.getSourceBaseDirectory()
   local sep = is_windows() and "\\" or "/"

   local req_abs_path = exe_dir .. sep .. src_dir .. sep .. dirname(path)
   local req_rel_path = src_dir .. sep .. dirname(path)
   local old_cpath = package.cpath

   if is_windows() then
      package.cpath =
         req_abs_path .. "\\windows\\?.dll;" ..
         req_abs_path .. "\\windows\\?.lib;" ..
         req_rel_path .. "\\windows\\?.dll;" ..
         req_rel_path .. "\\windows\\?.lib;" ..
         "?.lib;" ..
         "?.dll;" .. package.cpath
   elseif is_osx() then
      package.cpath =
         -- When launched using directory (e.g. 'love .' or 'love src/')
         req_abs_path .. "/osx/?.dylib;" ..
         req_abs_path .. "/osx/?.so;" ..

         -- When launched as an .app or with .love file
         -- (e.g. 'open mygame.app' or 'love mygame.love')
         exe_dir .. "/?.dylib;" ..
         exe_dir .. "/?.so;" ..

         "?.dylib;" ..
         "?.so;" .. package.cpath
   elseif is_linux() then
      package.cpath =
         req_abs_path .. "/linux/?.so;" ..
         req_abs_path .. "/linux/?.a;" ..

         -- When launched using an appimage build
         exe_dir .. "/?.so;" ..
         exe_dir .. "/?.a;" ..

         "?.so;" ..
         "?.a;" .. package.cpath
   end

   local suc, ret = pcall(require, file_name)
   package.cpath = old_cpath

   if suc then return ret end
   print(
      string.format(
         "creq(\"%s\") failed in \"%s\": %s", path, req_abs_path, ret
      )
   )

   return nil
end

return creq
