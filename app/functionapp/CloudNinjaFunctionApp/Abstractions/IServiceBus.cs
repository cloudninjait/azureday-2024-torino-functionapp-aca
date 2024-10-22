namespace CloudNinjaFunctionApp.Abstractions
{
    public interface IServiceBus
    {        
        ValueTask SendMessageToTopic(string topicName, string message );
    }
}