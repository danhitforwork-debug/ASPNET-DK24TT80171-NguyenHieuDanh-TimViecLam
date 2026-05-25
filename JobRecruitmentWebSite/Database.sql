IF DB_ID('JobRecruitmentDb') IS NOT NULL
BEGIN
 ALTER DATABASE JobRecruitmentDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
 DROP DATABASE JobRecruitmentDb;
END
GO
CREATE DATABASE JobRecruitmentDb;
GO
USE JobRecruitmentDb;
GO
CREATE TABLE Users(UserId INT IDENTITY PRIMARY KEY,Username NVARCHAR(50) UNIQUE NOT NULL,Password NVARCHAR(50) NOT NULL,FullName NVARCHAR(100),RoleName NVARCHAR(20) NOT NULL);
CREATE TABLE Categories(CategoryId INT IDENTITY PRIMARY KEY,CategoryName NVARCHAR(100) NOT NULL);
CREATE TABLE Provinces(ProvinceId INT IDENTITY PRIMARY KEY,ProvinceName NVARCHAR(100) NOT NULL);
CREATE TABLE JobTypes(JobTypeId INT IDENTITY PRIMARY KEY,JobTypeName NVARCHAR(100) NOT NULL);
CREATE TABLE Jobs(JobId INT IDENTITY PRIMARY KEY,Title NVARCHAR(200) NOT NULL,CategoryId INT NOT NULL,ProvinceId INT NOT NULL,JobTypeId INT NOT NULL,CompanyName NVARCHAR(200) NOT NULL,Salary NVARCHAR(100),Description NVARCHAR(MAX),CreatedDate DATETIME DEFAULT GETDATE());
CREATE TABLE Applications(ApplicationId INT IDENTITY PRIMARY KEY,JobId INT NOT NULL,FullName NVARCHAR(100) NOT NULL,Phone NVARCHAR(30),Email NVARCHAR(100),CvFile NVARCHAR(255),ApplyDate DATETIME DEFAULT GETDATE());
GO
INSERT INTO Users VALUES('admin','admin123',N'Quản trị viên','Admin'),('user','user123',N'Người dùng thường','User');
INSERT INTO Categories VALUES(N'Công nghệ thông tin'),(N'Kế toán'),(N'Bán hàng'),(N'Giao nhận - Kho vận'),(N'Chăm sóc khách hàng');
INSERT INTO Provinces VALUES(N'TP. Hồ Chí Minh'),(N'Bà Rịa - Vũng Tàu'),(N'Đồng Nai'),(N'Bình Dương'),(N'Hà Nội');
INSERT INTO JobTypes VALUES(N'Toàn thời gian'),(N'Bán thời gian'),(N'Thực tập'),(N'Làm theo ca');
INSERT INTO Jobs(Title,CategoryId,ProvinceId,JobTypeId,CompanyName,Salary,Description) VALUES
(N'Tuyển nhân viên IT hỗ trợ hệ thống',1,1,1,N'Công ty ABC',N'10 - 15 triệu',N'Hỗ trợ người dùng, xử lý lỗi máy tính, mạng, phần mềm.'),
(N'Tuyển nhân viên giao nhận',4,2,1,N'Công ty Logistics Việt',N'8 - 12 triệu',N'Giao nhận hàng hóa, cập nhật trạng thái đơn hàng.'),
(N'Tuyển thực tập sinh kế toán',2,1,3,N'Công ty Tài Chính Xanh',N'Thỏa thuận',N'Hỗ trợ nhập liệu chứng từ, báo cáo đơn giản.');
GO
SELECT * FROM Users; SELECT * FROM Jobs;
-- INSERT INTO Categories(CategoryName) VALUES (N'Nhân sự');
-- UPDATE Jobs SET Salary=N'12 - 18 triệu' WHERE JobId=1;
-- DELETE FROM Applications WHERE ApplicationId=1;
