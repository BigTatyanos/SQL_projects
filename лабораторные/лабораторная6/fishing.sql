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
   WHERE name = N'Registor'
) 
 DROP SCHEMA Registor
GO

CREATE SCHEMA Registor 
GO

IF OBJECT_ID('[KN301_Borodina].Registor.passport', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Registor.passport
GO


CREATE TABLE [KN301_Borodina].Registor.passport
(
	name_lodka nvarchar(35) NOT NULL,
	tip nvarchar(35) NULL,
	vodoizmeshenie float NULL,
	date_postroiki date NULL,
    CONSTRAINT PK_name_lodka PRIMARY KEY (name_lodka)
)
GO


IF OBJECT_ID('[KN301_Borodina].Registor.vuxod_v_more', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Registor.vuxod_v_more
GO


CREATE TABLE [KN301_Borodina].Registor.vuxod_v_more
(
	name_lodka nvarchar(35) NOT NULL,
	chlenu_ekipazha nvarchar(1000) NULL,
	date_vuhoda date NULL,
	date_vozvrashenia date NULL,
	metka_ulova_s_zapluva nvarchar(40) NULL
)
GO


IF OBJECT_ID('[KN301_Borodina].Registor.banki', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Registor.banki
GO


CREATE TABLE [KN301_Borodina].Registor.banki
(
	id_banki int NOT NULL,
	name_lodka nvarchar(35) NOT NULL,
	date_prihoda date NULL,
	date_otpluva date NULL,
	metka_ulova_s_banki nvarchar(40) NULL
)
GO


IF OBJECT_ID('[KN301_Borodina].Registor.ulov_s_banki', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Registor.ulov_s_banki
GO


CREATE TABLE [KN301_Borodina].Registor.ulov_s_banki
(
	metka nvarchar(40) NOT NULL,
	sort_rubu nvarchar(35) NULL,
	kol_vo int NULL,
	kachestvo nvarchar(35) NULL
)
GO

IF OBJECT_ID('[KN301_Borodina].Registor.ulov_s_zapluva', 'U') IS NOT NULL
  DROP TABLE  [KN301_Borodina].Registor.ulov_s_zapluva
GO


CREATE TABLE [KN301_Borodina].Registor.ulov_s_zapluva
(
	metka nvarchar(40) NOT NULL,
	sort_rubu nvarchar(35) NULL,
	ves float NULL
)
GO


CREATE TRIGGER trigger_banki
   ON  Registor.banki
	INSTEAD OF INSERT
AS
IF NOT EXISTS
(
 SELECT *
 FROM Registor.banki,inserted
 WHERE banki.name_lodka = inserted.name_lodka AND
 banki.date_prihoda <= inserted.date_prihoda AND inserted.date_prihoda <= banki.date_otpluva  
)
	BEGIN
		INSERT INTO Registor.banki SELECT * FROM inserted	
	END
ELSE
	THROW 50001, N'����� ��������� �� ���� ������ ������������', 1
GO


INSERT INTO Registor.passport
VALUES
(N'������� ������', N'����� ����������', 5000.5, '20071005')
, (N'������ �����', N'����� ����������', 4000.2, '20090704')
, (N'׸���� ���������', N'����� ����������', 6000.8, '20111223')
, (N'������� ����', N'������� ����������', 11000.9, '20050425')
, (N'�� �����������', N'������� ����������', 14000.3, '20000101')
, (N'���������', N'������� ����������', 25000.7, '20180606')
GO

INSERT INTO Registor.vuxod_v_more
VALUES
(N'������� ������', N'������� ������', '20200610', '20200620', N'���06100620')
, (N'������ �����', N'������� �������', '20200615', '20200630', N'���06150630')
, (N'׸���� ���������', N'������� ������', '20200617', '20200618', N'���06170618')
, (N'������� ����', N'������� �������', '20200805', '20200823', N'���08050823')
, (N'�� �����������', N'������� �������', '20200612', '20200814', N'���06120814')
, (N'���������', N'������� �������', '20200701', '20200721', N'��07010721')

, (N'������� ����', N'������� �������', '20200724', '20200730', N'���08240830')
, (N'������ �����', N'������� �����', '20200528', '20200615', N'���05280615')

, (N'׸���� ���������', N'������� �������', '20200622', '20200709', N'���06220709')
, (N'׸���� ���������', N'������� �������', '20200711', '20200727', N'��07110727')


INSERT INTO Registor.banki
VALUES
(1, N'������� ������', '20200612', '20200615', N'1��06120615')
, (2, N'������� ������', '20200616', '20200618', N'2��06160618')

, (2, N'������ �����', '20200616', '20200620', N'2��06160620')
, (3, N'������ �����', '20200622', '20200625', N'3��06220625')

, (2, N'׸���� ���������', '20200617', '20200617', N'2��06170617')
, (1, N'׸���� ���������', '20200617', '20200617', N'1��06170617')

, (3, N'������� ����', '20200806', '20200807', N'2��08060807')
, (1, N'������� ����', '20200810', '20200820', N'1��08100820')

, (1, N'�� �����������', '20200615', '20200622', N'1��06150622')
, (2, N'�� �����������', '20200624', '20200630', N'2��06240630')
, (3, N'�� �����������', '20200705', '20200721', N'3��07050721')

, (2, N'���������', '20200702', '20200703', N'2�07020703')
, (3, N'���������', '20200706', '20200715', N'3�07060715')

, (3, N'������� ����', '20200725', '20200728', N'3��07250728')

, (1, N'������ �����', '20200530', '20200610', N'1��05300610')
, (2, N'������ �����', '20200611', '20200614', N'2��06110614')

, (2, N'׸���� ���������', '20200624', '20200702', N'2��06240702')
, (3, N'׸���� ���������', '20200703', '20200705', N'3��07030705')

, (2, N'׸���� ���������', '20200713', '20200714', N'2��07130714')
, (1, N'׸���� ���������', '20200715', '20200717', N'1��07150717')


INSERT INTO Registor.ulov_s_banki
VALUES
(N'1��06120615', N'�����', 10, N'������')
,(N'1��06120615', N'������', 3, N'�������')
,(N'2��06160618', N'�����', 7, N'�������')

,(N'2��06160620', N'������', 2, N'�������')
,(N'2��06160620', N'������', 10, N'�������')
,(N'2��06160620', N'�����', 1, N'�������')
,(N'3��06220625', N'�����', 18, N'�������')
,(N'3��06220625', N'������', 20, N'�������')

,(N'2��06170617', N'������', 4, N'������')
,(N'2��06170617', N'�����', 5, N'������')
,(N'1��06170617', N'�����', 30, N'�������')
,(N'1��06170617', N'������', 2, N'������')

,(N'2��08060807', N'������', 9, N'�������')
,(N'1��08100820', N'������', 54, N'������')

,(N'1��06150622', N'������', 14, N'�������')
,(N'1��06150622', N'������', 3, N'�������')
,(N'2��06240630', N'�����', 6, N'�������')
,(N'3��07050721', N'������', 21, N'�������')
,(N'3��07050721', N'������', 7, N'�������')

,(N'2�07020703', N'������', 33, N'������')
,(N'2�07020703', N'������', 13, N'�������')
,(N'3�07060715', N'�����', 16, N'�������')
,(N'3�07060715', N'������', 40, N'�������')

,(N'3��07250728', N'�����', 22, N'�������')
,(N'3��07250728', N'������', 3, N'�������')
,(N'3��07250728', N'������', 15, N'�������')

,(N'1��05300610', N'������', 13, N'������')
,(N'1��05300610', N'�����', 15, N'������')
,(N'2��06110614', N'�����', 11, N'�������')
,(N'2��06110614', N'������', 23, N'������')

,(N'2��06240702', N'������', 14, N'�������')
,(N'2��06240702', N'������', 10, N'�������')
,(N'3��07030705', N'������', 27, N'�������')

,(N'1��07150717', N'�����', 23, N'�������')
,(N'2��07130714', N'�����', 15, N'�������')

--INSERT INTO Registor.banki
--VALUES
--(1, N'׸���� ���������', '20200715', '20200717', N'1��07150719')

INSERT INTO Registor.ulov_s_zapluva
VALUES
(N'���06100620', N'�����', 16)
,(N'���06100620', N'������', 9)

,(N'���06150630', N'�����', 38)
,(N'���06150630', N'������', 60)
,(N'���06150630', N'������', 34.5)

,(N'���06170618', N'�����', 54)
,(N'���06170618', N'������', 8)

,(N'���08050823', N'������', 63)

,(N'���06120814', N'�����', 10.8)
,(N'���06120814', N'������', 35.8)
,(N'���06120814', N'������', 21.5)

,(N'��07010721', N'�����', 32.3)
,(N'��07010721', N'������', 75.1)
,(N'��07010721', N'������', 21.4)

,(N'���08240830', N'�����', 28.6)
,(N'���08240830', N'������', 15)
,(N'���08240830', N'������', 10.2)

,(N'���05280615', N'�����', 17)
,(N'���05280615', N'������', 26)

,(N'���06220709', N'������', 54.6)
,(N'���06220709', N'������', 31.3)

,(N'��07110727', N'�����', 53.6)

---- 1)
----�� ���������� ���� � ��������� ��� ������� ��� ������,
----�������������� ����� � ����, ������ ��� ������� 
----� ��������������� ������� ������ � ����� � ���� � ��������� �����.
----��� ����� ����������
----���� � 5 ���� �� 28 ���� 2020 ����

--SELECT vuxod_v_more.name_lodka AS N'�������� ������', DATENAME(DD, date_vuhoda)
--				+' '+DATENAME(MM, date_vuhoda)
--				+' '+DATENAME(YY, date_vuhoda) AS N'����� � ����', SUM(ves) AS N'�������� �����'
--FROM Registor.vuxod_v_more
--INNER JOIN Registor.passport ON passport.name_lodka = vuxod_v_more.name_lodka
--INNER JOIN Registor.ulov_s_zapluva ON metka = metka_ulova_s_zapluva
--WHERE tip = N'����� ����������' AND '20200605' <= date_vuhoda AND date_vozvrashenia <= '20200728'
--GROUP BY vuxod_v_more.name_lodka, date_vuhoda
--ORDER BY vuxod_v_more.name_lodka, date_vuhoda
--GO

---- 2)
----��� ���������� ��������� ��� ������� ��� ������� ����� ����
----������ ������� � ���������� ������.
----���� � 25 ���� �� 7 ������� 2020 ����

--SELECT lov.sort_rubu AS N'���� ����', name_lodka AS N'�������� �����', lov.vess AS N'��� ����' FROM Registor.vuxod_v_more
--INNER JOIN Registor.ulov_s_zapluva ON metka = metka_ulova_s_zapluva
--INNER JOIN 
--(SELECT sort_rubu, MAX(ves) AS vess
--FROM Registor.ulov_s_zapluva
--WHERE metka IN(SELECT metka_ulova_s_zapluva 
--FROM Registor.vuxod_v_more 
--WHERE '20200625' <= date_vuhoda AND date_vozvrashenia <= '20200807')
--GROUP BY sort_rubu) AS lov ON lov.sort_rubu =  ulov_s_zapluva.sort_rubu AND lov.vess = ves
--WHERE '20200625' <= date_vuhoda AND date_vozvrashenia <= '20200807'
--GO


---- 3)
----��� ���������� ��������� ��� ������� ������ �����,
----� ��������� �������� ����� �� ���� ������.
----��� ������ ����� ������� ������ �������, �������������� ���
----���� � 25 ���� �� 7 ������� 2020 ����

--SELECT id_banki AS N'ID �����', name_lodka AS N'�������� �����', AVG(kol_vo) AS N'������� ����'
--FROM Registor.banki
--INNER JOIN Registor.ulov_s_banki 
--ON metka = metka_ulova_s_banki
--WHERE '20200625' <= date_prihoda AND date_otpluva <= '20200807'
--GROUP BY id_banki, name_lodka
--ORDER BY id_banki
--GO

---- 4)
----��� �������� ����� ������� ������ �������,
----������� �������� ���� ���� ��������.
----banka 2

DECLARE @sred_ulov float
SET @sred_ulov =
(SELECT AVG(f.poln_ves) FROM(
SELECT SUM(kol_vo) AS poln_ves
FROM Registor.ulov_s_banki
INNER JOIN Registor.banki 
ON metka = metka_ulova_s_banki
WHERE id_banki = 2
GROUP BY name_lodka) AS f)
----PRINT CONVERT(nvarchar(40), @sred_ulov)
SELECT t.name_lodka AS N'�������� �����', t.kolvo AS N'����' FROM
(SELECT name_lodka , SUM(kol_vo) AS kolvo
FROM Registor.ulov_s_banki
INNER JOIN Registor.banki 
ON metka = metka_ulova_s_banki
WHERE id_banki = 2 
GROUP BY name_lodka) AS t
WHERE t.kolvo > @sred_ulov
GO

---- 5)
----������� ������ ������ ���� � ��� ������� ����� � ������ ������
----� ��������� ���� ������ � �����������, �������� �����. 
----��� ���� ������ ���������� ������ ������ ���� ��������� ���������� ���.
----���� � 25 ���� �� 7 ������� 2020 ����

--SELECT sort_rubu AS N'���� ����', ves AS N'�������� �����',  DATENAME(DD, date_vuhoda)
--				+' '+DATENAME(MM, date_vuhoda)
--				+' '+DATENAME(YY, date_vuhoda) AS N'����� � ����',
--				DATENAME(DD, date_vozvrashenia)
--				+' '+DATENAME(MM, date_vozvrashenia)
--				+' '+DATENAME(YY, date_vozvrashenia) AS N'����������� �� ����' 
--FROM Registor.ulov_s_zapluva
--INNER JOIN Registor.vuxod_v_more 
--ON metka = metka_ulova_s_zapluva
--WHERE '20200625' <= date_vuhoda AND date_vozvrashenia <= '20200807'
--ORDER BY sort_rubu