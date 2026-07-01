using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TimeWise.Api.DTOs.Tasks;
using TimeWise.Api.Extensions;
using TimeWise.Api.Services.Interfaces;

namespace TimeWise.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/tasks")]
public class TasksController : ControllerBase
{
    private readonly ITaskService _taskService;

    public TasksController(ITaskService taskService) => _taskService = taskService;

    [HttpGet]
    public async Task<ActionResult<List<TaskDto>>> GetAll()
    {
        var userId = User.GetUserId();
        var tasks = await _taskService.GetAllAsync(userId);
        return Ok(tasks);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<TaskDto>> GetById(Guid id)
    {
        var userId = User.GetUserId();
        var task = await _taskService.GetByIdAsync(userId, id);
        if (task is null)
            return NotFound(new { message = "Task không tồn tại." });

        return Ok(task);
    }

    [HttpPost]
    public async Task<ActionResult<TaskDto>> Create([FromBody] CreateTaskRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            var task = await _taskService.CreateAsync(userId, request);
            return CreatedAtAction(nameof(GetById), new { id = task.Id }, task);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<TaskDto>> Update(Guid id, [FromBody] UpdateTaskRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            var task = await _taskService.UpdateAsync(userId, id, request);
            if (task is null)
                return NotFound(new { message = "Task không tồn tại." });

            return Ok(task);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var userId = User.GetUserId();
        var deleted = await _taskService.DeleteAsync(userId, id);
        if (!deleted)
            return NotFound(new { message = "Task không tồn tại." });

        return NoContent();
    }

    /// <summary>Đánh dấu hoàn thành — query date tùy chọn (yyyy-MM-dd).</summary>
    [HttpPost("{id:guid}/complete")]
    public async Task<ActionResult<TaskDto>> Complete(Guid id, [FromQuery] string? date)
    {
        DateOnly? completionDate = null;
        if (!string.IsNullOrWhiteSpace(date))
        {
            if (!DateOnly.TryParse(date, out var parsed))
                return BadRequest(new { message = "Ngày không hợp lệ. Dùng định dạng yyyy-MM-dd." });

            completionDate = parsed;
        }

        var userId = User.GetUserId();
        var (task, error) = await _taskService.CompleteAsync(userId, id, completionDate);

        if (error is not null)
            return BadRequest(new { message = error });

        return Ok(task);
    }
}
