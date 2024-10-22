namespace CloudNinjaFunctionApp.Helper;

public class SerializationHelper
{
    private static readonly JsonSerializerOptions _options = new JsonSerializerOptions()
    {
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public static string Serialize<T>(T instance)
    {
        return JsonSerializer.Serialize<T>(instance);
    }

    public static T Deserialize<T>(string jsonObject)
    {
        return JsonSerializer.Deserialize<T>(jsonObject, _options);
    }
}