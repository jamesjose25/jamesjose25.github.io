# Messages build

Building the `messages` component is very simple. Open a _build environment_ terminal, go to the `messages` directory in your workspace, and run `ant`:
```shell
$ cd localbuilds/S1000/messages
$ ant
```
This build should be fairly quick and is incremental meaning it will only rebuild what is absolutely necessary when changes are made or accepted into this component. When it has finished you should see something that resembles the following:
```
zip:
     [echo] 2020-08-11 12:51:38> Build the zip files
      [zip] Building zip: /Users/gb120268/localbuilds/S000/messages/bin/messages.java.zip
      [zip] Building zip: /Users/gb120268/localbuilds/S000/messages/bin/messages.unix.zip
      [zip] Building zip: /Users/gb120268/localbuilds/S000/messages/bin/messages.windows.zip
      [zip] Building zip: /Users/gb120268/localbuilds/S000/messages/bin/messages.ebcdic.zip

refresh:

all:

BUILD SUCCESSFUL
Total time: 24 seconds
```

And that's it! You can now move on to the [IntegrationAPI](./integrationapi.md).