using Microsoft.EntityFrameworkCore;
using TimeWise.Api.Entities;

namespace TimeWise.Api.Data;

public class TimeWiseDbContext : DbContext
{
    public TimeWiseDbContext(DbContextOptions<TimeWiseDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<TaskItem> Tasks => Set<TaskItem>();
    public DbSet<TaskCompletion> TaskCompletions => Set<TaskCompletion>();
    public DbSet<SubTask> SubTasks => Set<SubTask>();
    public DbSet<PomodoroSession> PomodoroSessions => Set<PomodoroSession>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(x => x.Id);

            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.GoogleId).HasMaxLength(128);
            entity.Property(x => x.DisplayName).HasMaxLength(200).IsRequired();
            entity.Property(x => x.PhotoUrl).HasMaxLength(500);

            entity.HasIndex(x => x.Email)
                .IsUnique()
                .HasFilter("[Email] IS NOT NULL");

            entity.HasIndex(x => x.GoogleId)
                .IsUnique()
                .HasFilter("[GoogleId] IS NOT NULL");
        });

        modelBuilder.Entity<TaskItem>(entity =>
        {
            entity.ToTable("Tasks");

            entity.HasKey(x => x.Id);

            entity.Property(x => x.Title).HasMaxLength(200).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(1000);
            entity.Property(x => x.WeekDays).HasMaxLength(20);

            entity.HasOne(x => x.User)
                .WithMany(u => u.Tasks)
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(x => x.UserId);
        });

        modelBuilder.Entity<TaskCompletion>(entity =>
        {
            entity.HasKey(x => x.Id);

            entity.HasOne(x => x.Task)
                .WithMany(t => t.Completions)
                .HasForeignKey(x => x.TaskId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(x => new { x.TaskId, x.CompletionDate }).IsUnique();
        });

        modelBuilder.Entity<SubTask>(entity =>
        {
            entity.HasKey(x => x.Id);

            entity.Property(x => x.Title).HasMaxLength(200).IsRequired();

            entity.HasOne(x => x.Task)
                .WithMany(t => t.SubTasks)
                .HasForeignKey(x => x.TaskId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<PomodoroSession>(entity =>
        {
            entity.HasKey(x => x.Id);

            entity.Property(x => x.TaskTitle).HasMaxLength(200);

            entity.HasOne(x => x.User)
                .WithMany(u => u.PomodoroSessions)
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(x => x.Task)
                .WithMany(t => t.PomodoroSessions)
                .HasForeignKey(x => x.TaskId)
                .OnDelete(DeleteBehavior.NoAction);

            entity.HasIndex(x => x.UserId);
            entity.HasIndex(x => x.StartedAt);
        });
    }
}
