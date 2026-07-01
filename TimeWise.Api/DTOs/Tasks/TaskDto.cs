namespace TimeWise.Api.DTOs.Tasks;

/// <summary>
/// Map với TaskModel trong Flutter (enum 0-based, completedDates dạng "yyyy-M-d").
/// </summary>
public class TaskDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Status { get; set; }
    public int Priority { get; set; }
    public int Recurrence { get; set; }
    public DateOnly? Deadline { get; set; }
    public DateOnly? StartDate { get; set; }
    public List<int> WeekDays { get; set; } = [];
    public List<string> CompletedDates { get; set; } = [];
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public List<SubTaskDto> SubTasks { get; set; } = [];
}
