namespace TimeWise.Api.Entities;

public class User
{
    public Guid Id { get; set; }
    public string? Email { get; set; }
    public string? GoogleId { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public ICollection<TaskItem> Tasks { get; set; } = new List<TaskItem>();
    public ICollection<PomodoroSession> PomodoroSessions { get; set; } = new List<PomodoroSession>();
}
