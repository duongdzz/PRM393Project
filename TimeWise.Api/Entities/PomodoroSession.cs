using TimeWise.Api.Entities.Enums;

namespace TimeWise.Api.Entities;

public class PomodoroSession
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid? TaskId { get; set; }
    public string? TaskTitle { get; set; }
    public PomodoroSessionType SessionType { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public bool Completed { get; set; }

    public User User { get; set; } = null!;
    public TaskItem? Task { get; set; }
}
