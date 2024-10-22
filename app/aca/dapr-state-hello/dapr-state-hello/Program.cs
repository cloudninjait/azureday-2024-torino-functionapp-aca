using Dapr.Client;
using System.Diagnostics;

#if DEBUG
Debugger.Launch();
#endif

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/hello-state", async () =>
{
    var client = new DaprClientBuilder().Build();
    
    // Get state from the state store
    var result = await client.GetStateAsync<int>("statestore", "myintkey");

    // Save state into the state store
    await client.SaveStateAsync("statestore", "myintkey", ++result);

    return result;
})
.WithName("HelloState")
.WithOpenApi();

app.MapGet("/invoke-dapr", async (int count) =>
{
    var client = DaprClient.CreateInvokeHttpClient(appId: "daprconsumer");

    Stopwatch watch = new Stopwatch();
    watch.Start();
    for (int i = 0; i < count; i++)
    {
        // Invoking a service
        var response = await client.PostAsJsonAsync("/process-dapr", i);

        Console.WriteLine("processed: " + i);
    }
    watch.Stop();
    
    Console.WriteLine($"Time elapsed: {watch.ElapsedMilliseconds} ms");

    return watch.ElapsedMilliseconds;
})
.WithName("InvokeDapr")
.WithOpenApi();

app.MapGet("/publish", async (int count) =>
{
    var daprClient = new DaprClientBuilder().Build();

    Stopwatch watch = new Stopwatch();
    watch.Start();
    for (int i = 0; i < count; i++)
    {
        // Invoking a service
        await daprClient.PublishEventAsync("pubsub", "test", new { res = i });

        Console.WriteLine("pushed event: " + i);
    }
    watch.Stop();

    Console.WriteLine($"Time elapsed: {watch.ElapsedMilliseconds} ms");

    return watch.ElapsedMilliseconds;
})
.WithName("Publish")
.WithOpenApi();

app.Run();
