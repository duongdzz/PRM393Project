using TimeWise.Api.Entities;
using TimeWise.Api.Entities.Enums;
using TaskStatusEnum = TimeWise.Api.Entities.Enums.TaskStatus;

namespace TimeWise.Api.Helpers;

/// <summary>
/// Logic lặp lại — map với occursOn() trong Flutter task_controller.dart.
/// </summary>
public static class TaskOccurrenceHelper
{
    public static bool OccursOn(TaskItem task, DateOnly day)
    {
        if (task.Status == TaskStatusEnum.Cancelled) return false;

        if (task.RecurrenceType == RecurrenceType.Once)
        {
            if (task.Deadline is null) return false;
            return task.Deadline.Value == day;
        }

        if (task.StartDate is null) return false;
        if (day < task.StartDate.Value) return false;

        return task.RecurrenceType switch
        {
            RecurrenceType.Daily => true,
            RecurrenceType.Weekdays => day.DayOfWeek is >= DayOfWeek.Monday and <= DayOfWeek.Friday,
            RecurrenceType.Weekly => OccursWeekly(task, day),
            RecurrenceType.Monthly => day.Day == task.StartDate.Value.Day,
            _ => false
        };
    }

    private static bool OccursWeekly(TaskItem task, DateOnly day)
    {
        var weekDays = WeekDaysHelper.Parse(task.WeekDays);
        if (weekDays.Count == 0)
            return ToFlutterWeekday(day) == ToFlutterWeekday(task.StartDate!.Value);

        return weekDays.Contains(ToFlutterWeekday(day));
    }

    /// <summary>Flutter weekday: 1=T2 … 7=CN.</summary>
    private static int ToFlutterWeekday(DateOnly date) =>
        date.DayOfWeek == DayOfWeek.Sunday ? 7 : (int)date.DayOfWeek;
}

public static class WeekDaysHelper
{
    public static string? Serialize(IEnumerable<int>? days)
    {
        if (days is null) return null;
        var list = days.OrderBy(d => d).ToList();
        return list.Count == 0 ? null : string.Join(",", list);
    }

    public static List<int> Parse(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return [];
        return value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(int.Parse)
            .ToList();
    }
}

public static class DateKeyHelper
{
    /// <summary>Map dateKey() Flutter: "yyyy-M-d" (không zero-pad).</summary>
    public static string ToDateKey(DateOnly date) => $"{date.Year}-{date.Month}-{date.Day}";
}
