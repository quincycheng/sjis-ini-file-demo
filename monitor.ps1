# Config File Locations
$sjisFile = "C:\Users\Quincy\Desktop\SJIS\test.ini"
$utf8File = "C:\Users\Quincy\Desktop\SJIS\test.utf8.ini"

# Monitor File Change
function Wait-FileChange {
    param(
        [string]$File,
        [string]$Action
    )
    $FilePath = Split-Path $File -Parent
    $FileName = Split-Path $File -Leaf
    $ScriptBlock = [scriptblock]::Create($Action)

    $Watcher = New-Object IO.FileSystemWatcher $FilePath, $FileName -Property @{ 
        IncludeSubdirectories = $false
        EnableRaisingEvents = $true
    }
    $onChange = Register-ObjectEvent $Watcher Changed -Action {$global:FileChanged = $true}

    while ($global:FileChanged -eq $false){
        Start-Sleep -Milliseconds 100
    }
    & $ScriptBlock 
    Unregister-Event -SubscriptionId $onChange.Id
}


# Copy file from UTF8 file to SJIS
function CopyUtf8ToSJIS {
	param(
		[string]$fromFile,
		[string]$toFile
		)
				
	Write-Output "The watched file was changed"
	
	Get-Content -Path $fromFile | Out-File -FilePath $toFile -Encoding "shift_jis" 
	
	Write-Output "The SJIS file was updated accordingly"
}


##################
# Program Starts
#
Write-Host "Monitoring $utf8File (Press Ctrl-C to stop)"
$Action = 'CopyUtf8ToSJIS -fromFile $utf8File -toFile $sjisFile'

while ($true) {
	$global:FileChanged = $false
	Wait-FileChange -File $utf8File -Action $Action
	Start-Sleep -Milliseconds 100
}