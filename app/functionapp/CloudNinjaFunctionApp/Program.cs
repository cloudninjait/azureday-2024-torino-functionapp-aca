using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services =>
    {
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();

        services.AddConfiguration();
        services.AddDatasources();
        services.AddLogics();
        services.AddRepositories();
        services.AddServices();
        services.AddAzureService();
    })
    .Build();

host.Run();