-- =============================================================================
-- BỔ SUNG bảng PomodoroSessions khi DB chỉ có 4 bảng (Users, Tasks, ...)
-- Chạy file này trên TimeWiseDb hiện tại — KHÔNG cần xóa database.
-- =============================================================================

USE TimeWiseDb;
GO

IF OBJECT_ID(N'dbo.PomodoroSessions', N'U') IS NOT NULL
    DROP TABLE dbo.PomodoroSessions;
GO

CREATE TABLE dbo.PomodoroSessions
(
    Id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PomodoroSessions_Id DEFAULT NEWID(),
    UserId      UNIQUEIDENTIFIER NOT NULL,
    TaskId      UNIQUEIDENTIFIER NULL,
    TaskTitle   NVARCHAR(200)    NULL,
    SessionType TINYINT          NOT NULL,
    StartedAt   DATETIME2        NOT NULL,
    EndedAt     DATETIME2        NULL,
    Completed   BIT              NOT NULL CONSTRAINT DF_PomodoroSessions_Completed DEFAULT 0,
    CONSTRAINT PK_PomodoroSessions PRIMARY KEY (Id),
    CONSTRAINT FK_PomodoroSessions_Users_UserId
        FOREIGN KEY (UserId) REFERENCES dbo.Users (Id) ON DELETE CASCADE,
    CONSTRAINT FK_PomodoroSessions_Tasks_TaskId
        FOREIGN KEY (TaskId) REFERENCES dbo.Tasks (Id) ON DELETE NO ACTION
);

CREATE INDEX IX_PomodoroSessions_UserId ON dbo.PomodoroSessions (UserId);
CREATE INDEX IX_PomodoroSessions_StartedAt ON dbo.PomodoroSessions (StartedAt);
GO

PRINT N'PomodoroSessions created successfully.';
GO
