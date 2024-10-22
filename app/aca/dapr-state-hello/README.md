# Run Dapr Application with State Store
dapr run --app-id daprstatehello --resources-path ../../resources/ -- dotnet run --configuration Release

# Run Dapr Application with State Store (with VS Debug)
dapr run --app-id daprstatehello --resources-path ../../resources/ -- dotnet run --configuration Debug