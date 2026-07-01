# Bước 8 — Test Swagger / API

## 1. Chạy API (Development)

```powershell
cd TimeWise.Api
$env:ASPNETCORE_ENVIRONMENT = "Development"
dotnet run --launch-profile http
```

Mở: **http://localhost:5000/swagger**

> Phải chạy **Development** — Swagger và `/api/auth/dev` chỉ bật ở môi trường này.

## 2. Lấy JWT (test nhanh)

Trong Swagger → **POST /api/auth/dev** → Execute.

Copy `token` từ response → **Authorize** → nhập: `Bearer {token}`

## 3. Test Google Auth (production flow)

**POST /api/auth/google**

```json
{ "idToken": "<idToken từ Flutter Google Sign-In>" }
```

## 4. Test Tasks

| Bước | Endpoint | Body mẫu |
|------|----------|----------|
| Tạo việc lặp | POST `/api/tasks` | `{"title":"Học Flutter","status":0,"priority":2,"recurrence":1,"startDate":"2026-07-02","weekDays":[],"subTasks":[]}` |
| Tạo việc 1 lần | POST `/api/tasks` | `{"title":"Nộp bài","status":0,"priority":3,"recurrence":0,"deadline":"2026-07-10"}` |
| Hoàn thành | POST `/api/tasks/{id}/complete?date=2026-07-02` | (không body) |
| Sửa | PUT `/api/tasks/{id}` | giống POST |
| Xóa | DELETE `/api/tasks/{id}` | |

## 5. Test Pomodoro

**POST /api/pomodoro/sessions**

```json
{
  "taskId": "GUID-task",
  "taskTitle": "Học Flutter",
  "sessionType": 0,
  "startedAt": "2026-07-02T08:00:00Z",
  "endedAt": "2026-07-02T08:25:00Z",
  "completed": true
}
```

**GET /api/pomodoro/sessions?date=2026-07-02**

## 6. Kết quả test tự động (đã chạy)

| Test | Kết quả |
|------|---------|
| Swagger UI | PASS |
| POST /api/auth/dev | PASS |
| POST /api/auth/google (token rỗng) | 400 PASS |
| CRUD /api/tasks | PASS |
| POST complete (lặp + một lần) | PASS |
| Pomodoro GET/POST | PASS |
| Không token → 401 | PASS |
| DB 5 bảng | PASS |

## Lưu ý

- Enum gửi từ JSON là **số nguyên 0-based** (khớp Flutter).
- `completedDates` trả về dạng `"yyyy-M-d"` (vd: `"2026-7-2"`).
- `/api/auth/dev` **chỉ Development** — không dùng khi deploy production.
