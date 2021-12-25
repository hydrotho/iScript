<#
    .SYNOPSIS

    Enable or disable PS/2-style keyboard and mouse devices, such as laptop's keyboard and touchpad.

    .DESCRIPTION

    ⚠ Please run this script as Administrator.

    .LINK

    https://docs.microsoft.com/en-us/windows-hardware/drivers/hid/ps-2--i8042prt--driver

    .NOTES

    Test on PowerShell 7.2 (LTS) with Windows Terminal.
#>

Add-Type -AssemblyName Microsoft.VisualBasic

function Test-Administrator {
    $Current = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $Current.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-NOT(Test-Administrator)) {
    Write-Output "Start PowerShell by using the Run as Administrator option, and then try running the script again."
    [Microsoft.VisualBasic.Interaction]::MsgBox("Start PowerShell by using the Run as Administrator option, and then try running the script again.", "Critical", "PS/2-Style Device Enable or Disable") | Out-Null
}
else {
    try {
        $Status = Get-Service -Name i8042prt -ErrorAction Stop | Select-Object -ExpandProperty StartType
        if ($Status -in "Automatic", "AutomaticDelayedStart") {
            Set-Service -Name i8042prt -StartupType Disabled | Out-Null
            Write-Output "Disable PS/2-style devices! Please reboot your computer for these changes to take effect!"
            [Microsoft.VisualBasic.Interaction]::MsgBox("Disable PS/2-style devices! Please reboot your computer for these changes to take effect!", "Information", "PS/2-Style Device Enable or Disable") | Out-Null
        }
        elseif ($Status -in "Disabled") {
            Set-Service -Name i8042prt -StartupType Automatic | Out-Null
            Write-Output "Enable PS/2-style devices! Please reboot your computer for these changes to take effect!"
            [Microsoft.VisualBasic.Interaction]::MsgBox("Enable PS/2-style devices! Please reboot your computer for these changes to take effect!", "Information", "PS/2-Style Device Enable or Disable") | Out-Null
        }
        else {
            Write-Output "Your computer's PS/2 (i8042prt) service startup type is 'Mannual'. This script has done nothing and exited."
            [Microsoft.VisualBasic.Interaction]::MsgBox("Your computer's PS/2 (i8042prt) service startup type is 'Mannual'. This script has done nothing and exited.", "Exclamation", "PS/2-Style Device Enable or Disable") | Out-Null
        }
    }
    catch {
        Write-Output "Your computer doesn't have PS/2 (i8042prt) service."
        [Microsoft.VisualBasic.Interaction]::MsgBox("Your computer doesn't have PS/2 (i8042prt) service.", "Critical", "PS/2-Style Device Enable or Disable") | Out-Null
    }
}
