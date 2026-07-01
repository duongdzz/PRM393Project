using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TimeWise.Api.DTOs.Pomodoro;
using TimeWise.Api.Extensions;
using TimeWise.Api.Services.Interfaces;

namespace TimeWise.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/pomodoro/sessions")]
public class PomodoroController : ControllerBase
{
    private readonly IPomodoroService _pomodoroService;

    public PomodoroController(IPomodoroService pomodoroService) =>
        _pomodoroService = pomodoroService;

    [HttpGet]
    public async Task<ActionResult<List<PomodoroSessionDto>>> GetSessions([FromQuery] string? date)
    {
        DateOnly? filterDate = null;
        if (!string.IsNullOrWhiteSpace(date))
        {
            if (!DateOnly.TryParse(date, out var parsed))
                return BadRequest(new { message = "Ngày không hợp lệ. Dùng định dạng yyyy-MM-dd." });

            filterDate = parsed;
        }

        var userId = User.GetUserId();
        var sessions = await _pomodoroService.GetSessionsAsync(userId, filterDate);
        return Ok(sessions);
    }

    [HttpPost]
    public async Task<ActionResult<PomodoroSessionDto>> Create([FromBody] CreatePomodoroSessionRequest request)
    {
        try
        {
            var userId = User.GetUserId();
            var session = await _pomodoroService.CreateSessionAsync(userId, request);
            return CreatedAtAction(nameof(GetSessions), new { date = (string?)null }, session);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
