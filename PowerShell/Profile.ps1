$options = @{
    HistoryNoDuplicates           = $True
    AddToHistoryHandler           = {
        Param([String]$line)
        return $line[0] -ne ' ' -and $line.Length -gt 5
    }
    HistorySearchCursorMovesToEnd = $True
}

Set-PSReadLineOption @options