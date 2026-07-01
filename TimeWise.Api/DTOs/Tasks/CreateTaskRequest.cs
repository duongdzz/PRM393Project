namespace TimeWise.Api.DTOs.Tasks;

public class CreateTaskRequest
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Status { get; set; }
    public int Priority { get; set; } = 1;
    public int Recurrence { get; set; } = 1;
    public DateOnly? Deadline { get; set; }
    public DateOnly? StartDate { get; set; }
    public List<int>? WeekDays { get; set; }
    public List<CreateSubTaskRequest>? SubTasks { get; set; }
}
