local rust = {}

local fs = require("luarocks.fs")
local cfg = require("luarocks.core.cfg")
local dir = require("luarocks.dir")
local path = require("luarocks.path")

function rust.run(rockspec)
   assert(rockspec:type() == "rockspec")

   if not fs.is_tool_available("cargo", "Cargo") then
      return nil, "'cargo' is not installed.\n" ..
                  "This rock is written in Rust: make sure you have a Rust\n" ..
                  "development environment installed and try again."
   end

   if not fs.execute("cargo build --release") then
      return nil, "Failed building."
   end
   
   if rockspec.build and rockspec.build.modules then
      local libdir = path.lib_dir(rockspec.name, rockspec.version)

      fs.make_dir(dir.dir_name(libdir))
      for _, mod in ipairs(rockspec.build.modules) do
         local src = dir.path("target", "release", "lib" .. mod .. "." .. cfg.lib_extension)
         local dst = dir.path(libdir, mod .. "." .. cfg.lib_extension)

         local ok, err = fs.copy(src, dst, "exec")
         if not ok then
            return nil, "Failed installing "..src.." in "..dst..": "..err
         end
      end
   end
   
   return true
end

return rust
