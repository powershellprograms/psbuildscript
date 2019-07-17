param([switch]$Jenkins=$false)
$ErrorActionPreference="Stop"
function Confirm-AdministratorContext
{
    $administrator = [Security.Principal.WindowsBuiltInRole] "Administrator"
    $identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $identity.IsInRole($administrator)
}


function Invoke-StaticAnalysis
{
    $result = (Invoke-PSAndMDStaticAnalysis)
    $result
    if ($result.Length -gt 0)
    {
        throw "Build failed. Found $($result.Length) static analysis issue(s)"
    }
    Write-Output "Static analysis findings clean"
    Write-Output "Proceeding for pylinting..."
    $pyresult = (Invoke-Pylinting)
    $pyresult
    if ($pyresult.Length -gt 0)
    {
        throw "Pylinting failed. Found $($pyresult.length) issues(s)"
    }
}


function Invoke-PSAndMDStaticAnalysis
{
    Invoke-ScriptAnalyzer -Path "." -Recurse
    node .\node_modules\markdownlint-cli\markdownlint.js **/*.md -i .\node_modules\
}

function Invoke-Pylinting {
  $files = Get-ChildItem -Path .\ -Filter *.py -Recurse -File -Name
  pylint -E $files

}

function Invoke-Build
{
    if ($Jenkins)
    {
        Write-Output "Building in Jenkins build CI server context"
    }
    else
    {
        Write-Output "Building in normal context"
    }
    Write-Output "Checking static analysis findings"
    Invoke-StaticAnalysis
    Write-Output "Running tests"
    Invoke-Test
    Write-Output "Running python unit tests"
    Invoke-PythonTest
    Write-Output "Python unit tests completed"
}

function Send-TestResult([string]$resultsPath)
{
    # If needed, upload test results to build server here
}

function Invoke-PythonTest {
  $files = Get-ChildItem -Path .\ -Filter encoder_*_t*.py -Recurse -File -Name
  foreach($file in $files) {
      python $file
  }
}

function Invoke-Test
{
    $resultsPath = ".\TestResults.xml"
    Invoke-Pester -EnableExit -OutputFormat NUnitXml -OutputFile $resultsPath
    if ($Jenkins)
    {
        Send-TestResult $resultsPath
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

    Write-Output "**PSScriptAnalyzer powershell module"
    if (-not (Get-Command -Module PSScriptAnalyzer))
    {
        Install-Module -Name "PSScriptAnalyzer" -Force -SkipPublisherCheck
    }

    Write-Output "**Pester powershell module"
    if (-not (Get-Command -Module Pester))
    {
        Install-Module -Name "Pester" -Force -SkipPublisherCheck
    }

    Write-Output "**Chocolatey package manager"
    if (-not (Get-Command choco -ErrorAction SilentlyContinue))
    {
        Invoke-TrustedExpression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    Write-Output "**NodeJS and NPM"
    if (-not (Get-Command npm  -ErrorAction SilentlyContinue))
    {
        cinst --no-progress -y --force NodeJS
    }

    Write-Output "**Python"
    if (-not (Get-Command python -ErrorAction SilentlyContinue))
    {
        cinst --no-progress -y --force Python
    }

    Write-Output "**Pandoc"
    if (-not (Get-Command pandoc -ErrorAction SilentlyContinue))
    {
        cinst --no-progress -y --force pandoc
    }

    Write-Output "**SharePoint Client Components"
    if (-not (Get-Command -Module SharePointOnline.CSOM))
    {
        Install-Module -Name SharePointOnline.CSOM -Force -SkipPublisherCheck
    }

    Write-Output "**makedownlint-cli"
    npm install markdownlint-cli

    Write-Output "**markdownspellcheck"
    npm install markdown-spellcheck
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
Invoke-Build
Write-Output "Build complete"
