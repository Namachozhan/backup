param(
    [string]$logFile = "C:\installation_log.txt"
)

# Log function to write messages to log file
function Log-Message {
    param([string]$message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $message
}

# Check if running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log-Message "Script needs to be run as an administrator."
    exit
}

# ############## Python Installation ##############
try {
    # Python installation (version 3.10)
    $pythonInstallerUrl = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"
    $installerPath = "$env:TEMP\python-installer.exe"

    Log-Message "Downloading Python 3.10 installer..."
    Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $installerPath -ErrorAction Stop
    Log-Message "Installing Python 3.10..."
    Start-Process -FilePath $installerPath -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 Include_Examples=1' -Wait

    if (Test-Path "C:\Program Files\Python310\python.exe") {
        Log-Message "Python 3.10 installed successfully."
    } else {
        Log-Message "Python installation failed."
    }
} catch {
    Log-Message "Error: $($_.Exception.Message)"
}

# ############## Git Installation ##############
try {
    # Git installation (latest version)
    $gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe"
    $installerPath = "$env:TEMP\git-installer.exe"
    
    Log-Message "Downloading Git installer..."
    Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $installerPath -ErrorAction Stop
    Log-Message "Installing Git..."
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /NORESTART /SP-" -Wait

    if (Test-Path "C:\Program Files\Git\bin\git.exe") {
        Log-Message "Git installed successfully."
    } else {
        Log-Message "Git installation failed."
    }
} catch {
    Log-Message "Error: $($_.Exception.Message)"
}

# ############## Visual Studio Code Installation ##############
try {
    # Install VS Code
    $vscodeUrl = "https://update.code.visualstudio.com/latest/win32-x64/stable"
    $destination = "$env:TEMP\vscode_installer.exe"
    Log-Message "Downloading VS Code installer..."

    Invoke-WebRequest -Uri $vscodeUrl -OutFile $destination -UseBasicParsing
    Log-Message "Starting VS Code installation"

    Start-Process -Wait -FilePath $destination -ArgumentList '/verysilent', '/mergetasks=!runcode'
    Remove-Item $destination

    # Verify VS Code installation
    $vscodePath = "C:\Program Files\Microsoft VS Code\Code.exe"
    if (Test-Path $vscodePath) {
        Log-Message "VS Code installation completed successfully."
    } else {
        Log-Message "VS Code installation failed."
    }
} catch {
    Log-Message "VS Code installation failed: $($_.Exception.Message)"
}

Log-Message "Script execution completed."