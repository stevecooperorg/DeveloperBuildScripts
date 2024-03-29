#
# Core.psm1
#

#####
# Warns if the file does not exist
function Use-Path($file, $role) {
  if (Test-Path -Path $file)
  {
    # the file exists; fine
    # Write-Host "Found $file" -foregroundcolor green
  } else {
    Write-Host "Could not find $file ($role)" -foregroundcolor yellow
  }
}


function Get-ScriptDirectory {
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

#####
# check for the existence of a file, or throws
function Assert-Path($file, $role) {
  if ($file) { # a non-null file
    if (Test-Path $file) {
      # fine!
    } else {
      throw "required '$file' ($role) to continue"
    }
  } else {
    Write-Error "No file passed for role $role"
    throw "done"
  }
}


function Write-Important($message) {
  Write-Host "** $message **" -Foregroundcolor DarkYellow
}

function Get-LocalAppDirectory {
  return [environment]::getfolderpath("LocalApplicationData");
}


function Set-Environment($name, $value) { 
  [Environment]::SetEnvironmentVariable($name, $value, "User")
}

function Get-Environment($name) {
  return [environment]::GetEnvironmentVariable($name,"User")
}

function Get-Functions() {
   Get-ChildItem Function: | where { $_.Name -match '-'} | sort-object -property Name | select Name,Definition | format-wide -autosize #format-table -autosize
}

<#

.SYNOPSIS

Sets the file modification time; a file 'touch'

#>
function Set-FileTime{
  param(
    [string[]]$paths,
    [bool]$only_modification = $false,
    [bool]$only_access = $false
  );

  begin {
    function updateFileSystemInfo([System.IO.FileSystemInfo]$fsInfo) {
      $datetime = get-date
      if ( $only_access )
      {
         $fsInfo.LastAccessTime = $datetime
      }
      elseif ( $only_modification )
      {
         $fsInfo.LastWriteTime = $datetime
      }
      else
      {
         $fsInfo.CreationTime = $datetime
         $fsInfo.LastWriteTime = $datetime
         $fsInfo.LastAccessTime = $datetime
       }
    }
   
    function touchExistingFile($arg) {
      if ($arg -is [System.IO.FileSystemInfo]) {
        updateFileSystemInfo($arg)
      }
      else {
        $resolvedPaths = resolve-path $arg
        foreach ($rpath in $resolvedPaths) {
          if (test-path -type Container $rpath) {
            $fsInfo = new-object System.IO.DirectoryInfo($rpath)
          }
          else {
            $fsInfo = new-object System.IO.FileInfo($rpath)
          }
          updateFileSystemInfo($fsInfo)
        }
      }
    }
   
    function touchNewFile([string]$path) {
      #$null > $path
      Set-Content -Path $path -value $null;
    }
  }
 
  process {
    if ($_) {
      if (test-path $_) {
        touchExistingFile($_)
      }
      else {
        touchNewFile($_)
      }
    }
  }
 
  end {
    if ($paths) {
      foreach ($path in $paths) {
        if (test-path $path) {
          touchExistingFile($path)
        }
        else {
          touchNewFile($path)
        }
      }
    }
  }
}