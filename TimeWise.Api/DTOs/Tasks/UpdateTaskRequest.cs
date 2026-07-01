namespace TimeWise.Api.DTOs.Tasks;

public class UpdateTaskRequest
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Status { get; set; }
    public int Priority { get; set; }
    public int Recurrence { get; set; }
    public DateOnly? Deadline { get; set; }
    public DateOnly? StartDate { get; set; }
    public List<int>? WeekDays { get; set; }
    public List<CreateSubTaskRequest>? SubTasks { get; set; }
}
