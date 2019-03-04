Write-Output "Installing NuGet package provider"
Install-PackageProvider -MinimumVersion 2.0 -Name "Nuget" -Force
Write-Output "Installing PSScriptAnalyzer module"
Install-Module -MinimumVersion 1.16 -Name "PSScriptAnalyzer" -Force -SkipPublisherCheck
Write-Output "Installing Pester module"
Install-Module -MinimumVersion 4.0 -Name "Pester" -Force -SkipPublisherCheck
