using Dapr;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

// Dapr will send serialized event object vs. being raw CloudEvent
app.UseCloudEvents();

// needed for Dapr pub/sub routing
app.MapSubscribeHandler();

if (app.Environment.IsDevelopment()) { app.UseDeveloperExceptionPage(); }

// Dapr subscription in [Topic] routes orders topic to this route
app.MapPost("/process", [Topic("pubsub", "test")] async (object message) => {

    Console.WriteLine("Received : " + JsonSerializer.Serialize(message));

    var envReplica = Environment.GetEnvironmentVariable("CONTAINER_APP_REPLICA_NAME");
    var replica = string.IsNullOrEmpty(envReplica) ? "default-replica" : envReplica;
    await Task.Delay(10000);

    Console.WriteLine($"{replica} consumed topic message.");

    return Results.Ok();
});


//Expose for Service-To-Service invocation
app.MapPost("/service", (object message) => {
    Console.WriteLine("Received : " + JsonSerializer.Serialize(message));
    return Results.Ok();
});

await app.RunAsync();
