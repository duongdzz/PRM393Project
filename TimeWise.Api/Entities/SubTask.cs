namespace TimeWise.Api.Entities;

public class SubTask
{
    public Guid Id { get; set; }
    public Guid TaskId { get; set; }
    public string Title { get; set; } = string.Empty;
    public bool IsDone { get; set; }
    public int SortOrder { get; set; }

    public TaskItem Task { get; set; } = null!;
}
