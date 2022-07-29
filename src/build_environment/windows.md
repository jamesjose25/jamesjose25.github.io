# Windows

These instructions should apply to all supported versions of Windows but I have only tested them on Windows 10 and Windows Server 2019. Save a copy of the [`build_env.cmd`](./build_env.cmd) script in the root of where you extracted your RTC sandbox.

At the top of the script is a small number of variables that you need to set manually, the rest are calculated automatically for you. Open the script in your text editor of choice and make the necessary changes.

## Using the `build_env.cmd` script

Every time you want to start working on your sandbox you must first run the `build_env.cmd` script. Things to bear in mind:

* You **must** run this from a clean command prompt. Do not run it twice in one shell, and do not run it from a _Visual Studio Developer Command Prompt_.
* You cannot use this script from a PowerShell prompt. A similar script can be written for PowerShell, but I have not published it here.

Running the script is as simple as running `.\build_env.cmd`. You can confirm whether it worked by running `where build`:

```
> where build
C:\S1000\MBBuildPreReqs\ode\5.0_b2\amd64_nt_4\build.exe
```

## Final setup

After you have created your `build_env.cmd` script, there is one final setup step that needs to be run. Head on over to the [`sandboxrc` file creation](./sandboxrc.md) step.