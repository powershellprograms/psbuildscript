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

$PSModules = [PSModuleInstaller]::new()
$PSModules.InstallPowerShellModules($PSModules.ModuleInstaller(("PSScriptAnalyzer","Pester","SharePointOnline.CSOM","SSS"),"-Module"))
$chocolateyPackages = [ChocolateyPackageInstaller]::new()
$chocolateyPackages.InstallChocolateyPackages($chocolateyPackages.ModuleInstaller(("NodeJS","python","pandoc")," "))
$nodePackages = [NodePackageInstaller]::new()
$nodePackages.InstallNodePackages($nodePackages.ModuleInstaller(("markdownlint-cli","markdown-spellcheck","jslint","jasmine")," "))
