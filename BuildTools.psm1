

function Invoke-MSBuildGeneral($msbuild, $dir, $sln, $buildName, $platform, [switch]$verbose) {
  $config = "$buildName|$platform"
  Write-Important "Building $sln"
  Write-Host "  build: $buildName"
  Write-Host "  platform: $platform"
  Write-Host "  directory: $dir"
  Write-Host "  devenv: $devenv11"
  Write-Host "  config: $config"

  Assert-Path -file $dir -role "working directory"
  Assert-Path -file $sln -role "solution file"
  Assert-Path -file $devenv11 -role "devenv"

  push-location
  cd $dir

  $verbosity = "minimal"
  if ($verbose) 
  {
      $verbosity = "detailed"
  }

  . $msbuild $sln /p:Configuration=$buildName /verbosity:"$verbosity" /nologo /fileLogger "/flp:verbosity=$verbosity;PerformanceSummary" /clp:PerformanceSummary

  pop-location  
}

function Invoke-MSBuild4($dir, $sln, $buildName, $platform, [switch]$verbose) {
  Invoke-MSBuildGeneral -msbuild "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" -dir $dir -sln $sln -buildName $buildName -platform $platform -verbose:$verbose
}

function Invoke-MSBuild4x64($dir, $sln, $buildName, $platform, [switch]$verbose) {
  Invoke-MSBuildGeneral -msbuild "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" -dir $dir -sln $sln -buildName $buildName -platform $platform -verbose:$verbose
}

######
# Gets latest versions from TFS into the specified directory
function Get-TfsSource($dir, [switch]$overwrite) {
  Assert-Path -file $tfexe -role "TFS Executable"
  push-location
  cd "$dir"
  if ($overwrite) {
    Write-Important "Updating and overwriting TFS files in '$dir'"
    & $tfexe "get" $dir "/noprompt" "/force" "/version:T" "/recursive"
  } else {
    Write-Important "Updating but not overwriting TFS files in '$dir'"
    & $tfexe "get" $dir "/noprompt" "/version:T" "/recursive"
  }
  pop-location
}

function Register-Dll($dll, [switch]$silent) { 
  if (Test-Path $dll) {
    Write-Important "Registering $dll library"
    if ($silent) {      
      & "regsvr32" "/s" $dll;
    } else {
      & "regsvr32" $dll;
    }
  } else {
    throw "Could not find $dll"
  }
}

function Register-Asm($dll) { 
  if (Test-Path $dll) {
    Write-Important "Registering $dll assembly"
    & "regasm" $dll "/codebase";
  } else {
    $msg ="Could not find $dll" 
    throw $msg
  }
}

function Register-Gac($dll) {
  if (Test-Path $dll) {
    Write-Important "Registering $dll to the GAC"
    & "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\gacutil.exe" "/i" $dll;
  } else {
    $msg = "Could not find $dll" 
    throw $msg    
  }
}

function Unregister-Gac($name) {
  Write-Important "Unregistering $name from the GAC"
  & "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\gacutil.exe" "/u" $name;
}

function Register-Gac4($dll) {
  if (Test-Path $dll) {
    Write-Important "Registering $dll to the GAC"
    & gacutil4 "/i" $dll;
  } else {
    $msg = "Could not find $dll" 
    throw $msg    
  }
}

function Unregister-Gac4($name) {
  Write-Important "Unregistering $name from the GAC"
  & gacutil4 "/u" $name;
}

use-path -file "$devenv11" -role "VS2012 executable"
use-path -file "$tfexe" -role "Team Foundation Server executable"

Export-ModuleMember Invoke-MSBuild4
Export-ModuleMember Invoke-MSBuild4x64
Export-ModuleMember Get-TfsSource