#
# Load user-specific configurations, such as source code root, locations of devenv, etc.
#
. "C:\Users\my.username\Documents\WindowsPowerShell\config.ps1"

#
# Load modules
# 
import-module "C:\Users\my.username\Documents\WindowsPowerShell\Core.psm1"
import-module "C:\Users\my.username\Documents\WindowsPowerShell\BuildTools.psm1"
import-module "C:\Users\my.username\Documents\WindowsPowerShell\MyProject.psm1"
import-module "C:\Users\my.username\Documents\WindowsPowerShell\sql.psm1"

Write-Host "Profile Loaded" -ForegroundColor green

set-alias upr Get-MyProjectSource
set-alias bpr Invoke-MyProjectBuild
set-alias fns Get-Functions
set-alias vbs get-verb | sort-object -property verb | format-table -property verb
set-alias touch set-filetime
