Param([Switch]$AppVeyor,[Parameter(Mandatory=$true)][String]$DockerTarget)
Write-Output "Run all tests"
$result = Invoke-Pester . -PassThru -OutputFile FullTestResults.xml -OutputFormat NUnitXml
If ($result.FailedCount -ne 0) {
    Write-Output "${result.FailedCount} tests failed - aborting build"
    Exit $result.FailedCount
}
Write-Output "Tests complete"
