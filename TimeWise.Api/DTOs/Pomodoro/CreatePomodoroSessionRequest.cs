namespace TimeWise.Api.DTOs.Pomodoro;

public class CreatePomodoroSessionRequest
{
    public Guid? TaskId { get; set; }
    public string? TaskTitle { get; set; }
    public int SessionType { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public bool Completed { get; set; }
}
