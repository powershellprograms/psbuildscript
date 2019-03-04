Describe "static analysis" {
    It "should not have any findings" {
        (Invoke-ScriptAnalyzer -Path . -Recurse) | Out-String | Should -BeNullOrEmpty
    }
}
