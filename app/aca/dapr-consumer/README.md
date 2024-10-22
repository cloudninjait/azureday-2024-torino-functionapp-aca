# Run Dapr Application with State Store
dapr run --app-id daprconsumer --resources-path ../../resources/ --app-port 7006 -- dotnet run --configuration Release

# Run Dapr Application with State Store (with VS Debug)
dapr run --app-id daprconsumer --resources-path ../../resources/ --app-port 7006 -- dotnet run --configuration Debug


# Monitoring Queries

## Container Replicas workload distribution 
ContainerAppConsoleLogs_CL
| where time_t >= datetime('2024-10-16 13:00')
| where ContainerAppName_s contains "app-daprconsumer"
| where Log_s contains "consumed topic message."
| summarize count(), min(time_t), max(time_t) by Log_s
| project Replica = Log_s, Duration = max_time_t - min_time_t, Total = count_

## Container Replicas parallelism
ContainerAppConsoleLogs_CL
| where time_t >= datetime('2024-10-09 13:00')
| where ContainerAppName_s == "app-daprconsumer"
| where Log_s contains "consumed topic message."
| summarize count() by bin(time_t, 10s)


## Overall workload distribution

let aca = view(){
ContainerAppConsoleLogs_CL
| where time_t >= datetime('2024-10-16 13:00')
| where ContainerAppName_s contains "app-daprconsumer"
| where Log_s contains "consumed topic message."
| summarize count() by Log_s
| project Replica = Log_s, Total = count_
};
let func = view(){
AppTraces
| where TimeGenerated >= datetime('2024-10-16 13:00')
| where AppRoleName == "azuretorino-live-func"
| where Message contains "Executed 'Functions.ServiceBusTriggerFunction'" and Message contains "Succeeded"
| summarize count() by AppRoleInstance
| project Replica = AppRoleInstance, Total = count_
};
union withsource='Perf' aca, func
| summarize by Perf, Replica, Total
| render barchart kind=stacked


## Overall excecution

let aca = view(){
ContainerAppConsoleLogs_CL
| where time_t >= datetime('2024-10-16 13:00')
| where ContainerAppName_s contains "app-daprconsumer"
| where Log_s contains "consumed topic message."
| summarize count() by bin(time_t, 10s)
| project time_bin = time_t, count_
};
let func = view(){
AppTraces
| where TimeGenerated >= datetime('2024-10-16 13:00')
| where AppRoleName == "azuretorino-live-func"
| where Message contains "Executed 'Functions.ServiceBusTriggerFunction'" and Message contains "Succeeded"
| summarize count() by bin(TimeGenerated, 10s)
| project time_bin = TimeGenerated, count_
};
union withsource='Perf' aca, func
| summarize count_ = sum(count_) by time_bin, Perf
| render columnchart kind=unstacked

