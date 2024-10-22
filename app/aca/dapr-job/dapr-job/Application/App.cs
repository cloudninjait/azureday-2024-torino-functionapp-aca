using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;

namespace CloudNinja.DaprJob.Appplication
{
    internal class App
    {
        public static IHost Build(string[] args)
        {
            return Host.CreateDefaultBuilder(args)
                .ConfigureHostConfiguration(configHost =>
                {
                    configHost.SetBasePath(Directory.GetCurrentDirectory());
                    configHost.AddJsonFile("appsettings.json", optional: true);
                })
                .ConfigureAppConfiguration((context, config) =>
                {
                    config.AddEnvironmentVariables();

                    var builtConfig = config.Build();

                    foreach (var item in builtConfig.AsEnumerable())
                    {
                        Console.WriteLine($"{item.Key}|{item.Value}");
                    }
                })
                .ConfigureServices((host, services) =>
                {
                    RegisterServices(services, host.Configuration);
                })
                .UseSerilog((context, configuration) =>
                {
                    configuration.ReadFrom.Configuration(context.Configuration);
                    configuration.WriteTo.ApplicationInsights(context.Configuration["appInsightsConnection"], TelemetryConverter.Traces);
                })
                .Build();
        }

        private static void RegisterServices(IServiceCollection services, IConfiguration config)
        {
            //Inject Services
        }
    }
}
