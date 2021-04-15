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
   WHERE name = N'TableOfCursValut'
) 
 DROP SCHEMA TableOfCursValut
GO

CREATE SCHEMA TableOfCursValut 
GO

IF OBJECT_ID('[KN301_Borodina].TableOfCursValut.valuts', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].TableOfCursValut.valuts
GO


CREATE TABLE [KN301_Borodina].TableOfCursValut.valuts
(
	IDValut int NOT NULL,
	Name_valut nvarchar(3) NULL, 
    CONSTRAINT PK_IdValut PRIMARY KEY (IdValut)
)
GO

IF OBJECT_ID('[KN301_Borodina].TableOfCursValut.curs', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].TableOfCursValut.curs
GO


CREATE TABLE [KN301_Borodina].TableOfCursValut.curs
(
	IDprodavaemoiValuta int NOT NULL,
	IDpokupaemoiValuta int NOT NULL,
	Curs float NULL,
	CONSTRAINT FK_IDprodavaemoiValuta FOREIGN KEY (IDprodavaemoiValuta) 
	REFERENCES [KN301_Borodina].TableOfCursValut.valuts(IdValut)
)
GO

ALTER TABLE [KN301_Borodina].TableOfCursValut.curs ADD 
	CONSTRAINT FK_IDpokupaemoiValuta FOREIGN KEY (IDpokupaemoiValuta) 
	REFERENCES [KN301_Borodina].TableOfCursValut.valuts(IdValut)
	ON UPDATE CASCADE 
GO	



INSERT INTO [KN301_Borodina].TableOfCursValut.valuts
 (IDValut, Name_valut)
 VALUES 
 (1, N'USD')
 ,(2, N'EUR')
 ,(3, N'RUB')
 ,(4, N'GBP')	
GO

INSERT INTO [KN301_Borodina].TableOfCursValut.curs
 (IDprodavaemoiValuta, IDpokupaemoiValuta, Curs)
 VALUES 
 (2, 1,  1.2)
 ,(4, 1, 1.33)
 ,(1, 2, 0.84)
 ,(3, 2, 0.011)
 ,(4, 2, 1.11)
 ,(2, 3, 91.42)
 ,(3, 1, 0.013)
 ,(1, 3, 76.39)
 ,(4, 3, 102.22)
 ,(1, 4, 0.75)
 ,(2, 4, 0.9)
 ,(3, 4, 0.0098)
 ,(1, 1, 1)
 ,(2, 2, 1)
 ,(3, 3, 1)
 ,(4, 4, 1)
GO


CREATE TRIGGER trigger_curs
	ON  [KN301_Borodina].TableOfCursValut.curs
	INSTEAD OF INSERT
AS
IF NOT EXISTS
(
 SELECT *
 FROM TableOfCursValut.curs,inserted
 WHERE TableOfCursValut.curs.IDpokupaemoiValuta = inserted.IDpokupaemoiValuta
 and TableOfCursValut.curs.IDprodavaemoiValuta = inserted.IDprodavaemoiValuta
)
	BEGIN
		INSERT INTO TableOfCursValut.curs SELECT * FROM inserted
	END
ELSE
		THROW 51004, N'Такой кросс-курс уже существует', 1
GO

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'Koshelek'
) 
 DROP SCHEMA Koshelek
GO

CREATE SCHEMA Koshelek 
GO

IF OBJECT_ID('[KN301_Borodina].Koshelek.dengi', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Koshelek.dengi
GO


CREATE TABLE [KN301_Borodina].Koshelek.dengi
(
	Name_valut nvarchar(3) NULL,
	Summa money NOT NULL
)
GO

CREATE PROCEDURE Snytie (@summa money, @valuta nvarchar(3)) AS
BEGIN
    IF EXISTS 
	(
	SELECT Summa, Name_valut
    FROM Koshelek.dengi
	WHERE Koshelek.dengi.Name_valut = @valuta 
	AND Koshelek.dengi.Summa >= @summa
	)
	BEGIN
		IF EXISTS (SELECT Summa, Name_valut
		FROM Koshelek.dengi
		WHERE Koshelek.dengi.Name_valut = @valuta 
		AND Koshelek.dengi.Summa = @summa)
			DELETE FROM Koshelek.dengi
			WHERE Koshelek.dengi.Name_valut = @valuta
		ELSE
		UPDATE Koshelek.dengi
		SET Koshelek.dengi.Summa -= @summa
		WHERE Koshelek.dengi.Name_valut = @valuta
	END
	ELSE
	BEGIN
		IF EXISTS
		(SELECT Summa, Name_valut
		FROM Koshelek.dengi
		WHERE Koshelek.dengi.Name_valut = @valuta 
		AND Koshelek.dengi.Summa < @summa
		)
		THROW 51000, N'Недостаточно средств на счете', 1
		IF NOT EXISTS
		(SELECT *
		FROM Koshelek.dengi
		WHERE Koshelek.dengi.Name_valut = @valuta)
		THROW 51001, N'У Вас нет такой валюты', 1
	END
END
GO


CREATE PROCEDURE Popolnenie (@summa money, @valuta nvarchar(3)) AS
BEGIN
    IF EXISTS 
	(
	SELECT Summa, Name_valut
    FROM Koshelek.dengi
	WHERE Koshelek.dengi.Name_valut = @valuta
	)
	BEGIN
		UPDATE Koshelek.dengi
		SET Koshelek.dengi.Summa += @summa
		WHERE Koshelek.dengi.Name_valut = @valuta
	END
	ELSE
		IF EXISTS
		(SELECT *
		FROM Koshelek.dengi
		WHERE Koshelek.dengi.Name_valut != @valuta
		AND EXISTS (SELECT Name_valut 
		FROM TableOfCursValut.valuts 
		WHERE Name_valut = @valuta))
		INSERT INTO [KN301_Borodina].Koshelek.dengi
		(Name_valut, Summa)
		VALUES 
		(@valuta, @summa)
		ELSE
		THROW 51002, N'Нет такой валюты', 1
END
GO


CREATE FUNCTION ConvertValut 
(@main_valuta nvarchar(3), @valut nvarchar(3), @kol_vo money)
RETURNS money
AS
BEGIN
IF (@main_valuta = @valut)
	RETURN @kol_vo
ELSE
	DECLARE @sum money
	DECLARE @IDMainValuta int
	DECLARE @IDvalut int

	SET @IDMainValuta  = (SELECT IDValut 
	FROM [KN301_Borodina].TableOfCursValut.valuts
	WHERE Name_valut = @main_valuta)

	SET @IDvalut  = (SELECT IDValut 
	FROM TableOfCursValut.valuts
	WHERE Name_valut = @valut)

	SET @sum = @kol_vo * (SELECT Curs
	FROM TableOfCursValut.curs
	WHERE IDpokupaemoiValuta = @IDMainValuta 
	and IDprodavaemoiValuta = @IDvalut)
	RETURN @sum
END
GO

CREATE PROCEDURE SummaInValuta (@main_valuta nvarchar(3))
AS
BEGIN
	DECLARE @VseDengi money
	SET @VseDengi = 0
	DECLARE @valut nvarchar(3)
	DECLARE @kol_vo money
	DECLARE my_cur CURSOR FOR 
    SELECT  Name_valut, Summa
    FROM Koshelek.dengi

   OPEN my_cur
   FETCH NEXT FROM my_cur INTO @valut, @kol_vo
   WHILE @@FETCH_STATUS = 0
   BEGIN  
      SET @VseDengi += dbo.ConvertValut(@main_valuta,  @valut, @kol_vo)
      FETCH NEXT FROM my_cur INTO @valut, @kol_vo
   END
   PRINT N'В кошельке имеется'
   PRINT CAST(@VseDengi AS NVARCHAR) + ' ' + @main_valuta
   CLOSE my_cur
   DEALLOCATE my_cur
END
GO

CREATE PROCEDURE VseDengiVKoshelke
AS
BEGIN
	DECLARE @valut nvarchar(3)
	DECLARE @kol_vo money
	DECLARE my_cur CURSOR FOR 
    SELECT  Name_valut, Summa
    FROM Koshelek.dengi

   OPEN my_cur
   FETCH NEXT FROM my_cur INTO @valut, @kol_vo
   PRINT N'Содержимое кошелька'
   WHILE @@FETCH_STATUS = 0
   BEGIN  
      PRINT CAST(@kol_vo AS NVARCHAR) + ' ' + @valut
      FETCH NEXT FROM my_cur INTO @valut, @kol_vo
   END
   CLOSE my_cur
   DEALLOCATE my_cur
END
GO

CREATE PROCEDURE CrosKurs
AS
BEGIN
	DECLARE @columnsValut VARCHAR(8000)
	SELECT @columnsValut = COALESCE(@columnsValut 
	+ ',[' + CAST([IDpokupaemoiValuta] AS VARCHAR) + ']' 
	+ ' AS ' + '[' + CAST([Name_valut] AS VARCHAR) + ']',
	'[' + CAST([IDpokupaemoiValuta] AS VARCHAR)+ ']' 
	+ ' AS ' + '[' + CAST([Name_valut] AS VARCHAR) + ']')
	FROM  (SELECT Name_valut, IDpokupaemoiValuta 
	FROM TableOfCursValut.valuts, TableOfCursValut.curs
	WHERE IDValut = IDpokupaemoiValuta
	GROUP BY Name_valut, IDpokupaemoiValuta) AS t
	GROUP BY IDpokupaemoiValuta, Name_valut

	DECLARE @columns VARCHAR(8000)
	SELECT @columns = COALESCE(@columns 
	+ ',[' + CAST([IDpokupaemoiValuta] AS VARCHAR) + ']',
	'[' + CAST([IDpokupaemoiValuta] AS VARCHAR)+ ']')
	FROM    TableOfCursValut.curs
	GROUP BY [IDpokupaemoiValuta]

	DECLARE @query NVARCHAR(4000)
	SET @query = 'SELECT [Name_valut] AS [\],'
	+ @columnsValut + ' FROM TableOfCursValut.curs
	Pivot(AVG([Curs]) FOR [IDpokupaemoiValuta] IN (' + @columns + ')) AS PVT
	INNER JOIN TableOfCursValut.valuts ON IDprodavaemoiValuta = IDValut'
	EXECUTE SP_EXECUTESQL @query
END
GO

INSERT INTO [KN301_Borodina].Koshelek.dengi
 (Name_valut, Summa)
 VALUES 
 (N'USD', 3000),
 (N'RUB', 150)
 GO

 --EXEC Snytie 150, N'RUB'
 --SELECT * FROM Koshelek.dengi

 --EXEC Snytie 1000, N'USD'

 --SELECT * FROM Koshelek.dengi

 --EXEC Popolnenie 200, N'RUB'

 -- SELECT * FROM Koshelek.dengi
  
 -- EXEC Popolnenie 200, N'EUR'

 -- SELECT Name_valut AS N'Валюта', Summa AS N'Сумма' FROM Koshelek.dengi
  
  --SELECT * FROM TableOfCursValut.curs

  EXEC CrosKurs

--EXEC SummaInValuta N'RUB'
--EXEC SummaInValuta N'USD'
--EXEC VseDengiVKoshelke
