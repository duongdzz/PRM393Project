# Bước 10 — Kiểm tra toàn bộ chức năng (E2E)

## Điều kiện chạy test

1. **SQL Server** — database `TimeWiseDb` với 5 bảng (Users, Tasks, TaskCompletions, SubTasks, PomodoroSessions)
2. **API** — chạy Development trên port **5000**:
   ```powershell
   cd TimeWise.Api
   $env:ASPNETCORE_ENVIRONMENT = "Development"
   dotnet run --launch-profile http
   ```
3. **Flutter** — emulator Android (`10.0.2.2:5000`) hoặc thiết bị thật (đổi `baseUrl` trong `api_service.dart`)

---

## Kết quả test tự động (Backend)

| # | Kiểm tra | Kết quả |
|---|----------|---------|
| 1 | Swagger `/swagger` | PASS |
| 2 | `POST /api/auth/dev` → JWT | PASS |
| 3 | Không token → 401 | PASS |
| 4 | Tạo task lặp (recurrence=1) | PASS |
| 5 | Hoàn thành task lặp theo ngày | PASS |
| 6 | Tạo + hoàn thành task một lần (status=2) | PASS |
| 7 | `GET /api/tasks` | PASS |
| 8 | Pomodoro POST + GET theo ngày | PASS |
| 9 | Enum byte (weekdays=2) | PASS |
| 10 | DELETE task (204 No Content) | PASS |
| 11 | `flutter analyze lib` — không có **error** | PASS |

---

## Checklist test thủ công trên Flutter

### A. Chế độ Khách (local-only)

- [ ] Splash → Login → **Vào với tư cách Khách**
- [ ] Dashboard hiển thị tên "Khách"
- [ ] Thêm công việc (FAB +) → hiện trên Dashboard / Lịch
- [ ] Tick hoàn thành trên Dashboard hoặc Lịch
- [ ] Pomodoro chạy timer → session lưu in-memory (mất khi thoát app)
- [ ] **Không** cần API chạy

### B. Đăng nhập Google (sync API + SQL Server)

- [ ] API đang chạy Development
- [ ] Đăng xuất (Profile) nếu đang Khách
- [ ] **Đăng nhập Google** trên Android → vào Home
- [ ] Thêm công việc lặp → kiểm tra SSMS: bảng `Tasks` có row mới
- [ ] Tick hoàn thành → bảng `TaskCompletions` có row
- [ ] Pomodoro hoàn thành 1 phiên work → bảng `PomodoroSessions` có row
- [ ] Thoát app → mở lại → task vẫn còn (load từ API)

### C. Các tab UI (không đổi layout)

- [ ] **Tổng quan** — stat cards, danh sách hôm nay
- [ ] **Pomodoro** — timer, chuyển phiên work/break
- [ ] **Lịch** — chấm ngày có task, tick theo ngày
- [ ] **Thống kê** — số liệu từ task/pomodoro
- [ ] **Hồ sơ** — avatar, tên, đăng xuất

---

## Kiến trúc hoàn chỉnh

```
Flutter (GetX UI)
  ├── Khách → in-memory
  └── Google → ApiService (Dio + JWT)
         └── TimeWise.Api (ASP.NET Core)
                └── SQL Server TimeWiseDb
```

---

## Lưu ý vận hành

| Vấn đề | Cách xử lý |
|--------|-----------|
| Flutter "Không thể kết nối server" | Kiểm tra API port 5000, emulator dùng `10.0.2.2` |
| Swagger không mở | Chạy `$env:ASPNETCORE_ENVIRONMENT = "Development"` |
| Google login lỗi idToken | Kiểm tra Web OAuth client ID + SHA-1 trên Google Cloud |
| Task POST 400 | Enum 0-based — đã fix `EnumParseHelper` |
| Pomodoro GET rỗng theo ngày | Đã fix timezone UTC ↔ local |

---

## Tóm tắt dự án (Bước 1–10)

| Bước | Nội dung | Trạng thái |
|------|----------|------------|
| 1 | Database design | ✅ |
| 2 | Entity | ✅ |
| 3 | DbContext | ✅ |
| 4 | SQL scripts | ✅ |
| 5 | Repository | ✅ |
| 6 | Service + DTO | ✅ |
| 7 | Controller + JWT | ✅ |
| 8 | Swagger test | ✅ |
| 9 | Kết nối Flutter | ✅ |
| 10 | Kiểm tra E2E | ✅ |

**UI Flutter giữ nguyên 100%** — chỉ thay nguồn dữ liệu bằng REST API + SQL Server.
