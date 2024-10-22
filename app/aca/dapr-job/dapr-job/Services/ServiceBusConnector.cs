using Azure.Messaging.ServiceBus;
using System.Text.Json;

public class ServiceBusTopicPublisher
{
    private readonly string _connectionString;
    private readonly string _topicName;

    public ServiceBusTopicPublisher(string connectionString, string topicName)
    {
        _connectionString = connectionString;
        _topicName = topicName;
    }

    public async Task SendMessagesAsync(List<object> events)
    {
        // Create a ServiceBusClient object
        await using var client = new ServiceBusClient(_connectionString);

        // Create a sender for the topic
        ServiceBusSender sender = client.CreateSender(_topicName);

        List<ServiceBusMessageBatch> batches = new List<ServiceBusMessageBatch>();
        try
        {
            // Create a batch of messages to send
            var messageBatch = await sender.CreateMessageBatchAsync();
            batches.Add(messageBatch);

            int messageCount = 0;

            while(messageCount < events.Count)
            {
                var message = new ServiceBusMessage(JsonSerializer.Serialize(events[messageCount]));

                // Try adding the message to the batch
                if (!messageBatch.TryAddMessage(message))
                {
                    // Create a new batch
                    messageBatch = await sender.CreateMessageBatchAsync();
                    batches.Add(messageBatch);

                    if (!messageBatch.TryAddMessage(message))
                    {
                        throw new Exception($"Error processing event '{events[messageCount]}'.");
                    }
                }

                messageCount++;
            }

            foreach(var batch in batches)
            {
                await sender.SendMessagesAsync(batch);
            }

            Console.WriteLine($"Sent {events.Count} messages to the topic {_topicName}.");
        }
        finally
        {
            foreach (var batch in batches)
            {
                batch.Dispose();
            }

            await sender.DisposeAsync();
        }
    }
}
