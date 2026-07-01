# TimeWiseDb — Tạo database trên SQL Server (không dùng EF Migration)

Project **không** chứa thư mục `Migrations`. Database được tạo thủ công bằng script SQL.

## Yêu cầu

- SQL Server (LocalDB, Express, hoặc full)
- Tài khoản `sa` (hoặc user có quyền `CREATE DATABASE`)

## Cách 1: SQL Server Management Studio (SSMS)

1. Mở SSMS, kết nối server (ví dụ `localhost`).
2. **File → Open → File** → chọn `CreateTimeWiseDb.sql`.
3. **Execute** (F5).
4. Kiểm tra: Database `TimeWiseDb` → Tables (`Users`, `Tasks`, `TaskCompletions`, `SubTasks`, `PomodoroSessions`).

## Cách 2: sqlcmd (PowerShell)

```powershell
sqlcmd -S localhost -U sa -P "MAT_KHAU_CUA_BAN" -i "Database\CreateTimeWiseDb.sql"
```

## Cấu hình API

Sửa password trong `appsettings.Development.json`:

```json
"DefaultConnection": "Server=localhost;Database=TimeWiseDb;User Id=sa;Password=MAT_KHAU_CUA_BAN;TrustServerCertificate=True;"
```

## Chỉ có 4 bảng (thiếu PomodoroSessions)

Nguyên nhân: lần chạy trước script cũ lỗi FK cascade (Msg 1785) nên dừng ở bảng thứ 5.

**Cách nhanh — giữ nguyên 4 bảng hiện có:**

1. Mở SSMS, database `TimeWiseDb`
2. Execute file **`Fix_PomodoroSessions_FK.sql`**
3. Refresh Tables → phải thấy **PomodoroSessions**

**Hoặc làm lại từ đầu:**

```sql
USE master;
DROP DATABASE IF EXISTS TimeWiseDb;
```

Rồi Execute **`CreateTimeWiseDb.sql`** (bản đã sửa `ON DELETE NO ACTION`).

## Lưu ý

- EF Core **chỉ kết nối** tới database đã tạo sẵn; không chạy `dotnet ef migrations`.
- `PomodoroSessions.TaskId` dùng `ON DELETE NO ACTION` (SQL Server không cho phép nhiều cascade path từ `Users`). Khi xóa task, Repository sẽ `SET TaskId = NULL` trên các session liên quan trước khi xóa.
- Nếu script lỗi ở `PomodoroSessions`: chạy thêm `Fix_PomodoroSessions_FK.sql`.
- Nếu đổi schema sau này: cập nhật script SQL + entity + DbContext, rồi chạy script ALTER thủ công (hoặc script mới).
