namespace TimeWise.Api.Helpers;

public static class EnumParseHelper
{
    public static bool IsDefined<TEnum>(int value) where TEnum : struct, Enum
    {
        var underlying = Enum.GetUnderlyingType(typeof(TEnum));
        var converted = Convert.ChangeType(value, underlying);
        return Enum.IsDefined(typeof(TEnum), converted);
    }

    public static TEnum Parse<TEnum>(int value, TEnum fallback) where TEnum : struct, Enum
    {
        if (!IsDefined<TEnum>(value))
            return fallback;

        var underlying = Enum.GetUnderlyingType(typeof(TEnum));
        var converted = Convert.ChangeType(value, underlying);
        return (TEnum)Enum.ToObject(typeof(TEnum), converted);
    }
}
