Param([Parameter(Mandatory=$true)][String]$DockerTarget)
Write-Output "Run static analysis test"
$result = Invoke-Pester ./StaticAnalysis* -PassThru -OutputFile StaticAnalysisTestResults.xml -OutputFormat NUnitXml
If ($result.FailedCount -ne 0) {
    Write-Output "Static analysis test failed - aborting build"
    Exit $result.FailedCount
}
Write-Output "Build docker image as $DockerTarget"
docker build -t $DockerTarget .
Write-Output "Build complete"
