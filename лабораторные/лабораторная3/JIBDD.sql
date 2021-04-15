	USE master

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KN301_Borodina'
)
ALTER DATABASE [KN301_Borodina] set single_user with rollback immediate
GO

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KN301_Borodina'
)
DROP DATABASE [KN301_Borodina]
GO

CREATE DATABASE [KN301_Borodina]
GO

USE [KN301_Borodina]
GO

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'TableOfregions'
) 
 DROP SCHEMA TableOfregions
GO

CREATE SCHEMA TableOfregions 
GO

IF OBJECT_ID('[KN301_Borodina].TableOfregions.regions', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].TableOfregions.regions
GO


CREATE TABLE [KN301_Borodina].TableOfregions.regions
(
	Number_region int NOT NULL,
	Region nvarchar(50) NULL, 
    CONSTRAINT PK_Number_region PRIMARY KEY (Number_region) 
)
GO

CREATE TABLE [KN301_Borodina].TableOfregions.numbers_of_regions
(
	Number_region int  NOT NULL, 
	Second_number_region int NULL
)
GO

ALTER TABLE [KN301_Borodina].TableOfregions.numbers_of_regions ADD 
	CONSTRAINT FK_Number_region FOREIGN KEY (Number_region) 
	REFERENCES [KN301_Borodina].TableOfregions.regions(Number_region)
	ON UPDATE CASCADE 
GO	

INSERT INTO [KN301_Borodina].TableOfregions.regions
 (Region, Number_region)
 VALUES 
 (N'������������ �������', 66)
 ,(N'����������� �������', 74)
 ,(N'���������� ��������', 02)
 ,(N'������', 77)	
GO

--SELECT * From [KN301_Borodina].TableOfregions.regions

INSERT INTO [KN301_Borodina].TableOfregions.numbers_of_regions
 VALUES 
 (66, 66)
 ,(66, 96)
 ,(66, 196)
 ,(74, 74)
 ,(74, 174)
 ,(02, 02)
 ,(02, 102)
 ,(02, 702)
 ,(77, 77)
GO

--SELECT * From [KN301_Borodina].TableOfregions.numbers_of_regions

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'Registor_cars'
) 
 DROP SCHEMA Registor_cars
GO

CREATE SCHEMA Registor_cars 
GO

IF OBJECT_ID('[KN301_Borodina].Registor_cars.zurnal', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Registor_cars.zurnal
GO


CREATE TABLE [KN301_Borodina].Registor_cars.zurnal
(
	Number_auto nvarchar(10) NOT NULL,
	Post tinyint NULL,
	Napravlenie_Dvigenia tinyint NULL,
	Time_Dvigenia time (0) Null 
)
GO

IF OBJECT_ID ('trigger_cars','TR') IS NOT NULL
   DROP TRIGGER trigger_cars 
GO

CREATE TRIGGER trigger_cars
   ON  [KN301_Borodina].Registor_cars.zurnal
	INSTEAD OF INSERT
AS
IF NOT EXISTS
(
 SELECT *
 FROM Registor_cars.zurnal,inserted
 WHERE Registor_cars.zurnal.Number_auto=inserted.Number_auto
)
	BEGIN
		IF NOT EXISTS
		(SELECT * FROM inserted
		WHERE UPPER(SUBSTRING(Number_auto, 1, 1)) LIKE N'%[ABEKMHOPCTYX������������]%' 
			AND SUBSTRING(Number_auto, 2, 3) LIKE '%[0-9][0-9][0-9]%' AND CONVERT(int,SUBSTRING(Number_auto, 2, 3)) > 0
			AND UPPER(SUBSTRING(Number_auto, 5, 2)) LIKE N'%[ABEKMHOPCTYX������������][ABEKMHOPCTYX������������]%'
			AND ((LEN(Number_auto) = 8 
		AND SUBSTRING(Number_auto, 7, 2) LIKE '%[0-9][0-9]%' 
		AND CONVERT(int,SUBSTRING(Number_auto, 7, 2)) > 0)
		OR (LEN(Number_auto) = 9 
		AND SUBSTRING(Number_auto, 7, 1) LIKE '%[127]%' 
		AND SUBSTRING(Number_auto, 8, 2) LIKE '%[0-9][0-9]%' 
		AND CONVERT(int,SUBSTRING(Number_auto, 8, 2)) > 0)))
		BEGIN
		PRINT '������������ ������ ������'
		END

		IF EXISTS
		(SELECT * FROM inserted
		WHERE 
		(LEN(Number_auto) = 8
		AND SUBSTRING(Number_auto, 7, 2) LIKE '%[0-9][0-9]%' 
		AND CONVERT(int,SUBSTRING(Number_auto, 7, 2)) NOT IN 
		(SELECT Second_number_region 
		FROM TableOfregions.numbers_of_regions))
		OR (LEN(Number_auto) = 9 
		AND SUBSTRING(Number_auto, 7, 1) LIKE '%[127]%'
		AND SUBSTRING(Number_auto, 7, 2) LIKE '%[0-9][0-9]%' 
		AND CONVERT(int,SUBSTRING(Number_auto, 7, 3)) NOT IN 
		(SELECT Second_number_region 
		FROM TableOfregions.numbers_of_regions))	
		)
		BEGIN
		PRINT '������ ������ ��� � ����������� '
		END

		INSERT INTO Registor_cars.zurnal SELECT * FROM inserted
		WHERE UPPER(SUBSTRING(Number_auto, 1, 1)) LIKE N'%[ABEKMHOPCTYX������������]%' 
			AND SUBSTRING(Number_auto, 2, 3) LIKE '%[0-9][0-9][0-9]%' AND CONVERT(int,SUBSTRING(Number_auto, 2, 3)) > 0
			AND UPPER(SUBSTRING(Number_auto, 5, 2)) LIKE N'%[ABEKMHOPCTYX������������][ABEKMHOPCTYX������������]%'
			AND ((LEN(Number_auto) = 8 
		AND SUBSTRING(Number_auto, 7, 2) LIKE '%[0-9][0-9]%' 
		AND CONVERT(int,SUBSTRING(Number_auto, 7, 2)) > 0
		AND CONVERT(int,SUBSTRING(Number_auto, 7, 2)) IN 
		(SELECT Second_number_region 
		FROM TableOfregions.numbers_of_regions))
		OR (LEN(Number_auto) = 9 
		AND SUBSTRING(Number_auto, 7, 1) LIKE '%[127]%' 
		AND SUBSTRING(Number_auto, 8, 2) LIKE '%[0-9][0-9]%' 
		AND CONVERT(int,SUBSTRING(Number_auto, 8, 2)) > 0)
		AND CONVERT(int,SUBSTRING(Number_auto, 7, 3)) IN 
		(SELECT Second_number_region 
		FROM TableOfregions.numbers_of_regions))	
	END
ELSE
	BEGIN
		IF EXISTS(SELECT inserted.* FROM inserted
		WHERE (DATEDIFF(MINUTE,(SELECT TOP 1 Registor_cars.zurnal.Time_Dvigenia 
		FROM Registor_cars.zurnal 
		WHERE inserted.Number_auto = Registor_cars.zurnal.Number_auto 
		ORDER BY Registor_cars.zurnal.Time_Dvigenia DESC),inserted.Time_Dvigenia) <5))
		BEGIN
		PRINT '������ 5 ����� � ��������� ������'
		END

		IF EXISTS
		(SELECT inserted.* FROM inserted
		WHERE (SELECT TOP 1 Registor_cars.zurnal.Napravlenie_Dvigenia 
		FROM Registor_cars.zurnal 
		WHERE inserted.Number_auto = Registor_cars.zurnal.Number_auto 
		ORDER BY Registor_cars.zurnal.Time_Dvigenia DESC) = inserted.Napravlenie_Dvigenia)
		BEGIN
		PRINT '������������ ����������� ��������'
		END

		INSERT INTO Registor_cars.zurnal 
		SELECT inserted.* FROM inserted
		WHERE --inserted.Number_auto NOT IN(
		--SELECT Number_auto 
		--FROM Registor_cars.zurnal) 
		--OR 
		(DATEDIFF(MINUTE,(SELECT TOP 1 Registor_cars.zurnal.Time_Dvigenia 
		FROM Registor_cars.zurnal 
		WHERE inserted.Number_auto = Registor_cars.zurnal.Number_auto 
		ORDER BY Registor_cars.zurnal.Time_Dvigenia DESC),inserted.Time_Dvigenia) >=5
		AND (SELECT TOP 1 Registor_cars.zurnal.Napravlenie_Dvigenia 
		FROM Registor_cars.zurnal 
		WHERE inserted.Number_auto = Registor_cars.zurnal.Number_auto 
		ORDER BY Registor_cars.zurnal.Time_Dvigenia DESC) != inserted.Napravlenie_Dvigenia)
		
	END
GO

CREATE VIEW transit AS
SELECT a.Number_auto AS '����� ����', a.Time_Dvigenia AS '����� ������', MIN(b.Time_Dvigenia) AS '����� ������' , 
(SELECT TableOfregions.regions.Region
FROM TableOfregions.regions
WHERE TableOfregions.regions.Number_region =
(SELECT TableOfregions.numbers_of_regions.Number_region 
FROM TableOfregions.numbers_of_regions
WHERE  (LEN(a.Number_auto) = 8 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 2)) = TableOfregions.numbers_of_regions.Second_number_region)
OR (LEN(a.Number_auto) = 9 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 3)) = TableOfregions.numbers_of_regions.Second_number_region))) AS '������'
FROM Registor_cars.zurnal a, Registor_cars.zurnal b
WHERE a.Number_auto = b.Number_auto
AND b.Time_Dvigenia = 
(SELECT TOP 1 c.Time_Dvigenia 
FROM Registor_cars.zurnal c 
WHERE a.Number_auto = c.Number_auto 
AND b.Napravlenie_Dvigenia = c.Napravlenie_Dvigenia
AND (DATEDIFF(MINUTE, a.Time_Dvigenia, c.Time_Dvigenia) > 0)
ORDER BY c.Time_Dvigenia)
AND a.Napravlenie_Dvigenia = 1 
AND b.Napravlenie_Dvigenia = 0 
AND a.Post != b.Post
AND'������������ �������' !=
(SELECT TableOfregions.regions.Region
FROM TableOfregions.regions
WHERE TableOfregions.regions.Number_region =
(SELECT TableOfregions.numbers_of_regions.Number_region 
FROM TableOfregions.numbers_of_regions
WHERE  (LEN(a.Number_auto) = 8 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 2)) = TableOfregions.numbers_of_regions.Second_number_region)
OR (LEN(a.Number_auto) = 9 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 3)) = TableOfregions.numbers_of_regions.Second_number_region)))
GROUP BY a.Number_auto, a.Time_Dvigenia
GO

CREATE VIEW domashnie AS
SELECT a.Number_auto AS '����� ����', a.Time_Dvigenia AS '����� ������', MIN(b.Time_Dvigenia) AS '����� ������', 
(SELECT TableOfregions.regions.Region
FROM TableOfregions.regions
WHERE TableOfregions.regions.Number_region =
(SELECT TableOfregions.numbers_of_regions.Number_region 
FROM TableOfregions.numbers_of_regions
WHERE  (LEN(a.Number_auto) = 8 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 2)) = TableOfregions.numbers_of_regions.Second_number_region)
OR (LEN(a.Number_auto) = 9 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 3)) = TableOfregions.numbers_of_regions.Second_number_region))) AS '������'
FROM Registor_cars.zurnal a, Registor_cars.zurnal b
WHERE a.Number_auto = b.Number_auto 
AND a.Napravlenie_Dvigenia = 0 
AND b.Napravlenie_Dvigenia = 1 
AND (DATEDIFF(MINUTE, a.Time_Dvigenia, b.Time_Dvigenia) > 0)
AND'������������ �������' =
(SELECT TableOfregions.regions.Region
FROM TableOfregions.regions
WHERE TableOfregions.regions.Number_region =
(SELECT TableOfregions.numbers_of_regions.Number_region 
FROM TableOfregions.numbers_of_regions
WHERE  (LEN(a.Number_auto) = 8 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 2)) = TableOfregions.numbers_of_regions.Second_number_region)
OR (LEN(a.Number_auto) = 9 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 3)) = TableOfregions.numbers_of_regions.Second_number_region)))
GROUP BY a.Number_auto, a.Time_Dvigenia
GO

CREATE VIEW inogorodnie AS
SELECT a.Number_auto AS '����� ����', a.Time_Dvigenia AS '����� ������', MIN(b.Time_Dvigenia) AS '����� ������', 
(SELECT TableOfregions.regions.Region
FROM TableOfregions.regions
WHERE TableOfregions.regions.Number_region =
(SELECT TableOfregions.numbers_of_regions.Number_region 
FROM TableOfregions.numbers_of_regions
WHERE  (LEN(a.Number_auto) = 8 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 2)) = TableOfregions.numbers_of_regions.Second_number_region)
OR (LEN(a.Number_auto) = 9 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 3)) = TableOfregions.numbers_of_regions.Second_number_region))) AS '������'
FROM Registor_cars.zurnal a, Registor_cars.zurnal b
WHERE a.Number_auto = b.Number_auto 
AND b.Time_Dvigenia = 
(SELECT TOP 1 c.Time_Dvigenia 
FROM Registor_cars.zurnal c 
WHERE a.Number_auto = c.Number_auto 
AND b.Napravlenie_Dvigenia = c.Napravlenie_Dvigenia
AND (DATEDIFF(MINUTE, a.Time_Dvigenia, c.Time_Dvigenia) > 0)
ORDER BY c.Time_Dvigenia)
AND a.Napravlenie_Dvigenia = 1 
AND b.Napravlenie_Dvigenia = 0 
AND a.Post = b.Post
GROUP BY a.Number_auto, a.Time_Dvigenia
GO

CREATE VIEW prochie AS
SELECT a.Number_auto AS '����� ����', a.Time_Dvigenia AS '����� ������', MIN(b.Time_Dvigenia) AS '����� ������', 
(SELECT TableOfregions.regions.Region
FROM TableOfregions.regions
WHERE TableOfregions.regions.Number_region =
(SELECT TableOfregions.numbers_of_regions.Number_region 
FROM TableOfregions.numbers_of_regions
WHERE  (LEN(a.Number_auto) = 8 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 2)) = TableOfregions.numbers_of_regions.Second_number_region)
OR (LEN(a.Number_auto) = 9 
AND CONVERT(int,SUBSTRING(a.Number_auto, 7, 3)) = TableOfregions.numbers_of_regions.Second_number_region))) AS '������'
FROM Registor_cars.zurnal a, Registor_cars.zurnal b
WHERE a.Number_auto = b.Number_auto 
AND a.Number_auto NOT IN (SELECT transit.[����� ����] FROM transit)
AND a.Number_auto NOT IN (SELECT domashnie.[����� ����] FROM domashnie)
AND a.Number_auto NOT IN (SELECT inogorodnie.[����� ����] FROM inogorodnie)
AND b.Napravlenie_Dvigenia = 0
AND a.Napravlenie_Dvigenia = 1
GROUP BY a.Number_auto, a.Time_Dvigenia
GO



--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- -- ������� �� 9 ��������
--(N'�305HG166', 1, 0, '12:10:00') --������ ������ � ������ ����� � (�� ��������)
-- ,(N'1305HH166', 1, 0, '12:10:00') --������ ������ � ������ �����
-- ,(N'KK75HH166', 2, 1, '12:10:00') --������ ������ � ������ �� �����
-- ,(N'A3H9HH166', 3, 0, '12:20:00') --������ ������ � ������ �� �����
-- ,(N'A39HHH166', 4, 1, '12:30:00') --��������� ������ � ������ �� �����
-- ,(N'A3,5HH166', 1, 1, '12:40:00') --������� ����� �� ������ ������
-- ,(N'A000HH166', 1, 1, '12:40:00') --����� ������ ���� �� ������ ������
-- ,(N'T305�H166', 2, 0, '12:50:00') --����� ������ � ������ ����� � (�� ��������)
-- ,(N'T385H�166', 3, 0, '12:50:00') --������ ������ � ������ ����� � (�� ��������)
-- ,(N'T3051H166', 2, 0, '12:50:00') --����� ������ � ������ �����
-- ,(N'T385H1166', 3, 0, '12:50:00') --������ ������ � ������ �����
-- ,(N'T385HHF66', 3, 0, '12:50:00') --������� ������ �� �����
-- ,(N'T385HH366', 3, 0, '12:50:00') --������� ������ �� ����� 1,2,7
-- ,(N'T385HK1H6', 3, 0, '12:50:00') --������� ������ �� �����
-- ,(N'T385HK16H', 3, 0, '12:50:00') --������� ������ �� �����
-- ,(N'T385HK100', 3, 0, '12:50:00') --������� � ������� ������ ����
-- ,(N'T385HK1,6', 3, 0, '12:50:00') --������� ����� � ��������� ������
-- ,(N't305hk166', 3, 0, '12:50:00') --(�����) ���������� �������
-- ,(N'T085HK166', 3, 0, '12:50:00') --(�����) ������� ������� ������
-- ,(N'T005HK250', 3, 0, '12:50:00') --(�����) ��� ������� ������
-- ,(N'T080KK702', 3, 0, '12:50:00') --(�����) ���� ������� ������
-- ,(N'�001��174', 3, 0, '12:50:00') -- (�����) ���������
-- -- ������� �� 8 ��������
-- ,(N'�305HY66', 1, 0, '12:10:00') --������ ������ � ������ ����� � (�� ��������)
-- ,(N'1305HY66', 1, 0, '12:10:00') --������ ������ � ������ �����
-- ,(N'TT75HY66', 2, 1, '12:10:00') --������ ������ � ������ �� �����
-- ,(N'A3T9HH66', 3, 0, '12:20:00') --������ ������ � ������ �� �����
-- ,(N'A39THY66', 4, 1, '12:30:00') --��������� ������ � ������ �� �����
-- ,(N'A3,5HT66', 1, 1, '12:40:00') --������� ����� �� ������ ������
-- ,(N'A000HH66', 1, 1, '12:40:00') --����� ������ ���� �� ������ ������
-- ,(N'T305�Y66', 2, 0, '12:50:00') --����� ������ � ������ ����� � (�� ��������)
-- ,(N'T385H�66', 3, 0, '12:50:00') --������ ������ � ������ ����� � (�� ��������)
-- ,(N'T3051K66', 2, 0, '12:50:00') --����� ������ � ������ �����
-- ,(N'T385H166', 3, 0, '12:50:00') --������ ������ � ������ �����
-- ,(N'T385HKH6', 3, 0, '12:50:00') --������� ������ �� �����
-- ,(N'T385HK6H', 3, 0, '12:50:00') --������� ������ �� �����
-- ,(N'T385HK00', 3, 0, '12:50:00') --������� � ������� ������ ����
-- ,(N't305hy74', 3, 0, '12:50:00') --(�����) ���������� �������
-- ,(N'�001��02', 3, 0, '12:50:00') -- (�����) ���������
-- -- ������� �� ������������� ���������� ��������
-- ,(N't305hk7', 3, 0, '12:50:00') --������ ������
-- ,(N'H000HH2009', 3, 0, '12:50:00') -- ������ ������
--GO


--  ������ 0
-- ������ 1


--������ ������������ �������
--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'�305HG166', 1, 0, '12:10:00')  
--GO

--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'A000HH66', 1, 1, '12:40:00')  
--GO

--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'T385HK6H', 3, 0, '12:50:00')  
--GO

---- ��� ������ ������� � �����������
--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'T385HK45', 3, 0, '12:50:00')  
--GO

---- ������� �� ������� ������ 5 �����
--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'Y370TT196', 4, 1, '15:06:00')  
--GO

--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'Y370TT196', 4, 0, '15:08:00')  
--GO

----��� ���� ������ 
--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'Y340TT96', 4, 0, '10:06:00')  
--GO

--INSERT INTO [KN301_Borodina].Registor_cars.zurnal
-- VALUES 
-- (N'Y340TT96', 4, 0, '10:30:00')  
--GO

---- ���������� ����������
INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N't305hy74', 2, 1, '10:06:00')  
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N't305hy74', 4, 0, '12:51:00') --
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'K385KK74', 2, 1, '12:06:00')  
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'K385KK74', 4, 0, '14:51:00') --
GO

--�������� ����������
INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'K245BB196', 4, 0, '11:06:00')  
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'K245BB196', 3, 1, '19:06:00')  
GO

--���������� ����������
INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES
 (N'Y001YY02', 3, 1, '9:00:00') -- 
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'Y001YY02', 3, 0, '19:30:00') 
GO

--������ ����������
INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'A020BC702', 2, 0, '18:26:00') 
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'A020BC702', 2, 1, '18:36:00') 
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'A021TY77', 2, 0, '18:46:00') 
GO

INSERT INTO [KN301_Borodina].Registor_cars.zurnal
 VALUES 
 (N'A021TY77', 3, 1, '18:56:00') 
GO

--SELECT * FROM Registor_cars.zurnal
--SELECT * FROM transit
--SELECT * FROM domashnie
SELECT * FROM inogorodnie
--SELECT * FROM prochie