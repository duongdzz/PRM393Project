using Microsoft.EntityFrameworkCore;
using TimeWise.Api.Data;
using TimeWise.Api.Entities;
using TimeWise.Api.Repositories.Interfaces;

namespace TimeWise.Api.Repositories;

public class PomodoroSessionRepository : IPomodoroSessionRepository
{
    private readonly TimeWiseDbContext _db;

    public PomodoroSessionRepository(TimeWiseDbContext db) => _db = db;

    public Task<List<PomodoroSession>> GetByUserIdAsync(Guid userId, DateOnly? date = null)
    {
        var query = _db.PomodoroSessions
            .AsNoTracking()
            .Where(p => p.UserId == userId);

        if (date.HasValue)
        {
            // Client gửi ngày theo lịch local; StartedAt lưu UTC.
            var localDayStart = date.Value.ToDateTime(TimeOnly.MinValue);
            var localDayEnd = localDayStart.AddDays(1);
            var utcStart = TimeZoneInfo.ConvertTimeToUtc(localDayStart, TimeZoneInfo.Local);
            var utcEnd = TimeZoneInfo.ConvertTimeToUtc(localDayEnd, TimeZoneInfo.Local);
            query = query.Where(p => p.StartedAt >= utcStart && p.StartedAt < utcEnd);
        }

        return query
            .OrderByDescending(p => p.StartedAt)
            .ToListAsync();
    }

    public async Task AddAsync(PomodoroSession session)
    {
        _db.PomodoroSessions.Add(session);
        await _db.SaveChangesAsync();
    }
}
