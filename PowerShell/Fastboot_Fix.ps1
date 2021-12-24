<#
    .SYNOPSIS

    Fix "press any key to shutdown" in fastboot mode.

    .DESCRIPTION

    ⚠ Please run this script as Administrator.

    It seems that Windows 10 uses some advanced usb features that are not supported by some devices, specially with Android in fastboot mode.

    This script will check the current registry and enable or disable the "Fastboot Fix" automatically.

    ⚠ If this script doesn't work for you, maybe your Hardware ID is not the same. ⚠

    .LINK

    https://forum.xda-developers.com/t/help-press-any-key-to-shutdown-in-fastboot.3816021/

    .NOTES

    Test on PowerShell 7.2 (LTS) with Windows Terminal.
#>

Add-Type -AssemblyName Microsoft.VisualBasic

$Hex_0 = @(0, 0)
$Hex_1 = @(1, 0, 0, 0)

function Test-Administrator {
    $Current = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $Current.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-NOT(Test-Administrator)) {
    Write-Output "Start PowerShell by using the Run as Administrator option, and then try running the script again."
    [Microsoft.VisualBasic.Interaction]::MsgBox("Start PowerShell by using the Run as Administrator option, and then try running the script again.", "Critical", "Fastboot Fix") | Out-Null
}
elseif (Test-Path -Path HKLM:\SYSTEM\CurrentControlSet\Control\usbflags\18D1D00D0100) {
    Remove-Item -Path HKLM:\SYSTEM\CurrentControlSet\Control\usbflags\18D1D00D0100 | Out-Null
    Write-Output "Disable Fastboot Fix!"
    [Microsoft.VisualBasic.Interaction]::MsgBox("Disable Fastboot Fix!", "Information", "Fastboot Fix") | Out-Null
}
else {
    New-Item -Path HKLM:\SYSTEM\CurrentControlSet\Control\usbflags -Name 18D1D00D0100 | Out-Null
    New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\usbflags\18D1D00D0100 -Name osvc -PropertyType Binary -Value $Hex_0 | Out-Null
    New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\usbflags\18D1D00D0100 -Name SkipBOSDescriptorQuery -PropertyType Binary -Value $Hex_1 | Out-Null
    New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\usbflags\18D1D00D0100 -Name SkipContainerIdQuery -PropertyType Binary -Value $Hex_1 | Out-Null
    Write-Output "Enable Fastboot Fix!"
    [Microsoft.VisualBasic.Interaction]::MsgBox("Enable Fastboot Fix!", "Information", "Fastboot Fix") | Out-Null
}
