# creq

Allows you to make use of dynamic libraries (.dll, .so, .dylib, .a, .lib) in an
organized manner for multiple OSes both with an executable and in development.
creq requires the correct library from a list of directories.

**The problem:**

For example, you want to use a library for your game which has separate versions:
  - for Windows (`library.dll`)
  - for Linux (`library.so`)
  - and for OSX (`library.so` or `library.dylib`)

You can already see the issue - you have to rename each library based on the OS and
check the running OS at runtime to pick the correct one. You can't just
`require("library")` in your code - on Windows it will work, but on Linux/OSX
you'd need to use different names to tell them apart.

Moreover, when you build an executable, you can only `require("library")` if the
library is in the root of the source tree. If it's in a different location, like
`libs/`, then `require("libs/library")` won't work from the executable, even
though it will work in development. So now you need to do more checks for
executable/development environment in addition to OS checks and then load it
either from `libs/` or from `./` (the directory of the executable).

And before you know it, you have all this spaghetti code just for loading a
library. `creq` handles all this ugliness for you and imposes a simple and
strict organization scheme so you don't get the libraries mixed up.

`creq` also illustrates a working example of how to package Love2D games for
multiple OSes without going insane.

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

    *`creq.lua` can be placed anywhere outside the `clibs/` directory in your project. It doesn't matter*.
   
5. Call `creq("clibs/mylib")` to load your library. This will work both in
   development (when invoking `love mygame/`) and in production (when running
  `mygame.exe` or `mygame.app`...)
6. If your dynamic libraries themselves require other libraries, place those in
   the respective OS's directory (See "extras" section below) and set the
   library loading path of your OS to point to that directory. In other words,
   you must point:
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
  3. If the directory `example/clibs/linux` is given in `LD_LIBRARY_PATH`, then
     `example/clibs/linux/libsteam_api.so` will be found and loaded.

When the same `creq("luasteam.so")` is called on a Linux machine from an
executable, we don't need to provide a `LD_LIBRARY_PATH` so long as we place the
libraries in the same directory, so creq will directly load those.

## Extras

When Love2D looks for dynamic libraries from an executable, it looks at
different directories for each OS. When you do `require("mylib")` or
`creq("clibs/mylib")` from a packaged game, this is where it looks:
  - on Windows, right next to the running .exe file
  - on OSX, inside the .app/ directory in `mygame.app/Contents/Resources/.`
  - on Linux, I'm not sure, but I do `LD_LIBRARY_PATH="./:$LD_LIBRARY_PATH"`
    inside the package from a launch script, which makes it look inside that
    directory so I place all the libraries there.


## License

The dynamic libraries in `example/clibs` belong to their respective owners and
are only here as an illustrative example. Everything else is MIT licensed.
