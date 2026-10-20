# HUONG DAN SU DUNG HE THONG QUAN LY CUA HANG SUA CHUA
## Danh cho: Ky Thuat Vien Sua Chua (Technician)

**Du an:** LV33-001 - He thong quan ly tong the cho cua hang sua chua
**Nhom:** Nhom 11 - Lop 23DTHC6 | **Phien ban:** 1.0 | **Ngay:** 18/10/2026
**Task Jira:** MBA-81 | **Nguoi soan:** Nguyen Viet Lam (PM / Dev Lead)

---

## MUC LUC

1. Gioi thieu chung
2. Dang nhap va giao dien
3. Xem danh sach phieu duoc phan cong
4. Nhan phieu va bat dau chan doan
5. Cap nhat ket qua chan doan va bao gia
6. Tien hanh sua chua
7. Quan ly linh kien va xuat kho
8. Hoan thanh va ban giao phieu
9. Xu ly phieu bao hanh
10. Cac luu y va tinh huong thuong gap
11. Lien he ho tro

---

## 1. GIOI THIEU CHUNG

He thong quan ly cua hang sua chua ho tro ky thuat vien:
- **Tiep nhan phieu sua chua** duoc phan cong tu nhan vien quay
- **Cap nhat ket qua chan doan** va bao gia cho khach hang
- **Ghi lai qua trinh sua chua** va linh kien da su dung
- **Xuat kho linh kien** khi tien hanh sua chua
- **Cap nhat trang thai phieu** theo tien do thuc te

> **Luu y:** Tai khoan ky thuat vien co quyen **TECHNICIAN** - chi thao tac voi phieu
> duoc phan cong cho minh. Khong co quyen xem bao cao doanh thu hoac quan ly nguoi dung.

---

## 2. DANG NHAP VA GIAO DIEN

### 2.1. Dang nhap
1. Truy cap dia chi he thong (do quan ly cung cap).
2. Nhap **Ten dang nhap** va **Mat khau**.
3. Nhan **"Dang nhap"**.

### 2.2. Giao dien Dashboard cho KTV

| The thong tin | Y nghia |
|---|---|
| Phieu cho nhan | Phieu duoc phan cong, chua bat dau |
| Dang chan doan | Phieu dang o giai doan DIAGNOSING |
| Dang sua chua | Phieu dang o giai doan REPAIRING |
| Hoan thanh hom nay | Phieu da hoan tat trong ngay |
| Qua han du kien | Phieu da qua ngay hen tra nhung chua xong |

> **Meo:** Click vao the "Qua han du kien" moi buoi sang de uu tien xu ly truoc.

### 2.3. Dang xuat
Nhan ten tai khoan goc phai tren cung > **"Dang xuat"**.
> CANH BAO: **Luon dang xuat khi ket thuc ca lam viec.**

---

## 3. XEM DANH SACH PHIEU DUOC PHAN CONG

### 3.1. Truy cap danh sach phieu cua minh
1. Vao menu **"Phieu cua toi"** (hoac "Phieu sua chua" > loc theo ten minh).
2. He thong chi hien thi phieu duoc phan cong cho tai khoan dang dang nhap.

### 3.2. Bo loc phieu

| Bo loc | Mo ta |
|---|---|
| Theo trang thai | RECEIVED, DIAGNOSING, WAITING_CONFIRM, REPAIRING, COMPLETED |
| Theo ngay tiep nhan | Khoang thoi gian tu den |
| Theo tu khoa | Ma phieu, ten khach, SDT |
| Qua han | Hien thi phieu da qua ngay du kien |

### 3.3. Xem chi tiet phieu
Click vao ma phieu de xem day du:
- Thong tin khach hang va thiet bi
- Tinh trang thiet bi luc nhan va yeu cau cua khach
- Bao gia du kien (neu da dien)
- Lich su thay doi trang thai
- Danh sach linh kien da su dung

---

## 4. NHAN PHIEU VA BAT DAU CHAN DOAN

### 4.1. Khi nhan thiet bi tu nhan vien quay
1. NV quay in phieu va thong bao cho ban (hoac qua he thong).
2. Vao danh sach phieu > tim phieu trang thai **RECEIVED**.
3. Kiem tra thiet bi thuc te voi thong tin ghi trong phieu.
4. Nhan **"Bat dau chan doan"** > trang thai phieu chuyen sang **DIAGNOSING**.

> BAT BUOC nhan "Bat dau chan doan" ngay khi nhan may de ghi lai thoi diem bat dau xu ly.

### 4.2. Trong qua trinh chan doan
- Doc thong tin o phan "Tinh trang luc nhan" va "Yeu cau cua khach".
- Tien hanh kiem tra thiet bi.
- Moi phat hien quan trong > ghi vao phan **"Ghi chu ky thuat"** (nhap, chua gui khach).

---

## 5. CAP NHAT KET QUA CHAN DOAN VA BAO GIA

### 5.1. Dien ket qua chan doan
1. Mo phieu dang o trang thai **DIAGNOSING**.
2. Nhan **"Cap nhat chan doan"**.
3. Dien vao o **"Ket qua chan doan"**:
```
Vi du:
- Man hinh bi tach keo, den nen yeu
- Pin chai con 41% suc khoe
- Cong sac long, khong nhan sac on dinh
```
4. Dien **bao gia chi tiet**:

| Truong | Noi dung |
|---|---|
| Tien cong uoc tinh | Nhap so tien (VND) |
| Tien linh kien uoc tinh | Nhap so tien (VND) |
| Ghi chu bao gia | Giai thich ro cac hang muc |

5. Nhan **"Gui bao gia"** > trang thai phieu chuyen sang **WAITING_CONFIRM**.

> NV Quay se goi dien thong bao cho khach hang.
> Ban **khong can lien he truc tiep voi khach** o buoc nay.

### 5.2. Cho phan hoi tu khach
- Phieu o trang thai WAITING_CONFIRM > khong lam gi them, cho NV quay thong bao.
- Khach **dong y** > NV quay xac nhan > phieu chuyen sang **REPAIRING**.
- Khach **tu choi** > phieu bi huy > tra may cho NV quay.

---

## 6. TIEN HANH SUA CHUA

### 6.1. Bat dau sua chua
- Phieu o trang thai **REPAIRING** > bat dau sua chua thuc su.
- Cap nhat lien tuc vao phan **"Ghi chu ky thuat"** de ghi lai tien do.

### 6.2. Ghi chu tien do sua chua
Nen ghi lai theo tung buoc, vi du:
```
14:00 - Thao may, kiem tra main. Phat hien tu loc nguon bi phong.
14:30 - Dat linh kien tu kho (tu 10uF/16V). Cho xuat kho.
15:00 - Thay tu thanh cong. Test len nguon OK.
15:30 - Ve sinh board mach, lap may lai.
15:45 - Test day du cac chuc nang: OK.
```

---

## 7. QUAN LY LINH KIEN VA XUAT KHO

### 7.1. Tim linh kien trong kho
1. Vao **"Linh kien"** > **"Tim kiem linh kien"**.
2. Tim theo ten, ma linh kien, hoac danh muc.
3. Xem **so ton kho hien tai** truoc khi xuat.

### 7.2. Xuat linh kien cho phieu sua chua
1. Mo phieu dang o trang thai **REPAIRING**.
2. Nhan **"+ Them linh kien su dung"**.
3. Tim va chon linh kien.
4. Nhap **so luong** su dung.
5. Nhan **"Xac nhan xuat kho"** > ton kho tu dong giam.

> CANH BAO: **Chi xuat dung so luong thuc te su dung.**
> Linh kien da xuat ma khong dung can bao nhan vien kho de hoan tra.

### 7.3. Xem linh kien da xuat
Trong chi tiet phieu > tab **"Linh kien su dung"** > danh sach da xuat kem gia va tong tien.

### 7.4. Canh bao het ton kho
Neu linh kien can thiet het hoac sap het (mau do/vang):
1. Bao ngay cho NV quay / quan ly de dat hang nhap them.
2. Ghi vao "Ghi chu" cua phieu: "Cho nhap linh kien [ten LK]".
3. Cap nhat ngay du kien hoan thanh moi neu can.

---

## 8. HOAN THANH VA BAN GIAO PHIEU

### 8.1. Test thiet bi truoc khi ban giao

| Hang muc test | Dien thoai | Laptop | May in |
|---|---|---|---|
| Len nguon binh thuong | Co | Co | Co |
| Man hinh hien thi OK | Co | Co | - |
| Sac nhan dien | Co | Co | Co |
| Cac chuc nang chinh | Co | Co | Co |
| Linh kien vua thay hoat dong on | Co | Co | Co |
| Vo may lap dung, khong thieu oc | Co | Co | Co |

### 8.2. Danh dau hoan thanh
1. Test OK > mo phieu > nhan **"Hoan thanh sua chua"**.
2. Dien vao o **"Ket qua sua chua"**:
```
Vi du:
- Da thay tu loc nguon 10uF/16V (1 cai)
- Ve sinh board mach
- Test day du: may hoat dong binh thuong
- Thoi gian bao hanh: 30 ngay cho linh kien da thay
```
3. Nhan **"Xac nhan hoan thanh"** > trang thai phieu chuyen sang **COMPLETED**.
4. Ban giao thiet bi cho nhan vien quay (khong ban giao truc tiep cho khach).

> He thong tu thong bao cho NV quay biet phieu da xong de goi khach den lay.

### 8.3. Xac nhan gia thuc te
Neu chi phi thuc te **khac voi bao gia** ban dau:
1. Truoc khi nhan "Hoan thanh", cap nhat lai tien cong va tien linh kien thuc te.
2. Neu thay doi lon > can thong bao cho NV quay de goi khach xac nhan lai truoc.

---

## 9. XU LY PHIEU BAO HANH

### 9.1. Phieu bao hanh la gi?
Khi khach mang thiet bi da sua truoc do quay lai trong thoi gian bao hanh,
he thong tao **phieu sua bao hanh** (co lien ket voi phieu goc).

### 9.2. Nhan dang phieu bao hanh
- Phieu bao hanh co nhan **"BAO HANH"** mau xanh la trong danh sach.
- Truong IsWarrantyRepair = TRUE.
- Xem phieu goc bang cach click **"Xem phieu goc"**.

### 9.3. Quy trinh xu ly
1. Kiem tra phieu bao hanh: xem lai phieu goc, linh kien da thay, ket qua goc.
2. Xac dinh nguyen nhan: loi ky thuat tu lan truoc hay do tac dong ben ngoai?
3. Tien hanh sua > **khong tinh them phi** neu loi thuoc pham vi bao hanh.
4. Loi do ngoai luc (vo, tham nuoc...) > bao NV quay thong bao khach, tinh phi binh thuong.
5. Hoan thanh tuong tu phieu thuong.

> CANH BAO: **Phieu bao hanh phai duoc xu ly uu tien** so voi cac phieu moi cung muc do.

---

## 10. CAC LUU Y VA TINH HUONG THUONG GAP

**May sua khong duoc, can tra lai khach:**
1. Ghi ro vao "Ket qua chan doan" nhung gi da thu va ly do khong sua duoc.
2. Bao NV quay > NV quay se lien he khach va huy phieu.
3. **Khong tu huy phieu** - chi NV quay hoac admin moi huy duoc.

**Can linh kien khong co trong kho:**
1. Ghi vao phan ghi chu phieu: "Can nhap linh kien [ten LK, so luong]".
2. Bao quan ly/nhan vien kho de dat hang.
3. Cap nhat ngay du kien hoan thanh moi vao phieu.

**Phat hien them hu hong nam ngoai bao gia ban dau:**
1. Dung sua ngay phan moi phat hien.
2. Ghi vao phieu va bao NV quay > NV quay goi khach xac nhan bo sung > moi tiep tuc.

**Sua xong nhung quen xuat linh kien:**
1. Mo phieu > vao tab "Linh kien su dung" > them linh kien con thieu.
2. Chi thao tac duoc khi phieu chua o trang thai DELIVERED. Neu da DELIVERED > bao admin.

**Thiet bi hu them trong qua trinh sua:**
Bao quan ly ngay lap tuc. Ghi day du vao phieu. Day la su co nghiem trong.

**Khach goi dien truc tiep hoi tien do:**
Khong trao doi bao gia truc tiep voi khach. Chuyen qua NV quay de tra loi chinh thuc.

---

## So Do Tom Tat Quy Trinh KTV

```
Nhan phieu (RECEIVED)
      |
Bat dau chan doan -> [DIAGNOSING]
      |
Ghi ket qua + bao gia -> Gui cho NV quay -> [WAITING_CONFIRM]
      |
Khach dong y -> [REPAIRING]
      |
Sua chua + xuat linh kien
      |
Test -> ghi ket qua -> [COMPLETED]
      |
Ban giao cho NV quay -> NV quay thu tien -> [DELIVERED]
```

---

## 11. LIEN HE HO TRO

| Van de | Lien he |
|---|---|
| Khong dang nhap duoc, mat mat khau | Quan ly hoac Admin he thong |
| Loi khi cap nhat phieu, xuat kho | Nhom ky thuat Nhom 11 |
| Can nhap linh kien gap | Quan ly kho / Quan ly cua hang |
| Van de voi khach hang | Nhan vien quay xu ly |

> CANH BAO: **Khong tu y can thiep vao he thong hoac sua du lieu truc tiep.**
> CANH BAO: **Moi thao tac deu duoc ghi log - hay thao tac chinh xac va trung thuc.**

---
*Tai lieu du an LV33-001 - Nhom 11, Lop 23DTHC6. Phien ban 1.0 - 10/2026.*