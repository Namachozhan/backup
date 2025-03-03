# Enable WinRM for remote management
Enable-PSRemoting -Force

# Configure LocalAccountTokenFilterPolicy to allow remote access for local administrator accounts
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 1

# Start the WinRM service
Start-Service winrm

# Configure firewall to allow WinRM traffic (HTTP on port 5985)
New-NetFirewallRule -Name "Allow WinRM" -DisplayName "Allow WinRM" -Enabled True -Protocol TCP -Direction Inbound -LocalPort 5985 -Action Allow

# Verify WinRM is configured correctly
winrm quickconfig


winrm set winrm/config/service/Auth '@{Basic="true"}'
 
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

Restart-Service WinRM -Force

# Allow the all ports
New-NetFirewallRule -DisplayName "All Inbound Traffic Testing" -Direction Inbound -Protocol TCP -Action Allow -Enabled True -Profile Any -LocalPort Any -RemotePort Any -RemoteAddress Any
