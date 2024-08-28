# creq

Allows you to make use of dynamic libraries (.dll, .so, .dylib, .a, .lib) in
Love2D in development, without having to build an executable. creq requires the
correct library from a list of directories.

## Setup

1. Download `creq.lua` and require it
2. Create a directory where you will place your dynamic libraries. For example
   `clibs/`.
3. Then create subdirectories in `clibs/` for each OS you wish to support. For
   example: `linux`, `osx` and `windows`.
4. Place your libraries in each of those subdirectoris. For example:
   `clibs/windows/mylib.dll`, `clibs/linux/mylib.so`, `clibs/osx/mylib.dylib`.
   This is what your directory structure will look like:
   ```
   mygame/
       main.lua
       creq.lua
       clibs/
           osx/
               mylib.dylib
           linux/
               mylib.so
           windows/
               mylib.dll
   ```
5. Call `creq("clibs/mylib")` to load your library. This will work both in
   development (when invoking `love mygame/`) and in production (when running
  `mygame.exe` or `mygame.app`...)
6. If your dynamic libraries themselves require other libraries, place those in
   the respective OS's directory and set the library loading path of your OS to
   point to that directory. In other words, you must point:
     - `LD_LIBRARY_PATH` on Linux to the `mygame/clibs/linux` directory
     - `DYLD_FALLBACK_LIBRARY_PATH` on OSX to the `mygame/clibs/osx` directory
     - `PATH` on Windows to the `mygame/clibs/windows` directory

   Doing this will allow the libraries required by creq, which themselves
   require other dynamic libraries, to find what they need. Look
   at the `example/` directory to see how it's done.

## Running the example

To run the example, stand at the root of the repository and run the appropriate
run script: `run.bat` on Windows or `run.sh` on OSX/Linux.

If you simply run `love example`, creq will load the dynamic libraries, *BUT* the
dynamic libraries loaded by those libraries won't be found, so we need to
specify a library loading path for each OS before invoking love. This is what
the scripts do.

**Setting the library loading path is only necessary if both are true:**
  1. The dynamic libraries you load want to load other libraries
  2. You are running in development, in other words, invoking `love` to run
     your app/game.

When you build an executable, you will be placing all your dynamic libraries
next to it anyway, so they will be found without setting the library loading
path on their own.

## How it works
This is what happens when we do `creq("luasteam.so")` on a Linux machine
in development:
  1. creq will call `require("clibs/linux/luasteam.so")`.
  2. The `luasteam.so` library itself will try to load
     `libsteam_api.so` from various directories all over the
     system, including those given in `LD_LIBRARY_PATH`.
  3. If the directory `example/clibs/linux` is given in `LD_LIBRARY_PATH`,
     `example/clibs/linux/libsteam_api.so` will be found and loaded.

When the same `creq("luasteam.so")` is called on a Linux machine from an
executable, we don't need to provide a `LD_LIBRARY_PATH` so long as we place the
libraries in the same directory, so creq will directly load those.


## License

The dynamic libraries in `example/clibs` belong to their respective owners and
are only here as an illustrative example, everything else is MIT licensed.
