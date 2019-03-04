FROM microsoft/windowsservercore
RUN PowerShell -Command Install-PackageProvider -MinimumVersion 2.0 -Name "Nuget" -Force
RUN PowerShell -Command Install-Module -MinimumVersion 1.16 -Name "PSScriptAnalyzer" -Force -SkipPublisherCheck
RUN PowerShell -Command Install-Module -MinimumVersion 4.0 -Name "Pester" -Force -SkipPublisherCheck
