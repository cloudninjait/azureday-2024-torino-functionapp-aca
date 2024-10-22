using Microsoft.Extensions.Logging;

public class BaseFunction(ILogger logger)
{
    protected readonly ILogger _logger = logger;
}