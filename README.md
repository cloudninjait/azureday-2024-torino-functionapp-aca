# Azure Login
az login --tenant <tenant-id>

# Deploy Core Infrastructure
dir infra/core/int
powershell .\deploy.ps1

dir infra/core/resources
powershell .\deploy.ps1

# Deploy ACA Enviroment
dir infra/services
powershell .\deploy.ps1