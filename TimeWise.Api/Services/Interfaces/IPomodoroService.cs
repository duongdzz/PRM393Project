using TimeWise.Api.DTOs.Pomodoro;

namespace TimeWise.Api.Services.Interfaces;

public interface IPomodoroService
{
    Task<List<PomodoroSessionDto>> GetSessionsAsync(Guid userId, DateOnly? date = null);
    Task<PomodoroSessionDto> CreateSessionAsync(Guid userId, CreatePomodoroSessionRequest request);
}
