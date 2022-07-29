# UNIX

## Build environment script

These instructions should apply to most UNIX like platforms but I have only tested them with Linux and macOS. Save a copy of the  [`build_env.sh`](./build_env.sh) script in the root of where you extracted your RTC sandbox.

At the top of the script is a small number of variables that you need to set manually, the rest are calculated automatically for you. Open the script in your text editor of choice and make the necessary changes.

Once you have saved your copy and made the relevant changes, use `chmod` to make the script executable:
```shell
$ chmod +x build_env.sh
```

__IMPORTANT__: Your shell _must_ be Bash for this script to work. You must switch to using Bash as your shell if you want to continue to follow these instructions. Always use a Bash shell when building ACE in a Unix environment.

## Using the `build_env.sh` script

Every time you want to start working on your sandbox you will need to _source_ this script into your shell. Navigate to the folder where you saved it and run the following command:
```shell
$ source ./build_env.sh
```
This will load all the environment variables into your current shell. To double check that it worked run the command `which build`. This should return something like this:
```shell
$ which build
/full/path/to/rtc/extract/MBBuildPreReqs/ode/5.0_b2/CONTEXT/build
```

## Final setup

After you have created your `build_env.sh` script, there is one final setup step that needs to be run. Head on over to the [`sandboxrc` file creation](./sandboxrc.md) step.