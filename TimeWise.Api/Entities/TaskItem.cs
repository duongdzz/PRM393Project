using TimeWise.Api.Entities.Enums;

namespace TimeWise.Api.Entities;

/// <summary>
/// Công việc — trọng tâm việc lặp lại. Tên TaskItem tránh trùng System.Threading.Tasks.Task.
/// </summary>
public class TaskItem
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public Enums.TaskStatus Status { get; set; } = Enums.TaskStatus.Todo;
    public TaskPriority Priority { get; set; } = TaskPriority.Medium;
    public RecurrenceType RecurrenceType { get; set; } = RecurrenceType.Daily;

    /// <summary>Chỉ dùng cho việc một lần (RecurrenceType.Once).</summary>
    public DateOnly? Deadline { get; set; }

    /// <summary>Ngày bắt đầu lặp (RecurrenceType != Once).</summary>
    public DateOnly? StartDate { get; set; }

    /// <summary>Các ngày trong tuần, ví dụ "1,3,5" (T2=1 … CN=7).</summary>
    public string? WeekDays { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public User User { get; set; } = null!;
    public ICollection<TaskCompletion> Completions { get; set; } = new List<TaskCompletion>();
    public ICollection<SubTask> SubTasks { get; set; } = new List<SubTask>();
    public ICollection<PomodoroSession> PomodoroSessions { get; set; } = new List<PomodoroSession>();
}
