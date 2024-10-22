using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace CloudNinjaFunctionApp
{
    public class CronTriggerFunction : BaseFunction
    {
        private readonly string _topicName = null;

        private readonly IServiceBus _serviceBus;

        private const int NUMBER_OF_MESSAGES = 250;

        public CronTriggerFunction(IServiceBus serviceBus, ILoggerFactory loggerFactory, IConfiguration configuration) : base(
                loggerFactory.CreateLogger<CronTriggerFunction>()
            )
        {
            _serviceBus = serviceBus;

            _topicName = configuration[AppConfigurationKeys.ServiceBusConfig.CORE_SERVICE_TOPIC_NAME]!;
        }

        [Function(FunctionNames.CRON_TRIGGER_FUNCTION)]
        public async Task Run(
            [TimerTrigger("0 */5 * * * *")] TimerInfo myTimer
        )
        {
            _logger.LogInformation("C# Timer trigger function executed at: {0}", DateTime.UtcNow);


            for (int i = 0; i < NUMBER_OF_MESSAGES; i++)
            {
                var item = new
                {
                    data = new
                    {
                        res = Guid.NewGuid().ToString()
                    }
                };

                var message = SerializationHelper.Serialize(item);

                await _serviceBus.SendMessageToTopic(_topicName, message);
            }

            if (myTimer.ScheduleStatus is not null)
            {
                _logger.LogInformation($"Next timer schedule at: {myTimer.ScheduleStatus.Next}");
            }
        }
    }
}