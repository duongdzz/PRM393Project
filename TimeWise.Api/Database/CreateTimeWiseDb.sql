-- =============================================================================
-- TimeWiseDb — Tạo database + schema (không dùng EF Migration)
-- Chạy bằng SQL Server Management Studio (SSMS) hoặc sqlcmd.
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'TimeWiseDb')
BEGIN
    CREATE DATABASE TimeWiseDb;
END
GO

USE TimeWiseDb;
GO

-- ── Users ────────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        Id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Users_Id DEFAULT NEWID(),
        Email       NVARCHAR(256)    NULL,
        GoogleId    NVARCHAR(128)    NULL,
        DisplayName NVARCHAR(200)    NOT NULL,
        PhotoUrl    NVARCHAR(500)    NULL,
        CreatedAt   DATETIME2        NOT NULL,
        UpdatedAt   DATETIME2        NOT NULL,
        CONSTRAINT PK_Users PRIMARY KEY (Id)
    );

    CREATE UNIQUE INDEX IX_Users_Email
        ON dbo.Users (Email)
        WHERE Email IS NOT NULL;

    CREATE UNIQUE INDEX IX_Users_GoogleId
        ON dbo.Users (GoogleId)
        WHERE GoogleId IS NOT NULL;
END
GO

-- ── Tasks ────────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'dbo.Tasks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tasks
    (
        Id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Tasks_Id DEFAULT NEWID(),
        UserId         UNIQUEIDENTIFIER NOT NULL,
        Title          NVARCHAR(200)    NOT NULL,
        Description    NVARCHAR(1000)   NULL,
        Status         TINYINT          NOT NULL CONSTRAINT DF_Tasks_Status DEFAULT 0,
        Priority       TINYINT          NOT NULL CONSTRAINT DF_Tasks_Priority DEFAULT 1,
        RecurrenceType TINYINT          NOT NULL CONSTRAINT DF_Tasks_RecurrenceType DEFAULT 1,
        Deadline       DATE             NULL,
        StartDate      DATE             NULL,
        WeekDays       NVARCHAR(20)     NULL,
        CreatedAt      DATETIME2        NOT NULL,
        UpdatedAt      DATETIME2        NOT NULL,
        CONSTRAINT PK_Tasks PRIMARY KEY (Id),
        CONSTRAINT FK_Tasks_Users_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.Users (Id) ON DELETE CASCADE
    );

    CREATE INDEX IX_Tasks_UserId ON dbo.Tasks (UserId);
END
GO

-- ── TaskCompletions ──────────────────────────────────────────────────────────
IF OBJECT_ID(N'dbo.TaskCompletions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TaskCompletions
    (
        Id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_TaskCompletions_Id DEFAULT NEWID(),
        TaskId         UNIQUEIDENTIFIER NOT NULL,
        CompletionDate DATE             NOT NULL,
        CompletedAt    DATETIME2        NOT NULL,
        CONSTRAINT PK_TaskCompletions PRIMARY KEY (Id),
        CONSTRAINT FK_TaskCompletions_Tasks_TaskId
            FOREIGN KEY (TaskId) REFERENCES dbo.Tasks (Id) ON DELETE CASCADE
    );

    CREATE UNIQUE INDEX IX_TaskCompletions_TaskId_CompletionDate
        ON dbo.TaskCompletions (TaskId, CompletionDate);
END
GO

-- ── SubTasks ─────────────────────────────────────────────────────────────────
IF OBJECT_ID(N'dbo.SubTasks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SubTasks
    (
        Id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_SubTasks_Id DEFAULT NEWID(),
        TaskId    UNIQUEIDENTIFIER NOT NULL,
        Title     NVARCHAR(200)    NOT NULL,
        IsDone    BIT              NOT NULL CONSTRAINT DF_SubTasks_IsDone DEFAULT 0,
        SortOrder INT              NOT NULL CONSTRAINT DF_SubTasks_SortOrder DEFAULT 0,
        CONSTRAINT PK_SubTasks PRIMARY KEY (Id),
        CONSTRAINT FK_SubTasks_Tasks_TaskId
            FOREIGN KEY (TaskId) REFERENCES dbo.Tasks (Id) ON DELETE CASCADE
    );
END
GO

-- ── PomodoroSessions ─────────────────────────────────────────────────────────
IF OBJECT_ID(N'dbo.PomodoroSessions', N'U') IS NULL
BEGIN
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
        -- NO ACTION: tránh multiple cascade paths (User→Tasks CASCADE + User→PomodoroSessions CASCADE)
        CONSTRAINT FK_PomodoroSessions_Tasks_TaskId
            FOREIGN KEY (TaskId) REFERENCES dbo.Tasks (Id) ON DELETE NO ACTION
    );

    CREATE INDEX IX_PomodoroSessions_UserId ON dbo.PomodoroSessions (UserId);
    CREATE INDEX IX_PomodoroSessions_StartedAt ON dbo.PomodoroSessions (StartedAt);
END
GO

-- ── Enum reference (chỉ ghi chú, không lưu DB) ───────────────────────────────
-- TaskStatus:       0=Todo, 1=InProgress, 2=Done, 3=Cancelled
-- TaskPriority:     0=Low, 1=Medium, 2=High, 3=Urgent
-- RecurrenceType:   0=Once, 1=Daily, 2=Weekdays, 3=Weekly, 4=Monthly
-- PomodoroSessionType: 0=Work, 1=ShortBreak, 2=LongBreak

PRINT N'TimeWiseDb schema created successfully.';
GO

-- ── Kiểm tra đủ 5 bảng ───────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'PomodoroSessions')
BEGIN
    RAISERROR(N'THIEU bang PomodoroSessions! Chay file Fix_PomodoroSessions_FK.sql', 16, 1);
END
ELSE
BEGIN
    PRINT N'OK: Du 5 bang (Users, Tasks, TaskCompletions, SubTasks, PomodoroSessions).';
END
GO
