namespace TimeWise.Api.Entities;

/// <summary>
/// Đánh dấu hoàn thành việc lặp theo từng ngày (map completedDates trong Flutter).
/// </summary>
public class TaskCompletion
{
    public Guid Id { get; set; }
    public Guid TaskId { get; set; }
    public DateOnly CompletionDate { get; set; }
    public DateTime CompletedAt { get; set; }

    public TaskItem Task { get; set; } = null!;
}
