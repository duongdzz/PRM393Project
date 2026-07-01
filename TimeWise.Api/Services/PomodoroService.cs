using TimeWise.Api.DTOs.Pomodoro;
using TimeWise.Api.Entities;
using TimeWise.Api.Entities.Enums;
using TimeWise.Api.Helpers;
using TimeWise.Api.Mappings;
using TimeWise.Api.Repositories.Interfaces;
using TimeWise.Api.Services.Interfaces;

namespace TimeWise.Api.Services;

public class PomodoroService : IPomodoroService
{
    private readonly IPomodoroSessionRepository _sessions;
    private readonly ITaskRepository _tasks;

    public PomodoroService(
        IPomodoroSessionRepository sessions,
        ITaskRepository tasks)
    {
        _sessions = sessions;
        _tasks = tasks;
    }

    public async Task<List<PomodoroSessionDto>> GetSessionsAsync(Guid userId, DateOnly? date = null)
    {
        var items = await _sessions.GetByUserIdAsync(userId, date);
        return items.Select(EntityMappers.ToDto).ToList();
    }

    public async Task<PomodoroSessionDto> CreateSessionAsync(
        Guid userId, CreatePomodoroSessionRequest request)
    {
        if (!EnumParseHelper.IsDefined<PomodoroSessionType>(request.SessionType))
            throw new ArgumentException("SessionType không hợp lệ.");

        if (request.TaskId.HasValue)
        {
            var task = await _tasks.GetByIdAsync(request.TaskId.Value, userId);
            if (task is null)
                throw new ArgumentException("Task không tồn tại.");
        }

        var session = new PomodoroSession
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TaskId = request.TaskId,
            TaskTitle = request.TaskTitle?.Trim(),
            SessionType = EnumParseHelper.Parse(request.SessionType, PomodoroSessionType.Work),
            StartedAt = request.StartedAt,
            EndedAt = request.EndedAt,
            Completed = request.Completed
        };

        await _sessions.AddAsync(session);
        return EntityMappers.ToDto(session);
    }
}
