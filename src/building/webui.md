# WebUI build (v10)

The v10 WebUI is a separate compiled component that is also build using `ant` like the messages and the IntegrationAPI components. It is only needed at v10 as it has been replaced by a number of Node.js modules in v11 which are managed externally. The WebUI does not depend on the Messages or IntegrationAPI so you do not need to rebuild the WebUI if you rebuild either of these.

To build the WebUI, navigate to the `webui` folder and run ant:
```shell
$ cd ../webui
$ ant
```

If the build fails due to test errors then you have not correctly set the `SUPPRESS` environment variable isn't set or doesn't contain `webui_junit`. WebUI builds are slower than the messages and IntegrationAPI builds but thankfully you don't have to do them very often. A successful build should show something like the following:

```
launchJUnitSelenium:

launchJUnitLocale:

launchJUnit:

copyzip:
     [copy] Copying 1 file to /Users/gb120268/localbuilds/S1000/webui/buildOutput

makesymlinkwithvrmf.check:
     [echo] makesymlinkwithvrmf.run: ${makesymlinkwithvrmf.run}

makesymlinkwithvrmf:

marklatest:

dist:

BUILD SUCCESSFUL
Total time: 1 minute 32 seconds
```