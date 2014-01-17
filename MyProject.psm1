$projectSrc = "$src\Path\To\Source"
$projectSln = "$projectSrc\MyProject.sln"

function Get-MyProjectSource() {
    Get-TfsSource $projectSrc
}

function Invoke-MyProjectBuild([switch]$verbose) {
    Write-Important "Building MyProject"
    Invoke-MSBuild4x64 -dir $projectSrc -sln $projectSln -buildName "DEBUG" -platform "Any CPU" -verbose:$verbose
}

function Delete-MyProjectDatabase() {
    $local = "sqlserver:\sql\$machineName\default\databases"
    $dbName = "MyProjectDbName"
    Write-Important "Attempting to delete $dbName in '$local'"
    push-location
    cd $local
    if (Test-Path $dbName)
    {
        iisreset;
        remove-item $dbName
        Write-Host "Deleted $dbName"
    } else {
        Write-Host "Could not find $dbName"
    }

    pop-location
}

function Update-Database($solutionDir, $projectBinDir, $assemblyName, $appConfigFile)
{
    $efMigrateExe = "$solutionDir\packages\EntityFramework.6.0.2\tools\migrate.exe"
    Write-Important "Updating Entity Framework Database"
    Write-Host "    Migrate.exe at $efMigrateExe"
    Write-Host "    EF project binary at $projectBinDir"
    Write-Host "    EF config at $appConfigFile"
    . "$efMigrateExe" "$assemblyName" /startupConfigurationFile="$appConfigFile" /startupDirectory="$projectBinDir"
}

function Update-MyProjectDatabase() {
    Update-Database -solutionDir "$projectSrc" -projectBinDir "$projectSrc\AIMyProject.EntityFramework\bin\Debug" -appConfigFile "$projectSrc\MyProjectWebApp\Web.config" -assemblyName "MyProject.EntityFramework.dll"
}

function Reset-MyProjectDatabase() {
    Delete-MyProjectDatabase;    
    Update-MyProjectDatabase;
}

function Browse-MyProject() {
    start "Http://localhost/MyProjectSite"
}

function Build-All() {
    $ErrorActionPreference = "Stop"
    Get-MyProjectSource;
    Invoke-MyProjectBuild;
    Reset-MyProjectDatabase;
    iisreset;
    Browse-MyProject;
}
