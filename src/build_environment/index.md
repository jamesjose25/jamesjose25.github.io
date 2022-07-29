# Build environment

There are a number of environment variables that must be configured correctly before you can start with your local build. You will need to set these every time you want to work with your localbuild so I recommend you save them in a script.

## Build type

IIB and ACE can be built in one of two different modes: _production_ and _development_ (or _debug_). The choice of build type is controlled by the `BTYPE` environment variable which can either be `P` or `D` (the default).

The major differences between P and D builds are:

* **Build times**: Production builds take much longer to build than development builds, as such you will probably want to use a development build for your local build unless you specifically need a production build.
* **Performance**: Prodcution builds run much faster than debug builds, as such you will want a production build if you need to do any performance testing.
* **Debugging**: Development builds can be run under a debugger with ease, whereas it is very difficult to get meaningful results with a debugger attached to a production build.
* **Extra runtime validation**: Development builds enable extra runtime checks which would be too much of a performance hit to customers. This includes useful features such as the Address Sanitizer (on macOS).

Generally speaking you should chose a **development** build unless you specifically need the extra performance provided by a production build.

Once you have chosen a build type for your local build you will not be able to change it without fully rebuilding the product.

## Platform specific instructions

* [UNIX platforms](./unix.md)
* [Windows](./windows.md)