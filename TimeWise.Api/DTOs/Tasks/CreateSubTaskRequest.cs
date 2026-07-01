namespace TimeWise.Api.DTOs.Tasks;

public class CreateSubTaskRequest
{
    public string Title { get; set; } = string.Empty;
    public bool IsDone { get; set; }
}
