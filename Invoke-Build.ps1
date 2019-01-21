function Confirm-AdministratorContext
{
    $administrator = [Security.Principal.WindowsBuiltInRole] "Administrator"
    $identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $identity.IsInRole($administrator)
}

class InstallBuildDependencies {

  [array]ModuleInstaller($moduleNames,$command) {
    $modulesToBeInstalled = @()
    For ($i = 0; $i -lt $moduleNames.count; $i++)
    {
      $commandString = @('Get-Command', $command, $moduleNames[$i]) -join ' '
      if (-not (&([scriptblock]::create($commandString)))) {
        $modulesToBeInstalled += $moduleNames[$i]
      }
    }
    return $modulesToBeInstalled
  }
}

class PSModuleInstaller:InstallBuildDependencies {
  [void]InstallPowerShellModules($moduleNames) {
    Foreach ($moduleName in $moduleNames)
    {
      Write-Host "**$moduleName"
      Install-Module -Name $moduleName -Force -SkipPublisherCheck
    }
  }
}

class ChocolateyPackageInstaller:InstallBuildDependencies {
  [void]InstallChocolateyPackages($packageNames) {
    Foreach ($packageName in $packageNames)
    {
      Write-Host "**$packageName"
      cinst --no-progress -y --force $packageName
    }
  }
}

  class NodePackageInstaller:InstallBuildDependencies {
    [void]InstallNodePackages($packageNames) {
      Foreach ($packageName in $packageNames)
      {
        Write-Host "**$packageName"
        npm install $packageName
      }
    }
}

function Install-BuildPrerequisite
{
    Write-Output "Installing build prerequisites -- note: requires admin privileges if any are missing"

    Write-Output "**NuGet package provider"
    if (-not (Get-PackageProvider | Where-Object {$_.Name -eq "NuGet"}))
    {
        Install-PackageProvider -Name "NuGet" -Force
    }

    Write-Output "**Chocolatey package manager"
    if (-not (Get-Command choco -ErrorAction SilentlyContinue))
    {
        Invoke-TrustedExpression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

function Invoke-TrustedExpression
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "", Scope="Function", Target="Invoke-TrustedExpression")]
    param([string]$trustedExpression)
    Invoke-Expression $trustedExpression
}

Write-Output "Build starting"
Install-BuildPrerequisite
Write-Output "Building"
#Invoke-Build
Write-Output "Build complete"
$PSModules = [PSModuleInstaller]::new()
$PSModules.InstallPowerShellModules($PSModules.ModuleInstaller(("PSScriptAnalyzer","Pester","SharePointOnline.CSOM"),"-Module"))
$chocolateyPackages = [ChocolateyPackageInstaller]::new()
$chocolateyPackages.InstallChocolateyPackages($chocolateyPackages.ModuleInstaller(("NodeJS","python","pandoc")," "))
$nodePackages = [NodePackageInstaller]::new()
$nodePackages.InstallNodePackages($nodePackages.ModuleInstaller(("markdownlint-cli","markdown-spellcheck","jslint","jasmine")," "))
