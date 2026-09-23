# GitHub Issues de tao cho 3 tuan dau

File nay dung de tao issue tren GitHub sau khi repo duoc push va GitHub connector/CLI duoc ket noi. Moi issue nen gan label theo mau: `sprint-1`, `sprint-2`, `sprint-3`, `docs`, `analysis`, `design`, `database`, `testing`, `priority:must`.

> Luu y: thay `@lam`, `@ky`, `@loi` bang GitHub username that cua 3 thanh vien.

## Sprint 1 - Khoi dong va lap ke hoach

### Issue 1

**Title:** `[Sprint 1][L] Hoan thien Project Charter`

**Assignee:** `@lam`  
**Labels:** `sprint-1`, `docs`, `project-management`, `priority:must`

**Body:**

- Mo ta de tai LV33-001.
- Ghi muc tieu SMART cua du an.
- Xac dinh stakeholder.
- Ghi vai tro 3 thanh vien.
- Ghi tieu chi thanh cong co the do duoc.

**Done when:** `docs/01-quan-ly-du-an/Project-Charter.md` day du va duoc ca nhom thong nhat.

### Issue 2

**Title:** `[Sprint 1][L] Hoan thien Scope Statement`

**Assignee:** `@lam`  
**Labels:** `sprint-1`, `docs`, `project-management`, `priority:must`

**Body:**

- Chot in-scope.
- Chot out-of-scope.
- Liet ke deliverables.
- Ghi rang buoc va gia dinh.
- Ghi tieu chi nghiem thu pham vi.

**Done when:** `docs/01-quan-ly-du-an/Scope-Statement.md` khop voi SRS va README.

### Issue 3

**Title:** `[Sprint 1][L] Lap WBS va milestone 8 tuan`

**Assignee:** `@lam`  
**Labels:** `sprint-1`, `docs`, `planning`, `priority:must`

**Body:**

- Chia du an thanh cac goi viec lon.
- Gan thoi gian bat dau/ket thuc.
- Uoc luong cong theo nguoi-ngay.
- Bo sung milestone M1-M8.

**Done when:** `docs/01-quan-ly-du-an/WBS.md` co lich 8 tuan va milestone ro rang.

### Issue 4

**Title:** `[Sprint 1][L] Lap RACI cho 3 thanh vien`

**Assignee:** `@lam`  
**Labels:** `sprint-1`, `docs`, `planning`, `priority:must`

**Body:**

- Liet ke cac goi viec chinh.
- Gan R/A/C/I cho Lam, Ky, Loi.
- Moi goi viec chi co mot nguoi giu A.

**Done when:** `docs/01-quan-ly-du-an/RACI-Matrix.md` ro nguoi chiu trach nhiem tung phan.

## Sprint 2 - Phan tich yeu cau

### Issue 5

**Title:** `[Sprint 2][Lo] Viet bien ban khao sat nghiep vu cua hang sua chua`

**Assignee:** `@loi`  
**Labels:** `sprint-2`, `analysis`, `docs`, `priority:must`

**Body:**

- Mo ta quy trinh tiep nhan thiet bi hien tai.
- Mo ta cach theo doi sua chua, linh kien, thanh toan, bao hanh.
- Ghi bieu mau/dau vao/dau ra dang dung.
- Ghi diem dau va van de can so hoa.

**Done when:** co file bien ban khao sat trong `docs/02-phan-tich/`.

### Issue 6

**Title:** `[Sprint 2][Lo] Hoan thien SRS 8 nhom chuc nang`

**Assignee:** `@loi`  
**Labels:** `sprint-2`, `analysis`, `srs`, `priority:must`

**Body:**

- Dac ta yeu cau tai khoan/RBAC.
- Dac ta khach hang/thiet bi.
- Dac ta phieu sua chua.
- Dac ta linh kien/ton kho.
- Dac ta hoa don/thanh toan.
- Dac ta bao hanh.
- Dac ta bao cao.
- Dac ta mobile app.

**Done when:** `docs/02-phan-tich/SRS.md` co FR va NFR ro, khop voi pham vi.

### Issue 7

**Title:** `[Sprint 2][Lo] Chi tiet hoa 16 User Stories va Acceptance Criteria`

**Assignee:** `@loi`  
**Labels:** `sprint-2`, `analysis`, `user-story`, `priority:must`

**Body:**

- Moi US co actor, mong muon, gia tri.
- Moi US co uu tien, story point, sprint.
- Moi US co acceptance criteria cu the.
- Bo sung cac US con dang ghi chu.

**Done when:** `docs/02-phan-tich/User-Stories.md` khong con muc "cac US con lai viet sau".

### Issue 8

**Title:** `[Sprint 2][L] Viet 3 quy trinh nghiep vu loi`

**Assignee:** `@lam`  
**Labels:** `sprint-2`, `analysis`, `business-process`, `priority:must`

**Body:**

- Quy trinh tiep nhan va xu ly phieu sua chua.
- Quy trinh xuat linh kien va tru ton.
- Quy trinh thanh toan va sinh bao hanh.
- Moi quy trinh ghi ro actor, buoc xu ly, dau vao/dau ra.

**Done when:** co tai lieu quy trinh trong `docs/02-phan-tich/`.

### Issue 9

**Title:** `[Sprint 2][Lo] Ve Use Case tong quat 4 actor`

**Assignee:** `@loi`  
**Labels:** `sprint-2`, `analysis`, `diagram`, `priority:must`

**Body:**

- Actor: Admin, Nhan vien, Ky thuat vien, Khach hang.
- Nhom use case theo chuc nang chinh.
- Xuat anh PNG hoac file drawio/staruml.

**Done when:** so do use case nam trong `docs/03-thiet-ke/use-case/`.

## Sprint 3 - Thiet ke va chot backlog

### Issue 10

**Title:** `[Sprint 3][L] Thiet ke kien truc he thong 3 lop`

**Assignee:** `@lam`  
**Labels:** `sprint-3`, `design`, `architecture`, `priority:must`

**Body:**

- Mo ta Web Admin, Mobile App, Backend API, SQL Server.
- Mo ta luong request/response.
- Mo ta cach phan quyen va bao mat token.

**Done when:** co tai lieu/so do kien truc trong `docs/03-thiet-ke/`.

### Issue 11

**Title:** `[Sprint 3][L] Hoan thien API Specification`

**Assignee:** `@lam`  
**Labels:** `sprint-3`, `design`, `api`, `priority:must`

**Body:**

- Format response chuan.
- Ma loi nghiep vu.
- Quy uoc phan trang.
- Endpoint 8 nhom chuc nang.
- Ma tran phan quyen endpoint theo vai tro.

**Done when:** `docs/03-thiet-ke/API-Specification.md` du dung cho Sprint 4 code.

### Issue 12

**Title:** `[Sprint 3][Lo] Ve ERD va hoan thien Database Design`

**Assignee:** `@loi`  
**Labels:** `sprint-3`, `database`, `design`, `priority:must`

**Body:**

- Ve ERD 13 bang.
- Ghi khoa chinh, khoa ngoai, quan he.
- Mo ta bang/cot/kieu du lieu/rang buoc.
- Ghi quy uoc sinh ma.

**Done when:** `Database-Design.md` day du va co file ERD xuat ra.

### Issue 13

**Title:** `[Sprint 3][Lo] Viet SQL schema, seed va queries bao cao`

**Assignee:** `@loi`  
**Labels:** `sprint-3`, `database`, `sql`, `priority:must`

**Body:**

- Script tao database va 13 bang.
- Constraint, index, computed column.
- Seed vai tro, user, dich vu, linh kien.
- 10 query bao cao thong ke.

**Done when:** cac file trong `database/schema/`, `database/seed/`, `database/queries/` chay duoc tren SQL Server.

### Issue 14

**Title:** `[Sprint 3][K] Mockup dang nhap va layout chung Web Admin`

**Assignee:** `@ky`  
**Labels:** `sprint-3`, `ui-ux`, `design`, `priority:must`

**Body:**

- Mockup man hinh dang nhap.
- Mockup layout sidebar/header/noi dung.
- The hien menu theo vai tro.
- Co mau, font, component co ban.

**Done when:** co link Figma hoac anh mockup luu trong tai lieu.

### Issue 15

**Title:** `[Sprint 3][K] Hoan thien Test Plan`

**Assignee:** `@ky`  
**Labels:** `sprint-3`, `testing`, `qa`, `priority:must`

**Body:**

- Pham vi kiem thu.
- Chien luoc test API, UI, database.
- Tieu chi vao/ra.
- Phan loai bug.
- Cac vung can test ky: ton kho, hoa don, bao hanh.

**Done when:** `docs/04-kiem-thu/Test-Plan.md` du lam can cu viet test case Sprint 4-6.

### Issue 16

**Title:** `[Sprint 3][L] Chot danh sach task va cau hinh GitHub Issues Sprint 1-3`

**Assignee:** `@lam`  
**Labels:** `sprint-3`, `planning`, `backlog`, `priority:must`

**Body:**

- Loai cac task thiet lap nho khoi backlog.
- Moi task co san pham nghiem thu.
- Chia task theo Sprint 1-3.
- Chia ro Lam/Ky/Loi.
- Tong hop cong tung thanh vien.

**Done when:** `docs/TASKS.md` chi con danh sach issue Sprint 1-3 va phan cong ro cho 3 thanh vien.

## Bang chia nhanh theo thanh vien

| Thanh vien | Issues | Trong tam |
|---|---|---|
| Nguyen Viet Lam | 1, 2, 3, 4, 8, 10, 11, 16 | Quan ly du an, quy trinh, kien truc, API, backlog |
| Tran Ngoc Loi | 5, 6, 7, 9, 12, 13 | Khao sat, SRS, User Stories, Use Case, Database, SQL |
| Nguyen Dai Ky | 14, 15 | UI mockup, Test Plan, QA |

## Len GitHub nen tao milestone/label nhu sau

**Milestones:**

- Sprint 1 - Khoi dong
- Sprint 2 - Phan tich
- Sprint 3 - Thiet ke

**Labels:**

- `project-management`
- `analysis`
- `design`
- `database`
- `api`
- `ui-ux`
- `testing`
- `docs`
- `priority:must`
- `priority:should`

