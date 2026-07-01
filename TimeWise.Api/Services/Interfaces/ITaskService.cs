using TimeWise.Api.DTOs.Tasks;

namespace TimeWise.Api.Services.Interfaces;

public interface ITaskService
{
    Task<List<TaskDto>> GetAllAsync(Guid userId);
    Task<TaskDto?> GetByIdAsync(Guid userId, Guid taskId);
    Task<TaskDto> CreateAsync(Guid userId, CreateTaskRequest request);
    Task<TaskDto?> UpdateAsync(Guid userId, Guid taskId, UpdateTaskRequest request);
    Task<bool> DeleteAsync(Guid userId, Guid taskId);
    Task<(TaskDto? Task, string? Error)> CompleteAsync(Guid userId, Guid taskId, DateOnly? date);
}
