Add-Type -AssemblyName System.Windows.Forms

$dialog = New-Object System.Windows.Forms.SaveFileDialog
$dialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
$dialog.Title = "Select a text file name to save as"

# Optional: Set initial directory
# $dialog.InitialDirectory = "C:\"

$result = $dialog.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $file = $dialog.FileName
    # Now you have the file path, you can save your data to this file
    Write-Host "$file"
} else {
    Write-Host "error"
}
