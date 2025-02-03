# Define your username and password for authentication
$username = 'chozhan1'
$password = 'Test1234'

# Convert the password to a secure string
$secpw = ConvertTo-SecureString $password -AsPlainText -Force

# Create a PSCredential object with the username and the secure password
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpw)

# Define the remote machine's IP address or hostname
$remoteIP = '13.67.237.194'  # Replace with the actual IP address of the new VM

# Define the local path to your existing PowerShell script (create_directory.ps1)
$localScriptPath = "C:\Users\eaifdevopsvm1\Documents\demo1\Terraform project\dir_creation.ps1"  # Replace with your actual script path

# Read the content of the script locally
$scriptContent = Get-Content -Path $localScriptPath -Raw

# Define the script block to run the script on the remote machine
$scriptBlock = {
    param($script)
    Invoke-Expression $script  # Execute the script content passed
}

# Run the script block remotely using Invoke-Command
Invoke-Command -ComputerName $remoteIP -ScriptBlock $scriptBlock -ArgumentList $scriptContent -Credential $cred -Authentication Basic -Port 5985

#+++++++++++++++++++++++++++ alone++++++++++++++++++++++++++++++++

$username = 'chozhan1'
$password = 'Test1234'
$secpw = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpw)
$remoteIP = '13.89.5.172'
$localScriptPath = "C:\Users\eaifdevopsvm1\Documents\demo1\Terraform project\dir_creation.ps1"
$scriptContent = Get-Content -Path $localScriptPath -Raw
$scriptBlock = {
    param($script)
    Invoke-Expression $script
}
Invoke-Command -ComputerName $remoteIP -ScriptBlock $scriptBlock -ArgumentList $scriptContent -Credential $cred -Port 5985


#+====================================================================
$username = 'chozhan1'
$password = 'Test1234'
$secpw = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpw)

# Define the remote machine IP
$remoteIP = '13.89.5.172'

# Path to the local Python script (make sure it's correctly pointing to the Python script)
$localScriptPath = "C:\Users\eaifdevopsvm1\Documents\demo1\Terraform project\venv.py"

# Read the Python script content
$scriptContent = Get-Content -Path $localScriptPath -Raw

# Define the script block for remote execution
$scriptBlock = {
    param($script, $path_py_venv)
    
    # Create the virtual environment using Python's venv module
    python -c $script --path=$path_py_venv
}

# Path where you want the virtual environment to be created on the remote machine
$path_py_venv = "C:\Users\chozhan3"

# Run the command remotely, passing the Python script content and the path
Invoke-Command -ComputerName $remoteIP -ScriptBlock $scriptBlock -ArgumentList $scriptContent, $path_py_venv -Credential $cred -Port 5985
