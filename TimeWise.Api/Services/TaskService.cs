using TimeWise.Api.DTOs.Tasks;
using TimeWise.Api.Entities;
using TimeWise.Api.Entities.Enums;
using TimeWise.Api.Helpers;
using TimeWise.Api.Mappings;
using TimeWise.Api.Repositories.Interfaces;
using TimeWise.Api.Services.Interfaces;
using TaskStatusEnum = TimeWise.Api.Entities.Enums.TaskStatus;

namespace TimeWise.Api.Services;

public class TaskService : ITaskService
{
    private readonly ITaskRepository _tasks;

    public TaskService(ITaskRepository tasks) => _tasks = tasks;

    public async Task<List<TaskDto>> GetAllAsync(Guid userId)
    {
        var items = await _tasks.GetAllByUserIdAsync(userId);
        return items.Select(EntityMappers.ToDto).ToList();
    }

    public async Task<TaskDto?> GetByIdAsync(Guid userId, Guid taskId)
    {
        var task = await _tasks.GetByIdAsync(taskId, userId);
        return task is null ? null : EntityMappers.ToDto(task);
    }

    public async Task<TaskDto> CreateAsync(Guid userId, CreateTaskRequest request)
    {
        ValidateTaskRequest(request.Title, request.Recurrence, request.Deadline, request.StartDate);

        var now = DateTime.UtcNow;
        var task = new TaskItem
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Title = request.Title.Trim(),
            Description = request.Description?.Trim(),
            Status = EnumParseHelper.Parse(request.Status, TaskStatusEnum.Todo),
            Priority = EnumParseHelper.Parse(request.Priority, TaskPriority.Medium),
            RecurrenceType = EnumParseHelper.Parse(request.Recurrence, RecurrenceType.Daily),
            Deadline = request.Deadline,
            StartDate = request.StartDate,
            WeekDays = WeekDaysHelper.Serialize(request.WeekDays),
            CreatedAt = now,
            UpdatedAt = now,
            SubTasks = MapSubTasks(request.SubTasks)
        };

        await _tasks.AddAsync(task);
        return EntityMappers.ToDto(task);
    }

    public async Task<TaskDto?> UpdateAsync(Guid userId, Guid taskId, UpdateTaskRequest request)
    {
        ValidateTaskRequest(request.Title, request.Recurrence, request.Deadline, request.StartDate);

        var task = await _tasks.GetByIdAsync(taskId, userId);
        if (task is null) return null;

        task.Title = request.Title.Trim();
        task.Description = request.Description?.Trim();
        task.Status = EnumParseHelper.Parse(request.Status, task.Status);
        task.Priority = EnumParseHelper.Parse(request.Priority, task.Priority);
        task.RecurrenceType = EnumParseHelper.Parse(request.Recurrence, task.RecurrenceType);
        task.Deadline = request.Deadline;
        task.StartDate = request.StartDate;
        task.WeekDays = WeekDaysHelper.Serialize(request.WeekDays);
        task.UpdatedAt = DateTime.UtcNow;

        task.SubTasks.Clear();
        foreach (var subTask in MapSubTasks(request.SubTasks))
            task.SubTasks.Add(subTask);

        await _tasks.UpdateAsync(task);

        var updated = await _tasks.GetByIdAsync(taskId, userId);
        return updated is null ? null : EntityMappers.ToDto(updated);
    }

    public async Task<bool> DeleteAsync(Guid userId, Guid taskId) =>
        await _tasks.DeleteAsync(taskId, userId);

    public async Task<(TaskDto? Task, string? Error)> CompleteAsync(
        Guid userId, Guid taskId, DateOnly? date)
    {
        var task = await _tasks.GetByIdAsync(taskId, userId);
        if (task is null)
            return (null, "Task không tồn tại");

        var pendingSubTasks = task.SubTasks.Count(s => !s.IsDone);
        if (pendingSubTasks > 0)
            return (null, $"Còn {pendingSubTasks} công việc con chưa hoàn thành");

        var day = date ?? DateOnly.FromDateTime(DateTime.Now);

        if (task.RecurrenceType == RecurrenceType.Once)
        {
            task.Status = TaskStatusEnum.Done;
        }
        else
        {
            if (!TaskOccurrenceHelper.OccursOn(task, day))
                return (null, "Công việc không có trong ngày này");

            if (!await _tasks.CompletionExistsAsync(taskId, day))
            {
                await _tasks.AddCompletionAsync(new TaskCompletion
                {
                    Id = Guid.NewGuid(),
                    TaskId = taskId,
                    CompletionDate = day,
                    CompletedAt = DateTime.UtcNow
                });
            }
        }

        task.UpdatedAt = DateTime.UtcNow;
        await _tasks.UpdateAsync(task);

        var updated = await _tasks.GetByIdAsync(taskId, userId);
        return updated is null
            ? (null, "Task không tồn tại")
            : (EntityMappers.ToDto(updated), null);
    }

    private static void ValidateTaskRequest(
        string title, int recurrenceValue, DateOnly? deadline, DateOnly? startDate)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Vui lòng nhập tên công việc");

        var recurrence = EnumParseHelper.Parse<RecurrenceType>(recurrenceValue, RecurrenceType.Daily);

        if (recurrence == RecurrenceType.Once && deadline is null)
            throw new ArgumentException("Vui lòng chọn ngày cho công việc một lần");

        if (recurrence != RecurrenceType.Once && startDate is null)
            throw new ArgumentException("Vui lòng chọn ngày bắt đầu");
    }

    private static List<SubTask> MapSubTasks(IReadOnlyList<CreateSubTaskRequest>? subTasks)
    {
        if (subTasks is null || subTasks.Count == 0)
            return [];

        return subTasks
            .Select((s, index) => new SubTask
            {
                Id = Guid.NewGuid(),
                Title = s.Title.Trim(),
                IsDone = s.IsDone,
                SortOrder = index
            })
            .ToList();
    }
}
