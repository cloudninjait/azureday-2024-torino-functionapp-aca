using Azure.Messaging.ServiceBus;

namespace CloudNinjaFunctionApp.Integration
{
    public class AzureServiceBus : IServiceBus
    {
        private ServiceBusClient _client = null; 

        public AzureServiceBus(string connectionString)
        {
            _client = new ServiceBusClient(connectionString);            
        }

        public async ValueTask SendMessageToTopic(string topicName,string message )
        {
            ServiceBusSender sender = _client.CreateSender(topicName);

            ServiceBusMessage busMessage = new ServiceBusMessage(message);
            try
            {
                await sender.SendMessageAsync(busMessage);
            }
            catch (Exception ex)
            {
                throw new ServiceBusMessageException("Error sending message to Service Bus", ex);
            }
        }
    }
}