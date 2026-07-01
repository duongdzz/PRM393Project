using TimeWise.Api.Entities;

namespace TimeWise.Api.Repositories.Interfaces;

public interface IPomodoroSessionRepository
{
    Task<List<PomodoroSession>> GetByUserIdAsync(Guid userId, DateOnly? date = null);
    Task AddAsync(PomodoroSession session);
}
