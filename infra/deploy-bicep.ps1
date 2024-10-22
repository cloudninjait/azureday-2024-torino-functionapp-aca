param (
    [Parameter(Mandatory=$true)]
    [string]$Enviroment,
    
    [string]$DeploymentType = "resourcegroup"
)

$paramFilePath =  "params-$Enviroment.json"
$BicepPath = "main.bicep"

# Check if the configuration file exists
if (-Not (Test-Path $paramFilePath)) {
    Write-Error "The configuration file '$paramFilePath' does not exist."
    exit 1
}

# Check if the bicep file exists
if (-Not (Test-Path $BicepPath)) {
    Write-Error "The bicep file '$BicepPath' does not exist."
    exit 1
}

# Read the combined configuration
$combinedConfig = Get-Content -Raw -Path $paramFilePath| ConvertFrom-Json

# Extract resource group name and parameters from the combined configuration
$resourceGroup = $combinedConfig.resourceGroupName
$parameters = $combinedConfig.parameters | ConvertTo-Json -Compress

# Save parameters to a temporary file
$tempParametersFile = [System.IO.Path]::GetTempFileName() + ".json"
$parameters | Out-File -FilePath $tempParametersFile

try {
    # Deploy the Bicep template
    if($DeploymentType -eq "resourcegroup") {
        
        az deployment group create --resource-group $resourceGroup --template-file $BicepPath --parameters @$tempParametersFile
    }
    else {
        az deployment sub create --template-file $BicepPath --location WestEurope --parameters @$tempParametersFile
    }

    # Clean up temporary file
    Remove-Item -Path $tempParametersFile
}
catch {
    Write-Error "Deployment failed: $_"
    # Clean up temporary file in case of error
    Remove-Item -Path $tempParametersFile -ErrorAction SilentlyContinue
}
