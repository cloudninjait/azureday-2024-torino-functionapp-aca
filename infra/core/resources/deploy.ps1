param (
    [Parameter(Mandatory=$true)]
    [string]$Enviroment
)

& "..\..\deploy-bicep.ps1" -Enviroment $Enviroment