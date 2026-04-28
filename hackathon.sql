create database gym_management;
use gym_management;

-- Tạo 4 bảng Members, Trainers, Classes, Enrollments với đúng cấu trúc, kiểu dữ liệu, khóa chính, khóa ngoại.
create table members (
	 member_id varchar(5) primary key not null,
     full_name varchar(100) not null,
     email varchar(100) not null unique,
     phone varchar(15) not null,
     membership_type varchar(50) not null,
     join_date date not null
);

create table trainers (
	trainer_id varchar(5) primary key not null,
    full_name varchar (100) not null,
    specialty varchar(100) not null,
    experience int not null,
    salary decimal(12,2) not null
);

-- Thêm ràng buộc cho cột fee trong bảng Classes: học phí phải >= 0
create table classes (
	class_id varchar(5) primary key not null,
    class_name varchar(100) not null unique,
    trainer_id varchar(5) not null,
    schedule_time datetime not null,
    max_capacity int not null,
    fee decimal(10,2) not null check (fee >= 0),
    foreign key (trainer_id) references trainers(trainer_id)
);


-- Thêm ràng buộc UNIQUE cho cặp (class_id, member_id) (một thành viên không được đăng ký 2 lần cùng một lớp).
create table enrollments (
	enrollment_id int primary key not null auto_increment,
    class_id varchar(5)not null,
    member_id varchar(5) not null,
    status varchar(20) not null default 'Pending',
    enroll_date date not null,
    foreign key (class_id) references classes (class_id),
    foreign key (member_id) references members (member_id),
    unique (class_id, member_id)
);

-- Chèn dữ liệu
insert into members 
values
	('M01', 'Nguyễn Văn An', 'an.nguyen@gmail.com', '0912345678', 'Premium', '2025-01-15'),
	('M02', 'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', 'VIP', '2025-02-20'),
	('M03', 'Lê Hoàng Cường', 'cuong.le@gmail.com', '0978123456', 'Basic', '2025-03-10'),
	('M04', 'Phạm Minh Dũng', 'dung.pham@gmail.com', '0909876543', 'Premium', '2025-04-05');
    
insert into trainers 
values
	('T01', 'Coach Alex', 'Strength Training', 8, 25000000),
	('T02', 'Huấn luyện viên Lan', 'Yoga & Pilates', 6, 18000000),
	('T03', 'Coach Minh', 'Functional Fitness', 10, 30000000);
    
insert into classes 
values 
	('C01', 'Morning Strength', 'T01', '2025-11-10 06:30:00', 20, 150000),
    ('C02', 'Yoga Flow', 'T02', '2025-11-10 17:30:00', 15, 120000),
    ('C03', 'HIIT Burn', 'T03', '2025-11-11 18:00:00', 18, 180000),
    ('C04', 'Power Lifting', 'T01', '2025-11-12 07:00:00', 12, 200000);
    
insert into enrollments (enrollment_id, class_id, member_id, status, enroll_date)
values
	(1, 'C01', 'M01', 'Comfirmed', '2025-11-01'),
    (2, 'C02', 'M02', 'Comfirmed', '2025-11-02'),
    (3, 'C01', 'M03', 'Canceled', '2025-11-03'),
    (4, 'C04', 'M01', 'Comfirmed', '2025-11-05'),
    (5, 'C03', 'M04', 'Pending', '2025-11-06');

-- Lớp C03 (HIIT Burn) có nhu cầu cao → tăng học phí (fee) thêm 20%
update classes 
set fee = fee * 1.2
where class_id = 'C03';

-- Cập nhật membership_type của thành viên M02 thành 'VIP Elite'
update members
set membership_type = 'VIP Elite'
where member_id = 'M02';

-- Xóa tất cả các đơn đăng ký có trạng thái 'Canceled'
delete from enrollments
where status = 'Canceled';

-- Thiết lập giá trị mặc định cho cột status trong bảng Enrollments là 'Pending'
alter table enrollments
alter status set default 'Pending';

-- Thêm cột gender (VARCHAR(10)) vào bảng Members sau khi tạo bảng (giá trị có thể là 'Male', 'Female', 'Other')
alter table members
add gender varchar(10);

-- Liệt kê tất cả các lớp học có chuyên môn liên quan đến "Strength" hoặc "Fitness"
select *
from classes c
join trainers t on c.trainer_id = t.trainer_id
where t.specialty like '%Strength%' or t.specialty like '%Fitness%';

-- Lấy thông tin full_name, email của những thành viên có tên chứa ký tự 'n'
select full_name, email
from members
where full_name like '%n%';

-- Hiển thị danh sách các lớp học gồm class_id, class_name, schedule_time, sắp xếp theo schedule_time tăng dần
select class_id, class_name, schedule_time
from classes 
order by schedule_time asc;

-- Lấy ra 3 lớp học có học phí (fee) thấp nhất
select *
from classes
order by fee asc
limit 3;

-- Hiển thị class_name, specialty từ bảng Classes và Trainers, bỏ qua lớp đầu tiên và lấy 2 lớp tiếp theo
select c.class_name, t.specialty
from classes c
join trainers t on c.trainer_id = t.trainer_id
limit 2 offset 1;

-- Giảm 15% học phí cho tất cả các lớp học diễn ra vào buổi sáng (trước 12:00)
update classes 
set fee = fee * 0.85
where hour(schedule_time) < 12;

-- Chuyển đổi toàn bộ full_name của thành viên trong bảng Members thành chữ in hoa
update members
set full_name = upper(full_name);

-- Xóa tất cả các lớp học có học phí bằng 0 (nếu có) và đảm bảo xử lý ràng buộc khóa ngoại với bảng Enrollments
delete from classes
where fee = 0;

-- Hiển thị enrollment_id, full_name (thành viên), class_name, full_name →  thay bằng trainer_full_name của các đơn đăng ký có trạng thái 'Confirmed'
select e.enrollment_id, m.full_name, c.class_name, t.full_name trainer_full_name
from enrollments e
join members m on e.member_id = m.member_id
join classes c on e.class_id = c.class_id
join trainers t on c.trainer_id = t.trainer_id
where e.status = 'Confirmed';

-- Liệt kê tất cả các lớp học (class_name) và thời gian (schedule_time) tương ứng. Hiển thị cả những lớp chưa có thành viên nào đăng ký
select c.class_name, c.schedule_time
from classes c
left join enrollments e on c.class_id = e.class_id;

-- Tính tổng số đơn đăng ký theo từng trạng thái (status)
select status, count(*) total
from enrollments
group by status;

-- Thống kê số lượng lớp học mà mỗi thành viên đã đăng ký. Chỉ hiển thị những thành viên đăng ký từ 2 lớp trở lên
select m.full_name, count(e.class_id) total_class
from members m
join enrollments e on m.member_id = e.member_id
group by m.member_id, m.full_name
having count(e.class_id) >= 2;

-- Lấy thông tin các lớp học có học phí thấp hơn học phí trung bình của tất cả các lớp
select *
from classes
where fee < (select avg(fee)
			 from classes);
             
select m.full_name, m.membership_type
from members m
join enrollments e on m.member_id = e.member_id
join classes c on e.class_id = c.class_id
where c.class_name = 'Morning Strength';

-- Liệt kê danh sách các lớp học diễn ra trong tháng 11 năm 2025
select *
from classes
where month(schedule_time) = 11 and year(schedule_time) = 2025;