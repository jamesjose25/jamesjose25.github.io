I'm in the process of expanding and beautifying these instructions, but I'm not quite there yet. The final home of the book will be https://pages.github.ibm.com/William-Woodhead/IIB-Build-Setup/, please go there to get started and come back here when you're ready to start building the server core.

### WMB Build

Now that all the prerequisite components have been built, we are ready to build the runtime itself. To do this we need to navigate to the `WMB/src` folder and run the command `build`. You will want to run `build` with the flag `-jN` where `N` is the number of parallel threads you want to use in the build, which will depend on how many cores your CPU has. If you omit the `-j` flag then your build will be _very_ slow.

The WMB build can be broken down into three major steps: _Build_, _Install_, and _Test_:
1. _Build_: This step takes the longest as it does the heavily lifting of:
    * Copying header files to a common location
    * Compiling all our `.cpp` files into `.o` files
    * Linking the compiled `.o` files into libraries, executables and tests
2. _Install_: This step copies all the final outputs from the build step into their appropriate install locations. This includes all the libraries and executables that make up the product, as well as the tests and test resources that are used in the next phase.
3. _Test_: Finally we run all, or a subset of, our unit tests to validate that the build was successful. We can optionally run component and load tests at this point however many of these are not suitable for developer machines and must be run in the automated test pipeline.

For each of the three steps above, there is a corresponding `build` command:
1. `$ build -jN build_all`
2. `$ build -jN install_all`
3. `$ build -jN unit_test_all`

You can also issue all three commands at once to do everything, this is generally a better idea to ensure you don't miss a step.
```
$ build -jN build_all install_all unit_test_all
```

Other common flags you can pass to `build` are:
  * `-i` - This tells `build` to ignore errors, frequently used with `-k`
  * `-k` - This tells `build` to continue regardless of errors. When combined with `-i` this will attempt to do everything despite of any errors that may be encountered. This is what is used by the build pipeline so that you can see the full list of errors from your build instead of just the first ones.

A full rutime build, install, and test can take well over an hour on Linux and macOS and can take 2 or more hours on Windows.

#### Incremental build
Once you have a full runtime build you can do incremental builds to only build parts that you have changed during your testing and developement, to do this you need to navigate to folder where the `Makefile.ode` is that controls the component you have changed and run the three build steps again from that directory. Generally this directory is the same directory as the one where you made your changes.

For example, let's suppose I've made some changes to the Group Nodes and their unit tests. These are located at `WMB/src/DataFlowEngine/GroupNodes`. I simply need to navigate to this folder and run the build from there:
```
$ cd $BUILD_SANDBOX_DIR/WMB/src/DataFlowEngine/GroupNodes
$ build -jN build_all install_all unit_test_all
```
This will rebuild only the changes I have made, install the compiled libraries, and run the unit tests just for this component

**NB**: If you change a header file you may have to recompile all consumers of the header file as well so be careful! If your tests start randomly failing or abending for no apparent reason it is likely because you have a mismatch somewhere between two libraries. The best way out of such a situation is to clean up the build (discussed below) and redo the WMB build from scratch.

#### Cleaning up
There are a number of different ways to clean up parts of, or all, of the WMB build.

* `build clean_all` - This target will delete all the compiled outputs from the build (or the subdirectory you are currently in), but will not clean up the build system's own internal book keeping files and copied header files.
* `build clobber_all` - The same as `clean_all`, but will also clean up all the internal book keeping files and copied header files to give as close to clean state as possible.
* _Full delete_ - If you want to back to a completele clean slate and start the WMB build from scratch then you need to delete the three following directories:
    * `WMB/export` - This contains copies of all the header files and compiled libraries from the build
    * `WMB/inst.images` - This contains the build product, as well as all the locally built testing material, debug symbols and other utilities.
    * `WMB/obj` - This contains all the compiled `.o` files, libraries, executables, and build system book keeping files (`depend.mk`)

## Using your local build
Once you have successfully completed the WMB build you are ready to use your local build. Inside `WMB/inst.images/$CONTEXT/shipdata` is the final product, as it would be layed out in a customer's install. Like an official release, we need to source some environment variables before we can run the product, but we will not use `mqsiprofile`. Instead we use `setreloc` which provides us access to all the tests and tools available in `WMB/inst.images/$CONTEXT/NonShip`.

* On Linux and macOS:
    ```
    $ cd $BUILD_SANDBOX_DIR/WMB/src
    $ source ./setreloc.sh /var/mqsi $PWD/..
    ```
    Or equivalently
    ```
    $ cd $BUILD_SANDBOX_DIR/WMB/src
    $ source ./setreloc.sh
    ```
* On Windows:
    ```
    cd %BUILD_SANDBOX_DIR%/WMB/src
    .\setreloc.cmd C:\ProgramData\MQSI %BUILD_SANDBOX_DIR\WMB
    ```

Once you have source `setreloc` you should be able to run all the standard `mqsi*` commands:
```
$ mqsiservice -v
BIPmsgs  en_GB
  Console CCSID=1208, ICU CCSID=1208
  Default codepage=UTF-8, in ascii=UTF-8
  JAVA console codepage name=UTF-8
BIP8996I: Version:    100015
BIP8997I: Product:    IBM Integration Bus
BIP8998I: CMVC Level: S000-Lyymmdd.xyz
BIP8999I: Build Type: Development, 64 bit, amd64_macos_x
BIP8974I: Component: DFDL-C, Build ID: 20180710-2330, Version: 1.1.2.0 (1.1.2.0), Platform: macosx_x86 64-bit, Type: production
BIP8071I: Successful command completion.
```
and you will also be able to run varios development commands such as the unit, compnonent, and load test harnesses.
