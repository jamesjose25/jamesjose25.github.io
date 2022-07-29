function Invoke-BatchFile
{
    param([string]$Path, [string]$Parameters)

    $tempFile = [IO.Path]::GetTempFileName()

    ## Store the output of cmd.exe.  We also ask cmd.exe to output
    ## the environment table after the batch file completes
    cmd.exe /c " `"$Path`" $Parameters && set " > $tempFile

    ## Go through the environment variables in the temp file.
    ## For each of them, set the variable in our local environment.
    Get-Content $tempFile | Foreach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
        else {
            $_
        }
    }

    Remove-Item $tempFile
}

function Get-ConfigOption {
    param(
        [Parameter(mandatory=$true)]
        [string]
        $ConfigFile,
        [Parameter(mandatory=$true)]
        [string]
        $SettingName,
        [Parameter(mandatory=$true)]
        [string]
        $Key,
        [Parameter(mandatory=$false)]
        [string]
        $CommandLineValue
    )

    $ErrorMessage = "Failed to find setting for $($SettingName). Try setting -$($SettingName) on the command line, set the environment variable $($Key), or add '$($Key)=<value>' to '$($ConfigFile)"

    $result = $null
    $source = $null

    if ($CommandLineValue -eq [String]::EMPTY) {
        if (Test-Path "Env:$($Key)") {
            $envvar = Get-Item "Env:$($Key)" 
            $result = $envvar.Value
            $source = "environment variable $($KEY)"
        } elseif (-not (Test-Path "$ConfigFile")) {
            Write-Error $ErrorMessage
            $result = $null
            $source = $ErrorMessage
        } else {
            $regex_result = Select-String -Path $ConfigFile -Pattern "^$($Key)=(.*)$"
            if ($null -eq $regex_result) {
                $result = $null
                $source = $ErrorMessage
            } else {
                $result = $regex_result.Matches.Groups[1].Value
                $source = $ConfigFile
            }
        }
    } else {
        $result = $CommandLineValue
        $source = "command line"
    }

    if ($null -eq $result) {
        Write-Error $ErrorMessage
        return $null
    } else {
        Write-Host "  -> '$($Key)=$($result)' - From $($source)"
        return $result
    }
}

function Initialize-BuildEnvironment {
    param(
        [Parameter(mandatory=$true)]
        [string]
        $Sandbox,

        [Parameter(mandatory=$false)]
        [string]
        $MQ = $null,

        [Parameter(mandatory=$false)]
        [string]
        $Java = $null,

        [Parameter(mandatory=$false)]
        [string]
        $Perl = $null,

        [Parameter(mandatory=$false)]
        [string]
        $BTYPE = $null,

        [Parameter(mandatory=$false)]
        [string]
        $CompilerVersion = $null
    )

    Write-Host "Opening sandbox $($Sandbox)"

    if (-not ($Env:MQ_HOME = Get-ConfigOption "$($Sandbox)\sandbox.config" "MQ" "MQ_HOME" $MQ)) {
        return
    }
    if (-not ($Env:JAVA_HOME = Get-ConfigOption "$($Sandbox)\sandbox.config" "Java" "JAVA_HOME" $Java)) {
        return
    }
    if (-not ($Env:PERL_HOME = Get-ConfigOption "$($Sandbox)\sandbox.config" "Perl" "PERL_HOME" $Perl)) {
        return
    }
    if (-not ($Env:BTYPE = Get-ConfigOption "$($Sandbox)\sandbox.config" "BTYPE" "BTYPE" $BTYPE)) {
        return
    }
    if (-not ($CompilerVersion = Get-ConfigOption "$($Sandbox)\sandbox.config" "Compiler Version" "BUILD_MSVC_VERSION" $CompilerVersion)) {
        return
    }

    if (Test-Path "$($Sandbox)\sandbox.config.new") {
        Remove-Item "$($Sandbox)\sandbox.config.new" | out-null
    }
    New-Item -Path "$($Sandbox)\sandbox.config.new" -ItemType File | out-null
    Add-Content "$($Sandbox)\sandbox.config.new" "MQ_HOME=$($Env:MQ_HOME)`n"
    Add-Content "$($Sandbox)\sandbox.config.new" "JAVA_HOME=$($Env:JAVA_HOME)`n"
    Add-Content "$($Sandbox)\sandbox.config.new" "PERL_HOME=$($Env:PERL_HOME)`n"
    Add-Content "$($Sandbox)\sandbox.config.new" "BTYPE=$($Env:BTYPE)`n"
    Add-Content "$($Sandbox)\sandbox.config.new" "BUILD_MSVC_VERSION=$($CompilerVersion)`n"
    Move-Item -Force -Path "$($Sandbox)\sandbox.config.new" -Destination "$($Sandbox)\sandbox.config"

    $Env:CONTEXT = 'amd64_nt_4'
    $Env:MACHINE = 'amd64_nt_4'
    $Env:PACKAGEBASE = "$($Sandbox)\WMB\inst.images\$($Context)"
    $Env:SANDBOXRC = "$($Sandbox)\sandboxrc.$($Context)"
    $Env:SUPPRESS = "webui_junit"

    $BuildPreReqs = "$($Sandbox)\MBBuildPreReqs"
    $OdePath = "$($BuildPreReqs)\ode\5.0_b2\amd64_nt_4"
    $AntBin = "$($BuildPreReqs)\ant\apache-ant-1.9.4\bin"
    $BldTools = "$($BuildPreReqs)\bldtools\amd64_nt_4"

    $Env:PATH = "$($OdePath);$($AntBin);$($Env:JAVA_HOME)\bin;$($Env:PERL_HOME)\bin;$($BldTools);$($Env:PATH)"
    $Env:INCLUDE = "$($Env:MQ_HOME)\tools\c\include;$($Env:MQ_HOME)\tools\cplus\include;$($Env:JAVA_HOME)\include"
    $Env:LIB = $null
    $Env:LIBPATH = $null

    $Env:ERRORLEVEL = $null
    if ($CompilerVersion -eq "2013") {
        Invoke-BatchFile "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" "amd64"
    } elseif ($CompilerVersion -eq "2017") {
        Invoke-BatchFile "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" "amd64"
    } else {
        Write-Error "Unknown compiler version selected: '$($CompilerVersion)'. Supported versions are 2013 and 2017."
        return
    }

    cd "$($Sandbox)\WMB\src"
}

Export-ModuleMember -Function Initialize-BuildEnvironment
