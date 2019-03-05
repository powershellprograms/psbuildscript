#Describe "static analysis" {
#    It "should not have any findings" {
#        (Invoke-ScriptAnalyzer -Path . -Recurse) | Out-String | Should -BeNullOrEmpty
#    }
#}
Describe 'Check if modules are installed' {
  it 'static analysis testing' {
    #Invoke-ScriptAnalyzer -Path . -Recurse | ForEach-Object {$_.Length} | Should Be NullOrEmpty
    $results = Invoke-ScriptAnalyzer -Path . -Recurse
    $results | Should Be $null
  }

  it 'Pester is installed' {
    $results = Get-Command -Module Pester
    $results | Should Not Be $null
  }

  it 'Nuget is installed' {
    $results = Get-Command -Name nuget
    $results | Should Not Be $null
  }
}
