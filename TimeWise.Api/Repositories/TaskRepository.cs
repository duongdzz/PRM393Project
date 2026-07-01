using Microsoft.EntityFrameworkCore;
using TimeWise.Api.Data;
using TimeWise.Api.Entities;
using TimeWise.Api.Repositories.Interfaces;

namespace TimeWise.Api.Repositories;

public class TaskRepository : ITaskRepository
{
    private readonly TimeWiseDbContext _db;

    public TaskRepository(TimeWiseDbContext db) => _db = db;

    public Task<List<TaskItem>> GetAllByUserIdAsync(Guid userId) =>
        _db.Tasks
            .AsNoTracking()
            .Include(t => t.Completions)
            .Include(t => t.SubTasks)
            .Where(t => t.UserId == userId)
            .OrderByDescending(t => t.UpdatedAt)
            .ToListAsync();

    public Task<TaskItem?> GetByIdAsync(Guid taskId, Guid userId) =>
        _db.Tasks
            .Include(t => t.Completions)
            .Include(t => t.SubTasks)
            .FirstOrDefaultAsync(t => t.Id == taskId && t.UserId == userId);

    public async Task AddAsync(TaskItem task)
    {
        _db.Tasks.Add(task);
        await _db.SaveChangesAsync();
    }

    public async Task UpdateAsync(TaskItem task)
    {
        _db.Tasks.Update(task);
        await _db.SaveChangesAsync();
    }

    public async Task<bool> DeleteAsync(Guid taskId, Guid userId)
    {
        if (!await _db.Tasks.AnyAsync(t => t.Id == taskId && t.UserId == userId))
            return false;

        // FK PomodoroSessions.TaskId dùng NO ACTION — gỡ liên kết trước khi xóa task.
        await _db.PomodoroSessions
            .Where(p => p.TaskId == taskId)
            .ExecuteUpdateAsync(s => s.SetProperty(p => p.TaskId, (Guid?)null));

        await _db.Tasks
            .Where(t => t.Id == taskId && t.UserId == userId)
            .ExecuteDeleteAsync();

        return true;
    }

    public async Task AddCompletionAsync(TaskCompletion completion)
    {
        _db.TaskCompletions.Add(completion);
        await _db.SaveChangesAsync();
    }

    public Task<bool> CompletionExistsAsync(Guid taskId, DateOnly completionDate) =>
        _db.TaskCompletions.AnyAsync(c =>
            c.TaskId == taskId && c.CompletionDate == completionDate);
}
