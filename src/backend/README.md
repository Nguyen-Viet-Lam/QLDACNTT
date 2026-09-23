# Backend prototype

Backend này là bản mẫu tối giản để chứng minh hướng triển khai API sau giai đoạn phân tích - thiết kế. Dữ liệu đang lưu in-memory, chưa kết nối SQL Server thật.

## Tài khoản mẫu

| Username | Password | Role |
|---|---|---|
| `admin` | `123456` | `ADMIN` |
| `staff` | `123456` | `STAFF` |
| `tech` | `123456` | `TECHNICIAN` |
| `customer` | `123456` | `CUSTOMER` |

## Endpoint

| Method | Endpoint | Quyền |
|---|---|---|
| GET | `/health` | Public |
| POST | `/api/auth/login` | Public |
| POST | `/api/auth/logout` | Đã đăng nhập |
| GET | `/api/auth/me` | Đã đăng nhập |
| GET | `/api/users` | ADMIN |
| GET | `/api/customers` | ADMIN, STAFF |
| GET | `/api/tickets` | ADMIN, STAFF, TECHNICIAN |
| GET | `/api/tickets/{code}` | ADMIN, STAFF, TECHNICIAN |

## Chạy thử

```bash
cd src/backend
dotnet restore
dotnet run
```

Đăng nhập:

```http
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "123456"
}
```

Gọi API cần quyền bằng token nhận được:

```http
GET http://localhost:5000/api/users
X-Session-Token: <token>
```
