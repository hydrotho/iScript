<#
    .SYNOPSIS

    一键添加小鹤双拼方案

    .DESCRIPTION

    ⚠ 请以管理员权限运行本脚本

    小鹤双拼是一种汉字输入法。其特点是把全拼压缩成声母和韵母，用两个键表示一个音。主要是把三个双声母zh、ch、sh及27个复韵母安排到26个字母键上的方案，单声母和单韵母保持原来位置不变。

    .LINK

    https://www.flypy.com/

    .NOTES

    Test on PowerShell 7.2 (LTS) with Windows Terminal.
#>

Add-Type -AssemblyName Microsoft.VisualBasic

function Test-Administrator {
    $Current = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $Current.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Add-FlypyScheme {
    param(
        [Switch]$Quiet
    )

    if (-NOT(Test-Administrator)) {
        Write-Error "请以管理员权限运行本脚本！"
        if (-NOT $Quiet) {
            [Microsoft.VisualBasic.Interaction]::MsgBox("请以管理员权限运行本脚本！", "Critical", "一键添加小鹤双拼方案") | Out-Null
        }
    }
    else {
        try {
            Get-ItemProperty -Path HKCU:Software\Microsoft\InputMethod\Settings\CHS -Name UserDefinedDoublePinyinScheme0 -ErrorAction Stop | Out-Null
            Write-Error "小鹤双拼方案已添加！请勿重复运行本脚本！"
            if (-NOT $Quiet) {
                [Microsoft.VisualBasic.Interaction]::MsgBox("小鹤双拼方案已添加！请勿重复运行本脚本！", "Exclamation", "一键添加小鹤双拼方案") | Out-Null
            }
        }
        catch {
            New-ItemProperty -Path HKCU:Software\Microsoft\InputMethod\Settings\CHS -Name UserDefinedDoublePinyinScheme0 -PropertyType String -Value "小鹤双拼*2*^*iuvdjhcwfg^xmlnpbksqszxkrltvyovt" -Force | Out-Null
            Write-Output "小鹤双拼方案添加成功！"
            if (-NOT $Quiet) {
                [Microsoft.VisualBasic.Interaction]::MsgBox("小鹤双拼方案添加成功！", "Information", "一键添加小鹤双拼方案") | Out-Null
            }
        }
    }
}

Add-FlypyScheme
