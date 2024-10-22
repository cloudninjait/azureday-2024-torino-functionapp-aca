using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

public static class ServiceExtensions
{
    internal static IServiceCollection AddConfiguration(this IServiceCollection services)
    {
        using (var provider = services.BuildServiceProvider())
        {
            var configuration = provider.GetRequiredService<IConfiguration>();

            services.AddSingleton<IConfiguration>(configuration);
        }
        return services;
    }

    internal static IServiceCollection AddServices(this IServiceCollection services)
    {
        using (var provider = services.BuildServiceProvider())
        {
            var configuration = provider.GetRequiredService<IConfiguration>();
        }

        return services;
    }

    internal static IServiceCollection AddDatasources(this IServiceCollection services)
    {
        using (var provider = services.BuildServiceProvider())
        {
            var configuration = provider.GetRequiredService<IConfiguration>();
        }

        return services;
    }

    internal static IServiceCollection AddLogics(this IServiceCollection services)
    {
        using (var provider = services.BuildServiceProvider())
        {
            var configuration = provider.GetRequiredService<IConfiguration>();
        }
        return services;
    }

    internal static IServiceCollection AddRepositories(this IServiceCollection services)
    {
        return services;
    }

    internal static IServiceCollection AddAzureService(this IServiceCollection services)
    {
        using (var provider = services.BuildServiceProvider())
        {
            var configuration = provider.GetRequiredService<IConfiguration>();

            services.AddSingleton<IServiceBus, AzureServiceBus>(x =>
            {
                var connectionString = configuration[AppConfigurationKeys.ServiceBusConfig.CORE_SERVICE_BUS_KEY]!;
                var result = new AzureServiceBus(connectionString);
                return result;
            });
        }

        return services;
    }
}