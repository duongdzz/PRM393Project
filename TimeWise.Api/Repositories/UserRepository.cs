using Microsoft.EntityFrameworkCore;
using TimeWise.Api.Data;
using TimeWise.Api.Entities;
using TimeWise.Api.Repositories.Interfaces;

namespace TimeWise.Api.Repositories;

public class UserRepository : IUserRepository
{
    private readonly TimeWiseDbContext _db;

    public UserRepository(TimeWiseDbContext db) => _db = db;

    public Task<User?> GetByIdAsync(Guid id) =>
        _db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == id);

    public Task<User?> GetByGoogleIdAsync(string googleId) =>
        _db.Users.FirstOrDefaultAsync(u => u.GoogleId == googleId);

    public Task<User?> GetByEmailAsync(string email) =>
        _db.Users.FirstOrDefaultAsync(u => u.Email == email);

    public async Task AddAsync(User user)
    {
        _db.Users.Add(user);
        await _db.SaveChangesAsync();
    }

    public async Task UpdateAsync(User user)
    {
        _db.Users.Update(user);
        await _db.SaveChangesAsync();
    }
}
