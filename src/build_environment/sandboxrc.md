# `sandboxrc` file creation

There is one final piece of one-time setup that must be performed before you can start building the product, which is to create your `sandboxrc` file. This is a file needed by our historic build framework, ODE, the details of which I shall spare you from here.

Open up a terminal, navigate to your workspace sandbox and source your `build_env` script to set up the build environment. Now run the following command:

* **UNIX**:
    ```shell
    $ mkbb -dir "$PWD" -m $CONTEXT WMB
    ```
* **Windows**:
    ```bat
    > mkbb -dir "%CD%" -m %CONTEXT% WMB
    ```

This should create a file called `sandboxrc` in the root of your sandbox whose contents look something like this:

```
        # sandbox rc file created by mksb/mkbb

        # default sandbox
default WMB

        # base directories to sandboxes
base * /Users/gb120268/localbuilds/S1000

        # list of sandboxes
sb WMB

        # mksb/mkbb config specific
mksb -dir /Users/gb120268/localbuilds/S1000
mksb -m amd64_macos_x
mksb -tools b
mksb -obj b /
mksb -src b /
```

And that's it! You're ready to move on to building the product.