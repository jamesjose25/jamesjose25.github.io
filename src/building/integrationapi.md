# IntegrationAPI build

Building the IntegrationAPI is the same as building messages, just go to the IntegrationAPI directory and run `ant`:
```shell
$ cd ../IntegrationAPI
$ ant
```

The IntegrationAPI build takes longer to run than the messages build but shouldn't take more than a few minutes. It's also prone to infrequent unit test failures, so if the build fails just try rerunning it and it'll likely pass.

Once completed successfully you should see something like:
```
     [copy] Copying 1 file to /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/common/classes
     [copy] Copying 1 file to /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/common/classes/jms2.0
     [copy] Copying 5 files to /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/common/jackson/lib
    [mkdir] Created dir: /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/common/jnr/lib
     [copy] Copying 10 files to /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/common/jnr/lib
    [mkdir] Created dir: /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/common/webservices/prereqs
     [copy] Copying 31 files to /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/common/webservices/prereqs
     [echo] export prereqs to /Users/gb120268/localbuilds/S000/IntegrationAPI/prereqs so they can be picked up by Sx00/Tx00/ibx00.
     [echo] export create_jar_links scripts to /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/nonship so they can be used by toolkit and packaging builds.
    [mkdir] Created dir: /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/nonship
     [copy] Copying 2 files to /Users/gb120268/localbuilds/S000/IntegrationAPI/inst.images/nonship

static_analysis:
     [echo] Static analysis with SpotBugs.
     [echo] Static analysis with SpotBugs. (Not yet implemented.)

dist:
     [echo]  Built dist package.

BUILD SUCCESSFUL
Total time: 49 seconds
```

Once you've successfully built the IntegrationAPI, move on to:

* [WebUI (v10)](./building/webui.md)
* [Server core (v11)](./building/server_core.md)