using TimeWise.Api.DTOs.Pomodoro;
using TimeWise.Api.DTOs.Tasks;
using TimeWise.Api.Entities;
using TimeWise.Api.Helpers;

namespace TimeWise.Api.Mappings;

public static class EntityMappers
{
    public static TaskDto ToDto(TaskItem task) => new()
    {
        Id = task.Id,
        Title = task.Title,
        Description = task.Description ?? string.Empty,
        Status = (int)task.Status,
        Priority = (int)task.Priority,
        Recurrence = (int)task.RecurrenceType,
        Deadline = task.Deadline,
        StartDate = task.StartDate,
        WeekDays = WeekDaysHelper.Parse(task.WeekDays),
        CompletedDates = task.Completions
            .Select(c => DateKeyHelper.ToDateKey(c.CompletionDate))
            .ToList(),
        CreatedAt = task.CreatedAt,
        UpdatedAt = task.UpdatedAt,
        SubTasks = task.SubTasks
            .OrderBy(s => s.SortOrder)
            .Select(ToDto)
            .ToList()
    };

    public static SubTaskDto ToDto(SubTask subTask) => new()
    {
        Id = subTask.Id,
        Title = subTask.Title,
        IsDone = subTask.IsDone,
        SortOrder = subTask.SortOrder
    };

    public static PomodoroSessionDto ToDto(PomodoroSession session) => new()
    {
        Id = session.Id,
        TaskId = session.TaskId,
        TaskTitle = session.TaskTitle,
        SessionType = (int)session.SessionType,
        StartedAt = session.StartedAt,
        EndedAt = session.EndedAt,
        Completed = session.Completed
    };
}
