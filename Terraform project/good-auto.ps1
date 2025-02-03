param(
    [string]$repoDir,
    [string]$repoUrl,
    [string]$logFile = "C:\repo_creation_log.txt"
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

# ############## Git Installation ##############
# Check if Git is installed and skip installation if it is
try {
    $gitVersion = git --version
    if ($gitVersion) {
        Log-Message "Git is already installed: $gitVersion"
        $gitInstalled = $true
    } else {
        $gitInstalled = $false
    }
} catch {
    $gitInstalled = $false
}

# If Git is not installed, install Git
if (-not $gitInstalled) {
    Log-Message "Git is not installed. Installing Git..."
    try {
        $gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.1/Git-2.42.0-64-bit.exe"
        $installerPath = "$env:TEMP\git-installer.exe"
        Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $installerPath -ErrorAction Stop

        Log-Message "Running Git installer..."
        Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /NORESTART /SP-" -Wait
        Log-Message "Git installation process completed."

        Remove-Item -Path $installerPath
        Log-Message "Git installer removed."

        # Manually refresh the environment variables (so git is recognized in the current session)
        [System.Environment]::SetEnvironmentVariable('Path', "$env:Path;C:\Program Files\Git\bin", [System.EnvironmentVariableTarget]::Process)
        Log-Message "Git path added to current session's environment variables."

    } catch {
        Log-Message "Error during Git installation: $_"
    }
}

# Ensure Git is in the PATH
$gitPath = "C:\Program Files\Git\bin\git.exe"
if (Test-Path $gitPath) {
    try {
        $currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Process)
        Log-Message "Current PATH (session): $currentPath"
        if ($currentPath -notlike "*C:\Program Files\Git\bin*") {
            [System.Environment]::SetEnvironmentVariable('Path', "$currentPath;C:\Program Files\Git\bin", [System.EnvironmentVariableTarget]::Process)
            Log-Message "Git path added to environment variables for this session."
        } else {
            Log-Message "Git path already in environment variables."
        }
    } catch {
        Log-Message "Error while adding Git to PATH: $_"
    }
} else {
    Log-Message "Git executable not found at $gitPath. Please check the installation."
}

# Check if the directory exists and create it using New-Item
try {
    if (-Not (Test-Path -Path $repoDir)) {
        Log-Message "Directory does not exist. Creating directory: '$repoDir'"
        try {
            $newDir = New-Item -ItemType Directory -Path $repoDir -Force
            Log-Message "Directory '$repoDir' created. New-Item result: $newDir"
            # Check if the directory exists immediately after creation
            if (Test-Path -Path $repoDir) {
                Log-Message "Confirmed: Directory '$repoDir' exists."
            } else {
                Log-Message "Error: Directory '$repoDir' was not created successfully."
            }
        } catch {
            Log-Message "Error during directory creation: $_"
        }
    } else {
        Log-Message "Directory '$repoDir' already exists."
    }
} catch {
    Log-Message "Error while checking/creating directory '$repoDir': $_"
}

# Change to the newly created or existing directory
Set-Location -Path $repoDir

# Verify current directory
$currentDir = Get-Location
Log-Message "Current Directory: $currentDir"

# Add delay before reattempting Git usage
Start-Sleep -Seconds 3

# Check if Git is in the PATH before cloning
try {
    git --version
    Log-Message "Git is accessible, proceeding with cloning."
} catch {
    Log-Message "Git is not recognized in the PATH. Please check the installation."
}

# Clone the Git repository
try {
    Log-Message "Cloning repository: $repoUrl"
    git clone $repoUrl
    Log-Message "Repository cloned successfully."

    # List the contents of the cloned repository
    $clonedRepoDir = [System.IO.Path]::Combine($repoDir, (Split-Path $repoUrl -Leaf).Replace(".git", ""))
    Log-Message "Available files in cloned repository '$clonedRepoDir':"
    Get-ChildItem -Path $clonedRepoDir | ForEach-Object { Log-Message "  $_.Name" }
} catch {
    Log-Message "Error during repository cloning: $_"
}

# ############## Python Installation ##############
# Log file paths for Python installation
$pythonLogFile = "C:\python_installation.log"

try {
    # Python installation
    $pythonInstallerUrl = "https://www.python.org/ftp/python/3.9.9/python-3.9.9-amd64.exe"
    $installerPath = "$env:TEMP\python-installer.exe"

    Log-Message "Downloading Python installer..."
    Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $installerPath -ErrorAction Stop
    Log-Message "Installing Python..."
    Start-Process -FilePath $installerPath -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 Include_Examples=1' -Wait

    if (Test-Path "C:\Program Files\Python39\python.exe") {
        Log-Message "Python installed successfully."
    } else {
        Log-Message "Python installation failed."
    }
} catch {
    Log-Message "Error: $($_.Exception.Message)"
}

# ############## VS Code Installation ##############
# Log file path for VS Code installation
$vscodeLogFile = "C:\vscode_install.log"

try {
    # Install VS Code
    $vscodeUrl = "https://update.code.visualstudio.com/latest/win32-x64/stable"
    $destination = "$env:TEMP\vscode_installer.exe"
    Log-Message "Downloading VS Code installer from $vscodeUrl"

    Invoke-WebRequest -Uri $vscodeUrl -OutFile $destination -UseBasicParsing
    Log-Message "Starting VS Code installation"

    Start-Process -Wait -FilePath $destination -ArgumentList '/verysilent', '/mergetasks=!runcode'
    Remove-Item $destination

    # Verify VS Code installation
    $vscodePath = "C:\Program Files\Microsoft VS Code\Code.exe"
    if (Test-Path $vscodePath) {
        Log-Message "VS Code installation completed successfully"
    } else {
        Log-Message "VS Code installation failed: Executable not found at $vscodePath"
    }
} catch {
    Log-Message "VS Code installation failed: $($_.Exception.Message)"
}
