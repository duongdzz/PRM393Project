using TimeWise.Api.Entities;

namespace TimeWise.Api.Repositories.Interfaces;

public interface ITaskRepository
{
    Task<List<TaskItem>> GetAllByUserIdAsync(Guid userId);
    Task<TaskItem?> GetByIdAsync(Guid taskId, Guid userId);
    Task AddAsync(TaskItem task);
    Task UpdateAsync(TaskItem task);
    Task<bool> DeleteAsync(Guid taskId, Guid userId);
    Task AddCompletionAsync(TaskCompletion completion);
    Task<bool> CompletionExistsAsync(Guid taskId, DateOnly completionDate);
}
