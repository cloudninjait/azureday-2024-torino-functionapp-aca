using CloudNinja.DaprJob.Appplication;
using CloudNinja.DaprJob.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Serilog;
using Serilog.Context;

try
{
    Console.WriteLine("Starting application...");
    var runId = $"runId:{DateTime.UtcNow:yyyyMMddHHmm}";

    IHost host = App.Build(args);

    var logger = host.Services.GetRequiredService<ILogger<Program>>();
    var config = host.Services.GetRequiredService<IConfiguration>();

    using (LogContext.PushProperty("RunId", runId))
    {
        logger.LogInformation("Pushing events to bus");

        await PushToServiceBus(config);

        logger.LogInformation("Events pushed");

        Log.CloseAndFlush();
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Error: {ex.Message}");
}

async Task PushToServiceBus(IConfiguration config)
{
    var items = int.Parse(config["Items"]);
    List<object> events = new List<object>();

    for (int i = 0; i < items; i++)
    {
        var guid = Guid.NewGuid().ToString();
        BusMessage message = new BusMessage()
        {
            data = new MessageData() { res = Guid.NewGuid().ToString() }
        };

        events.Add(message);
    }

    ServiceBusTopicPublisher publisher = new ServiceBusTopicPublisher(
       config["ServiceBus:ConnectionString"],
       "test"
       );

    await publisher.SendMessagesAsync(events);
}