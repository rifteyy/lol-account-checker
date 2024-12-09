Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
$dialog.Title = "Select a Text File"

$result = $dialog.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $filePath = $dialog.FileName
    Write-Output "$filePath"
    # You can save this path to a variable or use it as needed
} else {
    Write-Output "FALSE"
}
