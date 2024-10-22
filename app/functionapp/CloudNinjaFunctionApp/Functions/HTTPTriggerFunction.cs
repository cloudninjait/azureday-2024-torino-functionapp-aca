using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace CloudNinjaFunctionApp.Functions
{
    public class HTTPTriggerFunction : BaseFunction
    {
        public HTTPTriggerFunction(ILogger<HTTPTriggerFunction> logger) : base(logger)
        {
        }

        [Function(FunctionNames.HTTP_TRIGGER_FUNCTION)]
        public IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            return new OkObjectResult("Welcome to Azure Functions!");
        }
    }
}