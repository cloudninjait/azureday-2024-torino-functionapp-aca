using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace CloudNinjaFunctionApp.Functions
{
    public class ServiceBusTriggerFunction
    {

        private const int DELAY_MS = 10000;

        private readonly ILogger<ServiceBusTriggerFunction> _logger;

        public ServiceBusTriggerFunction(ILogger<ServiceBusTriggerFunction> logger)
        {
            _logger = logger;
        }

        [Function(FunctionNames.SERVICE_BUS_TRIGGER_FUNCTION)]
        public async Task Run(
            [ServiceBusTrigger(
                    "%ServiceBusTopicName%", 
                    "%ServiceBusSubscriptionNameFunctionApp%", 
                    Connection = "ServiceBusConnectionString")]ServiceBusReceivedMessage message,
              ServiceBusMessageActions messageActions)
        {
            var t = Task.Delay(DELAY_MS);

            _logger.LogInformation("Message ID: {id}", message.MessageId);
            _logger.LogInformation("Message Body: {body}", message.Body);
            _logger.LogInformation("Message Content-Type: {contentType}", message.ContentType);

            await t;

            // Complete the message
            await messageActions.CompleteMessageAsync(message);
        }
 
    }
}
