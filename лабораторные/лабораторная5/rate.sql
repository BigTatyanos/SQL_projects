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
   WHERE name = N'Tarifs'
) 
 DROP SCHEMA Tarifs
GO

CREATE SCHEMA Tarifs 
GO

IF OBJECT_ID('[KN301_Borodina].Tarifs.tarif', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Tarifs.tarif
GO


CREATE TABLE [KN301_Borodina].Tarifs.tarif
(
	name_tarifs nvarchar(35) NOT NULL,
	cost money NULL,
	pocket int NULL,
	cost_per_minute money NULL,
    CONSTRAINT PK_name_tarifs PRIMARY KEY (name_tarifs)
)
GO

IF OBJECT_ID('[KN301_Borodina].Tarifs.segments', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Tarifs.segments
GO


CREATE TABLE [KN301_Borodina].Tarifs.segments
(
	name_tarifs nvarchar(35) NULL,
	left_border float NULL,
	right_border float NULL
)
GO

--INSERT INTO [KN301_Borodina].Tarifs.tarif
-- (Name_tarifs, cost,pocket, cost_per_minute)
-- VALUES 
-- (N'Поминутный',0, 0, 1)
-- ,(N'Первый',150, 200, 2)
-- ,(N'Безлимитный',300, 31*24*60, 0)
--GO

--INSERT INTO [KN301_Borodina].Tarifs.tarif
-- (Name_tarifs, cost, pocket, cost_per_minute)
-- VALUES 
-- (N'Поминутный',0, 0, 0.5)
-- ,(N'Первый',2, 5, 1)
-- ,(N'Безлимитный',5, 31*24*60, 0)
--GO


INSERT INTO [KN301_Borodina].Tarifs.tarif
 (Name_tarifs, cost,pocket, cost_per_minute)
 VALUES 
 (N'Поминутный',0, 0, 0.5)
 ,(N'Первый',2, 6, 1)
 ,(N'Безлимитный',6, 31*24*60, 0)
GO

--INSERT INTO [KN301_Borodina].Tarifs.tarif
-- (Name_tarifs, cost,pocket, cost_per_minute)
-- VALUES 
-- (N'1',500, 31*24*60, 0)
-- ,(N'2',300, 31*24*60, 0)
-- ,(N'3',200, 100, 0.5)
-- ,(N'4',0, 0, 3)
--GO


CREATE FUNCTION Find_points
(@a money, @b money, @c money, @d money)
RETURNS float
AS
BEGIN
	IF (@a = @c OR @b = @d) RETURN 0--''
	DECLARE @x float
	DECLARE @y float
	SET @x = (@c - @a) / (@b - @d)
	--SET @y = @a + @b * @x
	RETURN @x
END
GO


DECLARE @Tochka float
SET @Tochka = 0
DECLARE @F_name_tarifs nvarchar(35)
DECLARE @F_plata money
DECLARE @F_pocket int
DECLARE @F_cost_per_minute money
DECLARE my_cur CURSOR FOR 
SELECT  * FROM Tarifs.tarif

OPEN my_cur
FETCH NEXT FROM my_cur INTO @F_name_tarifs, @F_plata, @F_pocket,@F_cost_per_minute
WHILE @@FETCH_STATUS = 0
	BEGIN  
		DECLARE @S_name_tarifs nvarchar(35)
		DECLARE @S_plata money
		DECLARE @S_pocket int
		DECLARE @S_cost_per_minute money
		DECLARE cur CURSOR FOR 
		SELECT  * FROM Tarifs.tarif
		
		OPEN cur
		FETCH NEXT FROM cur INTO @S_name_tarifs, @S_plata, @S_pocket,@S_cost_per_minute

		WHILE @@FETCH_STATUS = 0
			BEGIN 
			IF NOT @F_name_tarifs = @S_name_tarifs
				BEGIN

					SET @Tochka = dbo.Find_points(@F_plata, 0, -@S_cost_per_minute*(@S_pocket+1) + @S_plata + @S_cost_per_minute , @S_cost_per_minute)
					IF @Tochka >= @S_pocket AND @Tochka <= @F_pocket AND @Tochka NOT IN (SELECT right_border FROM Tarifs.segments)
						INSERT INTO [KN301_Borodina].Tarifs.segments (right_border) VALUES  (@Tochka)
					SET @Tochka = dbo.Find_points(-@F_cost_per_minute*(@F_pocket+1) + @F_plata + @F_cost_per_minute , @F_cost_per_minute, @S_plata, 0)
					IF @Tochka >= @F_pocket AND @Tochka <= @S_pocket AND @Tochka NOT IN (SELECT right_border FROM Tarifs.segments)
						INSERT INTO [KN301_Borodina].Tarifs.segments (right_border) VALUES  (@Tochka)
					SET @Tochka = dbo.Find_points(-@F_cost_per_minute*(@F_pocket+1) + @F_plata + @F_cost_per_minute , @F_cost_per_minute, -@S_cost_per_minute*(@S_pocket+1) + @S_plata + @S_cost_per_minute , @S_cost_per_minute)
					IF @Tochka >= (case when @S_pocket > @F_pocket then @S_pocket else @F_pocket end) AND @Tochka NOT IN (SELECT right_border FROM Tarifs.segments)
						INSERT INTO [KN301_Borodina].Tarifs.segments (right_border) VALUES  (@Tochka)
					
				END
				FETCH NEXT FROM cur INTO @S_name_tarifs, @S_plata, @S_pocket,@S_cost_per_minute
			END
		FETCH NEXT FROM my_cur INTO @F_name_tarifs, @F_plata, @F_pocket,@F_cost_per_minute
		CLOSE cur
		DEALLOCATE cur
	END
CLOSE my_cur
DEALLOCATE my_cur
GO


DECLARE @left float
SET @left = 0
DECLARE @right float
DECLARE cur_seg CURSOR FOR 
SELECT right_border  
FROM Tarifs.segments 
ORDER BY right_border

OPEN cur_seg
FETCH NEXT FROM cur_seg INTO @right
WHILE @@FETCH_STATUS = 0
	BEGIN  
		UPDATE Tarifs.segments
		SET left_border = @left
		WHERE right_border = @right
		SET @left = @right
		FETCH NEXT FROM cur_seg INTO @right
	END
INSERT INTO Tarifs.segments (left_border, right_border) 
VALUES (@left, 31*24*60)
CLOSE cur_seg
DEALLOCATE cur_seg
GO

DECLARE @left_bord float
DECLARE @right_bord float
DECLARE @min_sum money
DECLARE @name_min_tarif nvarchar(35)
DECLARE cur_tar CURSOR FOR 
SELECT left_border, right_border  
FROM Tarifs.segments 
ORDER BY right_border

OPEN cur_tar
FETCH NEXT FROM cur_tar INTO @left_bord, @right_bord
WHILE @@FETCH_STATUS = 0
	BEGIN  
		SET @min_sum = -1
		DECLARE @name_tarifs nvarchar(35)
		DECLARE @plata money
		DECLARE @pocket int
		DECLARE @cost_per_minute money
		DECLARE cur_min CURSOR FOR 
		SELECT  * FROM Tarifs.tarif
		
		OPEN cur_min
		FETCH NEXT FROM cur_min INTO @name_tarifs, @plata, @pocket,@cost_per_minute
		WHILE @@FETCH_STATUS = 0
			BEGIN 
				IF @right_bord <= @pocket
					BEGIN
						IF (@min_sum = -1 OR @min_sum > @plata)
							BEGIN
								SET @min_sum = @plata
								SET @name_min_tarif = @name_tarifs
							END
					END
					
				ELSE
					BEGIN
						IF (@min_sum = -1 
						OR @min_sum > @cost_per_minute*((@left_bord + 0.1) - @pocket - 1) + @plata + @cost_per_minute)
							BEGIN
								SET @min_sum = @cost_per_minute*((@left_bord + 0.1) - @pocket - 1) + @plata + @cost_per_minute
								SET @name_min_tarif = @name_tarifs
							END
					END
				FETCH NEXT FROM cur_min INTO @name_tarifs, @plata, @pocket,@cost_per_minute
			END
		CLOSE cur_min
		DEALLOCATE cur_min

		UPDATE Tarifs.segments
		SET name_tarifs = @name_min_tarif
		WHERE left_border = @left_bord AND right_border = @right_bord

		FETCH NEXT FROM cur_tar INTO @left_bord, @right_bord
	END
CLOSE cur_tar
DEALLOCATE cur_tar
GO

--SELECT *
--FROM Tarifs.segments
--ORDER BY right_border
--GO

--SELECT a.name_tarifs, a.left_border, a.right_border , b.left_border, b.right_border 
--FROM Tarifs.segments AS a, Tarifs.segments AS b
--WHERE a.name_tarifs = b.name_tarifs
--ORDER BY a.right_border
--GO

--SELECT a.name_tarifs, a.left_border, b.right_border 
--FROM Tarifs.segments AS a, Tarifs.segments AS b
--WHERE (a.right_border = b.left_border AND a.name_tarifs = b.name_tarifs)
--ORDER BY a.right_border
--GO

CREATE TABLE [KN301_Borodina].Tarifs.segments_without
(
	tarifs nvarchar(35) NULL,
	left_bord float NULL,
	right_bord float NULL
)
GO


DECLARE @left_bb float
DECLARE @left_bw float
DECLARE @right_bw float
DECLARE @right_bb float
DECLARE @name_w_tarif nvarchar(35)
DECLARE @name_mb_tarif nvarchar(35)
DECLARE cur_p CURSOR FOR 
SELECT *
FROM Tarifs.segments
ORDER BY right_border

OPEN cur_p
FETCH NEXT FROM cur_p INTO @name_w_tarif, @left_bw, @right_bw
SET @name_mb_tarif = @name_w_tarif
SET @right_bb = @right_bw
SET @left_bb = @left_bw
WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF (@name_w_tarif = @name_mb_tarif)
			SET @right_bw = @right_bb
		ELSE 
			BEGIN
				INSERT INTO Tarifs.segments_without
				VALUES
				(@name_w_tarif, @left_bw, @right_bw)
				SET @name_w_tarif = @name_mb_tarif
				SET @right_bw = @right_bb
				SET @left_bw = @left_bb
			END
		FETCH NEXT FROM cur_p INTO @name_mb_tarif, @left_bb, @right_bb
	END
	INSERT INTO Tarifs.segments_without
	VALUES (@name_w_tarif, @left_bw, @right_bw)
CLOSE cur_p
DEALLOCATE cur_p
GO

--SELECT * FROM Tarifs.segments 
--ORDER BY right_border
--GO

SELECT * FROM Tarifs.segments_without
ORDER BY right_bord
GO

CREATE PROCEDURE Best_tariff
(@minuts int)
AS
BEGIN
	IF @minuts > 31*24*60
		THROW 50001, 'Нет столько минут в месяце', 1
	SELECT TOP 1 name_tarifs AS N'Выгодный тариф'
	FROM Tarifs.segments
	WHERE left_border <= @minuts AND @minuts <= right_border
END
GO

EXEC Best_tariff 175