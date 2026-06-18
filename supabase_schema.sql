-- FILE: supabase_schema.sql
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard/project/_/sql)

-- Drop existing tables if they exist to avoid column schema conflicts
DROP TABLE IF EXISTS public.checkins CASCADE;
DROP TABLE IF EXISTS public.settings CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.files CASCADE;
DROP TABLE IF EXISTS public.calculations CASCADE;
DROP TABLE IF EXISTS public.logbooks CASCADE;
DROP TABLE IF EXISTS public.trees CASCADE;
DROP TABLE IF EXISTS public.plots CASCADE;
DROP TABLE IF EXISTS public.projects CASCADE;
DROP TABLE IF EXISTS public.owners CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- 1. Tạo bảng users
CREATE TABLE IF NOT EXISTS public.users (
    id text PRIMARY KEY,
    "fullName" text NOT NULL,
    email text UNIQUE NOT NULL,
    phone text,
    role text NOT NULL, -- platform_admin, forest_owner, forest_worker
    status text DEFAULT 'active', -- active, locked
    password text NOT NULL
);

-- 2. Tạo bảng owners
CREATE TABLE IF NOT EXISTS public.owners (
    code text PRIMARY KEY,
    name text NOT NULL,
    type text NOT NULL,
    "regNo" text,
    phone text,
    email text,
    province text,
    status text DEFAULT 'active',
    "totalProjects" integer DEFAULT 0,
    "totalArea" numeric DEFAULT 0
);

-- 3. Tạo bảng projects
CREATE TABLE IF NOT EXISTS public.projects (
    code text PRIMARY KEY,
    name text NOT NULL,
    "ownerCode" text REFERENCES public.owners(code) ON DELETE SET NULL,
    "ownerName" text,
    province text,
    district text,
    commune text,
    area numeric NOT NULL,
    "forestType" text,
    "treeSpecies" text,
    "yearPlanted" integer,
    status text DEFAULT 'draft',
    lat numeric,
    lng numeric
);

-- 4. Tạo bảng plots
CREATE TABLE IF NOT EXISTS public.plots (
    code text PRIMARY KEY,
    "projectCode" text REFERENCES public.projects(code) ON DELETE SET NULL,
    area numeric,
    elevation numeric,
    lat numeric,
    lng numeric,
    status text DEFAULT 'active'
);

-- 5. Tạo bảng trees
CREATE TABLE IF NOT EXISTS public.trees (
    id bigserial PRIMARY KEY,
    "plotCode" text REFERENCES public.plots(code) ON DELETE CASCADE,
    species text NOT NULL,
    dbh numeric NOT NULL,
    height numeric NOT NULL,
    quantity integer NOT NULL
);

-- 6. Tạo bảng logbooks
CREATE TABLE IF NOT EXISTS public.logbooks (
    id text PRIMARY KEY,
    date text NOT NULL,
    type text NOT NULL,
    "user" text NOT NULL,
    project text NOT NULL,
    location text,
    lat numeric,
    lng numeric,
    photos integer DEFAULT 0,
    "desc" text,
    synced boolean DEFAULT true,
    images text[] -- Danh sách URLs ảnh trên Supabase Storage
    ,
    job_type text,
    description text,
    latitude numeric,
    longitude numeric,
    timestamp text,
    user_id text,
    user_name text,
    project_id text
);

-- 7. Tạo bảng calculations
CREATE TABLE IF NOT EXISTS public.calculations (
    code text PRIMARY KEY,
    project text NOT NULL,
    date text NOT NULL,
    method text NOT NULL,
    biomass numeric,
    carbon numeric,
    co2e numeric,
    status text DEFAULT 'draft'
);

-- 8. Tạo bảng files
CREATE TABLE IF NOT EXISTS public.files (
    id bigserial PRIMARY KEY,
    name text NOT NULL,
    category text NOT NULL,
    project text NOT NULL,
    uploader text NOT NULL,
    date text NOT NULL,
    size text,
    url text NOT NULL
);

-- 9. Tạo bảng notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id bigserial PRIMARY KEY,
    type text NOT NULL,
    title text NOT NULL,
    "desc" text NOT NULL,
    "time" text NOT NULL,
    read boolean DEFAULT false
);

-- 10. Tạo bảng settings
CREATE TABLE IF NOT EXISTS public.settings (
    key text PRIMARY KEY,
    factors jsonb NOT NULL
);

-- 11. Tạo bảng checkins
CREATE TABLE IF NOT EXISTS public.checkins (
    id bigserial PRIMARY KEY,
    user_id text NOT NULL,
    user_name text NOT NULL,
    latitude numeric NOT NULL,
    longitude numeric NOT NULL,
    timestamp text NOT NULL,
    type text NOT NULL,
    note text,
    project_id text
);

-- =========================================================================
-- HẠT GIỐNG DỮ LIỆU (SEED DATA)
-- =========================================================================

-- 1. Chèn cài đặt mặc định
INSERT INTO public.settings (key, factors) VALUES 
('speciesFactors', '[{"species":"Keo Lai", "factor":0.48}, {"species":"Bạch đàn", "factor":0.47}, {"species":"Thông", "factor":0.50}]'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- 2. Chèn danh sách users hệ thống
INSERT INTO public.users (id, "fullName", email, phone, role, status, password) VALUES
('admin@qlr.vn', 'Admin Platform', 'admin@qlr.vn', '0900 000 001', 'platform_admin', 'active', '123456'),
('owner@qlr.vn', 'Nguyễn Văn A', 'owner@qlr.vn', '0901 234 567', 'forest_owner', 'active', '123456'),
('worker@qlr.vn', 'Trần Thị B', 'worker@qlr.vn', '0905 111 222', 'forest_worker', 'active', '123456')
ON CONFLICT (id) DO NOTHING;

-- 3. Chèn danh sách chủ rừng (owners)
INSERT INTO public.owners (code, name, type, "regNo", phone, email, province, status, "totalProjects", "totalArea") VALUES
('OWN-0001', 'Nguyễn Văn A', 'Individual', '123456789012', '0901 234 567', 'nguyenvana@email.com', 'Lâm Đồng', 'active', 3, 1250.50),
('OWN-0002', 'Lê Thị B', 'Individual', '987654321098', '0912 345 678', NULL, 'Đắk Lắk', 'active', 1, 980.75),
('OWN-0003', 'Công ty TNHH Rừng Vàng', 'Company', '0401234587', '0567 234 567', NULL, 'Đắk Lắk', 'active', 2, 1320.30)
ON CONFLICT (code) DO NOTHING;

-- 4. Chèn danh sách dự án (projects)
INSERT INTO public.projects (code, name, "ownerCode", "ownerName", province, district, commune, area, "forestType", "treeSpecies", "yearPlanted", status, lat, lng) VALUES
('PRJ-0001', 'Dak Lak Project 01', 'OWN-0001', 'Nguyễn Văn A', 'Đắk Lắk', 'Krông Bông', 'Hòa Phong', 1250.50, 'Rừng trồng', 'Keo Lai', 2020, 'active', 12.6, 108.25),
('PRJ-0002', 'Lam Dong Project 02', 'OWN-0001', 'Nguyễn Văn A', 'Lâm Đồng', 'Di Linh', 'Tân Châu', 980.75, 'Rừng trồng', 'Bạch đàn', 2019, 'active', 11.58, 108.07),
('PRJ-0003', 'Gia Lai Project 01', 'OWN-0003', 'Công ty TNHH Rừng Vàng', 'Gia Lai', 'Chư Sê', 'Ia Pal', 1320.30, 'Rừng tự nhiên', 'Thông', 2018, 'active', 13.65, 108.05)
ON CONFLICT (code) DO NOTHING;

-- 5. Chèn các ô đo đếm mẫu (plots)
INSERT INTO public.plots (code, "projectCode", area, elevation, lat, lng, status) VALUES
('PLT-0001', 'PRJ-0001', 500, 600, 12.345678, 108.234567, 'active'),
('PLT-0002', 'PRJ-0002', 500, 665, 11.234567, 107.123456, 'active')
ON CONFLICT (code) DO NOTHING;

-- 6. Chèn dữ liệu cây đo đếm (trees)
INSERT INTO public.trees (id, "plotCode", species, dbh, height, quantity) VALUES
(1, 'PLT-0001', 'Keo Lai', 18, 12, 150),
(2, 'PLT-0001', 'Bạch đàn', 15, 10, 60),
(3, 'PLT-0002', 'Bạch đàn', 16, 11, 140)
ON CONFLICT (id) DO NOTHING;
SELECT setval('public.trees_id_seq', COALESCE((SELECT MAX(id) FROM public.trees), 1));

-- 7. Chèn nhật ký công việc (logbooks)
INSERT INTO public.logbooks (id, date, type, "user", project, location, lat, lng, photos, "desc", synced, images, job_type, description, latitude, longitude, timestamp, user_id, user_name, project_id) VALUES
('LOG-1001', '2024-05-20', 'Trồng cây', 'Nguyễn Văn A', 'Dak Lak Project 01', 'Đắk Lắk', 12.345678, 108.234567, 0, 'Trồng bổ sung 150 cây Keo Lai tại lô PLT-0001.', true, ARRAY[]::text[], 'planting', 'Trồng bổ sung 150 cây Keo Lai tại lô PLT-0001.', 12.345678, 108.234567, '2024-05-20T00:00:00Z', 'owner@qlr.vn', 'Nguyễn Văn A', 'PRJ-0001'),
('LOG-1002', '2024-05-19', 'Bảo dưỡng', 'Trần Thị B', 'Lam Dong Project 02', 'Lâm Đồng', 11.234567, 107.123456, 0, 'Phát quang dây leo, dọn cỏ quanh gốc khu vực lô B2.', true, ARRAY[]::text[], 'care', 'Phát quang dây leo, dọn cỏ quanh gốc khu vực lô B2.', 11.234567, 107.123456, '2024-05-19T00:00:00Z', 'worker@qlr.vn', 'Trần Thị B', 'PRJ-0002')
ON CONFLICT (id) DO NOTHING;

-- 8. Chèn các tính toán Carbon mẫu (calculations)
INSERT INTO public.calculations (code, project, date, method, biomass, carbon, co2e, status) VALUES
('CAL-0001', 'Dak Lak Project 01', '2024-05-20', 'IPCC Tier 1', 125000, 60000, 220200, 'approved'),
('CAL-0002', 'Lam Dong Project 02', '2024-05-19', 'IPCC Tier 1', 98000, 46000, 168780, 'approved')
ON CONFLICT (code) DO NOTHING;

-- 9. Chèn các file tài liệu đính kèm (files)
INSERT INTO public.files (id, name, category, project, uploader, date, size, url) VALUES
(1, 'Quyet_dinh_phe_duyet_PRJ01.pdf', 'Hồ sơ pháp lý', 'Dak Lak Project 01', 'Admin Platform', '2024-05-18', '2.4 MB', '#'),
(2, 'Bao_cao_khao_sat_LamDong.docx', 'Báo cáo khảo sát', 'Lam Dong Project 02', 'Trần Thị B', '2024-05-19', '4.1 MB', '#')
ON CONFLICT (id) DO NOTHING;
SELECT setval('public.files_id_seq', COALESCE((SELECT MAX(id) FROM public.files), 1));

-- 10. Chèn thông báo hệ thống (notifications)
INSERT INTO public.notifications (id, type, title, "desc", "time", read) VALUES
(1, 'logbook', 'Nhật ký mới', 'Trần Thị B vừa gửi nhật ký "Bảo dưỡng" tại Lam Dong Project 02', '2 giờ trước', false),
(2, 'project', 'Dự án mới', 'Dak Lak Project 02 đã được tạo, trạng thái Draft', '5 giờ trước', false)
ON CONFLICT (id) DO NOTHING;
SELECT setval('public.notifications_id_seq', COALESCE((SELECT MAX(id) FROM public.notifications), 1));

-- Tắt Row Level Security (RLS) cho tất cả các bảng để tiện kết nối trực tiếp
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.owners DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.plots DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.trees DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.logbooks DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.calculations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.files DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.checkins DISABLE ROW LEVEL SECURITY;
