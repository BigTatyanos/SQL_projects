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
   WHERE name = N'Izmerenia'
) 
 DROP SCHEMA Izmerenia
GO

CREATE SCHEMA Izmerenia
GO

IF OBJECT_ID('[KN301_Borodina].Izmerenia.tip_izmerenii', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Izmerenia.tip_izmerenii
GO


CREATE TABLE [KN301_Borodina].Izmerenia.tip_izmerenii
(
	ID_izmerenii int NOT NULL, 
	Name_izmerenii nvarchar(40) NULL, 
	Ed_izmerenii nvarchar(40) NULL, 
    CONSTRAINT PK_ID_izmerenii PRIMARY KEY (ID_izmerenii) 
)
GO

CREATE TABLE [KN301_Borodina].Izmerenia.stancia
(
	ID_stancii int  NOT NULL, 
	Name_stancii nvarchar(40) NULL, 
	Adres nvarchar(40) NOT NULL, 
    CONSTRAINT PK_ID_stancii PRIMARY KEY (ID_stancii)
)
GO

CREATE TABLE [KN301_Borodina].Izmerenia.zurnal
(
	Data_izmerenii date  NOT NULL, 
	Time_izmerenii Time (0) NULL, 
	Znachenie int NOT NULL,
	ID_izmerenii int NOT NULL,
	ID_stancii int  NOT NULL
)
GO

ALTER TABLE [KN301_Borodina].Izmerenia.zurnal ADD 
	CONSTRAINT FK_ID_izmerenii FOREIGN KEY (ID_izmerenii) 
	REFERENCES [KN301_Borodina].Izmerenia.tip_izmerenii(ID_izmerenii)
	ON UPDATE CASCADE 
GO		

ALTER TABLE [KN301_Borodina].Izmerenia.zurnal ADD 
	CONSTRAINT FK_ID_stancii FOREIGN KEY (ID_stancii) 
	REFERENCES [KN301_Borodina].Izmerenia.stancia(ID_stancii)
	ON UPDATE CASCADE 
GO	

INSERT INTO [KN301_Borodina].Izmerenia.stancia 
  VALUES
  (109876,N'Свердловская1',N'Екатеринбург Столичная 148')
 ,(276840,N'Челябинская23',N'Челябинск Ленина 13')
 ,(300689,N'Томская44',N'Томск Академическая 97')

 INSERT INTO [KN301_Borodina].Izmerenia.tip_izmerenii
  VALUES 
  (123456,N'Температура', N'Цельсия')
 ,(298654,N'Давление', N'мм.рт.ст')
 ,(345690,N'Сила ветра', N'м/с')

 INSERT INTO [KN301_Borodina].Izmerenia.zurnal
 (Data_izmerenii,Time_izmerenii,Znachenie,ID_izmerenii,ID_stancii)
 VALUES
  ('20190707','15:00:00',25,123456,109876)
 ,('20190808','16:00:33',750,298654,109876)
 ,('20190520','10:30:34',10,345690,276840)
 ,('20200425','17:40:22',16,123456,300689)
 ,('20200108','18:00:50',25,345690,300689)
 GO

SELECT Izmerenia.stancia.Name_stancii AS 'Название станции', Izmerenia.stancia.Adres AS 'Адрес станции',
				Izmerenia.zurnal.ID_stancii AS 'ID станции', Izmerenia.zurnal.ID_izmerenii AS 'ID измерений',
				Izmerenia.tip_izmerenii.Name_izmerenii AS 'Название измерений', Izmerenia.zurnal.Znachenie AS 'Значение измерений',
				Izmerenia.tip_izmerenii.Ed_izmerenii AS 'Единицы измерения', 
				DATENAME(DD, Izmerenia.zurnal.Data_izmerenii)
				+' '+DATENAME(MM, Izmerenia.zurnal.Data_izmerenii)
				+' '+DATENAME(YY, Izmerenia.zurnal.Data_izmerenii) AS 'Дата',
				Izmerenia.zurnal.Time_izmerenii AS 'Время'
				
FROM     Izmerenia.tip_izmerenii INNER JOIN
                  Izmerenia.zurnal ON Izmerenia.tip_izmerenii.ID_izmerenii = Izmerenia.zurnal.ID_izmerenii INNER JOIN
                  Izmerenia.stancia ON Izmerenia.zurnal.ID_stancii = Izmerenia.stancia.ID_stancii
