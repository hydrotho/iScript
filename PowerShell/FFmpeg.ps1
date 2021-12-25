<#
    .SYNOPSIS

    Change video container formats without re-encoding.

    .DESCRIPTION

    ⚠ Please add ffmpeg to your Windows "PATH" Environment Variable.

    This script makes ffmpeg omit the decoding and encoding steps, so it does only demuxing and muxing when changing the container format.

    .LINK

    https://ffmpeg.org/ffmpeg.html#Stream-copy

    .NOTES

    Test on PowerShell 7.2 (LTS) with Windows Terminal.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$LogFFmpeg = $null

function isSuccessful {
    if ($LASTEXITCODE -ne 0) {
        throw "An Unexpected Error Occurred!"
    }
}

function Get-FileCount {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Dir,

        [Parameter(Mandatory = $false)]
        [switch]
        $Recurse
    )

    if ($Recurse) {
        Get-ChildItem -LiteralPath $Dir -Recurse -File | Measure-Object | Select-Object -ExpandProperty Count
    }
    else {
        Get-ChildItem -LiteralPath $Dir -File | Measure-Object | Select-Object -ExpandProperty Count
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "FFmpeg"
$form.Size = New-Object System.Drawing.Size(500, 250)
$form.StartPosition = "CenterScreen"

$inputPathLabel = New-Object System.Windows.Forms.Label
$inputPathLabel.Location = New-Object System.Drawing.Point(10, 20)
$inputPathLabel.Size = New-Object System.Drawing.Size(480, 20)
$inputPathLabel.Text = "Please Input Absolute Path of a Dir or a File (Include Filename Extension)"
$form.Controls.Add($inputPathLabel)

$inputPathBox = New-Object System.Windows.Forms.TextBox
$inputPathBox.Location = New-Object System.Drawing.Point(10, 45)
$inputPathBox.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($inputPathBox)

$inputExtLabel = New-Object System.Windows.Forms.Label
$inputExtLabel.Location = New-Object System.Drawing.Point(10, 80)
$inputExtLabel.Size = New-Object System.Drawing.Size(480, 20)
$inputExtLabel.Text = "Please Input the Filename Extension of Target Video Container Format"
$form.Controls.Add($inputExtLabel)

$inputExtBox = New-Object System.Windows.Forms.TextBox
$inputExtBox.Location = New-Object System.Drawing.Point(10, 105)
$inputExtBox.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($inputExtBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(125, 155)
$okButton.Size = New-Object System.Drawing.Size(100, 30)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(275, 155)
$cancelButton.Size = New-Object System.Drawing.Size(100, 30)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$form.ControlBox = $false
$form.Topmost = $true

$form.Add_Shown({ $inputPathBox.Select() })
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $InputPath = $inputPathBox.Text
    if ($inputExtBox.Text -match "^\.") {
        $InputExt = $inputExtBox.Text -replace "^[\.]*", "."
    }
    else {
        $InputExt = "." + $inputExtBox.Text
    }

    try {
        if (!(Test-Path -LiteralPath $InputPath -PathType Any)) {
            throw [System.IO.FileNotFoundException] "Invalid Input Path!"
        }

        if (Test-Path -LiteralPath $InputPath -PathType Leaf) {
            $InputItem = Get-Item -LiteralPath $InputPath
            $LogFFmpeg = $InputItem
            $OutputPath = $InputItem.DirectoryName + "\" + "[Mod]" + " " + $InputItem.BaseName + $InputExt
            -Join ('Processing "', $InputItem.Name, '" ...') | Write-Output
            ffmpeg -xerror -i "$InputItem" -map 0:a? -map 0:s? -map 0:v -codec copy "$OutputPath" *> $null
            isSuccessful
            Write-Output "Transfer Successfully!"
            [Microsoft.VisualBasic.Interaction]::MsgBox("Transfer Successfully!", "Information", "FFmpeg") | Out-Null
        }
        else {
            $FileCount = Get-FileCount $InputPath -Recurse
            $NowCount = 0

            Write-Output "Creating Directory..."
            foreach ($ChildDirectory in Get-ChildItem -LiteralPath $InputPath -Recurse -Directory) {
                if ((Get-FileCount $ChildDirectory) -ne 0) {
                    $ChildDirectory.CreateSubdirectory("Mod by Script") | Out-Null
                }
            }
            if ((Get-FileCount $InputPath) -ne 0) {
                (Get-Item -LiteralPath $InputPath).CreateSubdirectory("Mod by Script") | Out-Null
            }

            Write-Progress -Activity "Transfer in Progress" -Status "$NowCount/$FileCount Complete" -PercentComplete 1 -CurrentOperation "Start FFmpeg"
            foreach ($ChildItem in Get-ChildItem -LiteralPath $InputPath -Recurse -File) {
                $LogFFmpeg = $ChildItem
                $OutputPath = $ChildItem.DirectoryName + "\" + "Mod by Script" + "\" + $ChildItem.BaseName + $InputExt
                ffmpeg -xerror -i "$ChildItem" -map 0:a? -map 0:s? -map 0:v -codec copy "$OutputPath" *> $null
                isSuccessful
                $NowCount++
                if (($Percent = [int][Math]::Round($NowCount / $FileCount * 100, [MidpointRounding]::ToZero)) -eq 0) {
                    $Percent = 1
                }
                Write-Progress -Activity "Transfer in Progress" -Status "$NowCount/$FileCount Complete" -PercentComplete $Percent -CurrentOperation $ChildItem
            }
            [Microsoft.VisualBasic.Interaction]::MsgBox("Transfer Successfully!", "Information", "FFmpeg") | Out-Null
        }
    }
    catch [System.IO.FileNotFoundException] {
        [Microsoft.VisualBasic.Interaction]::MsgBox($PSItem.Exception.Message, "Critical", "FFmpeg") | Out-Null
    }
    catch {
        Write-Output "`nError Occured:"
        Write-Output "`t$LogFFmpeg"
        [Microsoft.VisualBasic.Interaction]::MsgBox($PSItem.Exception.Message, "Critical", "FFmpeg") | Out-Null
    }
}
