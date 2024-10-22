# Azure Serverless: dalle Azure Functions ai Microservizi in Container

![Carratta_Santacroce_-_Azure_Serverless_dalle_Azure_Functions_ai_Microservizi_in_Container_730177 (1)](https://github.com/user-attachments/assets/63e8704a-5e73-4f40-a5aa-1a539aa2c659)

## Deploy

### Azure Login
az login --tenant TENANT_ID

###  Deploy Core Infrastructure
dir infra/core/int
powershell .\deploy.ps1

dir infra/core/resources
powershell .\deploy.ps1

###  Deploy ACA Enviroment
dir infra/services
powershell .\deploy.ps1

