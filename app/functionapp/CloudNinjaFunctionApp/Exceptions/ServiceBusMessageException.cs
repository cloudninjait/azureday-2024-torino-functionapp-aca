using System.Runtime.Serialization;

namespace CloudNinjaFunctionApp.Exceptions;

[Serializable]
public class ServiceBusMessageException : ApplicationException
{
    public ServiceBusMessageException()
    {
    }

    public ServiceBusMessageException(string message) : base(message)
    {
    }

    public ServiceBusMessageException(string message, Exception innerException) : base(message, innerException)
    {
    }

    protected ServiceBusMessageException(SerializationInfo info, StreamingContext context) : base(info, context)
    {
    }
}