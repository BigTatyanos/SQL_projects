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
	THROW 50001, N'Катер находится на двух банках одновременно', 1
GO


INSERT INTO Registor.passport
VALUES
(N'Морской дьявол', N'малая рыболовная', 5000.5, '20071005')
, (N'Старый моряк', N'малая рыболовная', 4000.2, '20090704')
, (N'Чёрная жемчужина', N'малая рыболовная', 6000.8, '20111223')
, (N'Морской волк', N'средняя рыболовная', 11000.9, '20050425')
, (N'Не потопляемый', N'средняя рыболовная', 14000.3, '20000101')
, (N'Барракуда', N'большая рыболовная', 25000.7, '20180606')
GO

INSERT INTO Registor.vuxod_v_more
VALUES
(N'Морской дьявол', N'капитан Петров', '20200610', '20200620', N'МДП06100620')
, (N'Старый моряк', N'капитан Сидоров', '20200615', '20200630', N'СМС06150630')
, (N'Чёрная жемчужина', N'капитан Ложкин', '20200617', '20200618', N'ЧЖЛ06170618')
, (N'Морской волк', N'капитан Андреев', '20200805', '20200823', N'МВА08050823')
, (N'Не потопляемый', N'капитан Фамусов', '20200612', '20200814', N'НПФ06120814')
, (N'Барракуда', N'капитан Устинов', '20200701', '20200721', N'БУ07010721')

, (N'Морской волк', N'капитан Воронин', '20200724', '20200730', N'МВВ08240830')
, (N'Старый моряк', N'капитан Щенин', '20200528', '20200615', N'СМЩ05280615')

, (N'Чёрная жемчужина', N'капитан Бондарь', '20200622', '20200709', N'ЧЖБ06220709')
, (N'Чёрная жемчужина', N'капитан Москвин', '20200711', '20200727', N'БУ07110727')


INSERT INTO Registor.banki
VALUES
(1, N'Морской дьявол', '20200612', '20200615', N'1МД06120615')
, (2, N'Морской дьявол', '20200616', '20200618', N'2МД06160618')

, (2, N'Старый моряк', '20200616', '20200620', N'2СМ06160620')
, (3, N'Старый моряк', '20200622', '20200625', N'3СМ06220625')

, (2, N'Чёрная жемчужина', '20200617', '20200617', N'2ЧЖ06170617')
, (1, N'Чёрная жемчужина', '20200617', '20200617', N'1ЧЖ06170617')

, (3, N'Морской волк', '20200806', '20200807', N'2МВ08060807')
, (1, N'Морской волк', '20200810', '20200820', N'1МВ08100820')

, (1, N'Не потопляемый', '20200615', '20200622', N'1НП06150622')
, (2, N'Не потопляемый', '20200624', '20200630', N'2НП06240630')
, (3, N'Не потопляемый', '20200705', '20200721', N'3НП07050721')

, (2, N'Барракуда', '20200702', '20200703', N'2Б07020703')
, (3, N'Барракуда', '20200706', '20200715', N'3Б07060715')

, (3, N'Морской волк', '20200725', '20200728', N'3МВ07250728')

, (1, N'Старый моряк', '20200530', '20200610', N'1СМ05300610')
, (2, N'Старый моряк', '20200611', '20200614', N'2СМ06110614')

, (2, N'Чёрная жемчужина', '20200624', '20200702', N'2ЧЖ06240702')
, (3, N'Чёрная жемчужина', '20200703', '20200705', N'3ЧЖ07030705')

, (2, N'Чёрная жемчужина', '20200713', '20200714', N'2ЧЖ07130714')
, (1, N'Чёрная жемчужина', '20200715', '20200717', N'1ЧЖ07150717')


INSERT INTO Registor.ulov_s_banki
VALUES
(N'1МД06120615', N'Сибас', 10, N'Плохое')
,(N'1МД06120615', N'Форель', 3, N'Хорошее')
,(N'2МД06160618', N'Сибас', 7, N'Хорошее')

,(N'2СМ06160620', N'Форель', 2, N'Хорошее')
,(N'2СМ06160620', N'Дорадо', 10, N'Хорошее')
,(N'2СМ06160620', N'Сибас', 1, N'Хорошее')
,(N'3СМ06220625', N'Сибас', 18, N'Хорошее')
,(N'3СМ06220625', N'Форель', 20, N'Хорошее')

,(N'2ЧЖ06170617', N'Дорадо', 4, N'Плохое')
,(N'2ЧЖ06170617', N'Сибас', 5, N'Плохое')
,(N'1ЧЖ06170617', N'Сибас', 30, N'Хорошее')
,(N'1ЧЖ06170617', N'Дорадо', 2, N'Плохое')

,(N'2МВ08060807', N'Форель', 9, N'Хорошее')
,(N'1МВ08100820', N'Форель', 54, N'Плохое')

,(N'1НП06150622', N'Форель', 14, N'Хорошее')
,(N'1НП06150622', N'Дорадо', 3, N'Хорошее')
,(N'2НП06240630', N'Сибас', 6, N'Хорошее')
,(N'3НП07050721', N'Дорадо', 21, N'Хорошее')
,(N'3НП07050721', N'Форель', 7, N'Хорошее')

,(N'2Б07020703', N'Дорадо', 33, N'Плохое')
,(N'2Б07020703', N'Форель', 13, N'Хорошее')
,(N'3Б07060715', N'Сибас', 16, N'Хорошее')
,(N'3Б07060715', N'Форель', 40, N'Хорошее')

,(N'3МВ07250728', N'Сибас', 22, N'Хорошее')
,(N'3МВ07250728', N'Дорадо', 3, N'Хорошее')
,(N'3МВ07250728', N'Форель', 15, N'Хорошее')

,(N'1СМ05300610', N'Дорадо', 13, N'Плохое')
,(N'1СМ05300610', N'Сибас', 15, N'Плохое')
,(N'2СМ06110614', N'Сибас', 11, N'Хорошее')
,(N'2СМ06110614', N'Дорадо', 23, N'Плохое')

,(N'2ЧЖ06240702', N'Форель', 14, N'Хорошее')
,(N'2ЧЖ06240702', N'Дорадо', 10, N'Хорошее')
,(N'3ЧЖ07030705', N'Форель', 27, N'Хорошее')

,(N'1ЧЖ07150717', N'Сибас', 23, N'Хорошее')
,(N'2ЧЖ07130714', N'Сибас', 15, N'Хорошее')

--INSERT INTO Registor.banki
--VALUES
--(1, N'Чёрная жемчужина', '20200715', '20200717', N'1ЧЖ07150719')

INSERT INTO Registor.ulov_s_zapluva
VALUES
(N'МДП06100620', N'Сибас', 16)
,(N'МДП06100620', N'Форель', 9)

,(N'СМС06150630', N'Сибас', 38)
,(N'СМС06150630', N'Форель', 60)
,(N'СМС06150630', N'Дорадо', 34.5)

,(N'ЧЖЛ06170618', N'Сибас', 54)
,(N'ЧЖЛ06170618', N'Дорадо', 8)

,(N'МВА08050823', N'Форель', 63)

,(N'НПФ06120814', N'Сибас', 10.8)
,(N'НПФ06120814', N'Форель', 35.8)
,(N'НПФ06120814', N'Дорадо', 21.5)

,(N'БУ07010721', N'Сибас', 32.3)
,(N'БУ07010721', N'Форель', 75.1)
,(N'БУ07010721', N'Дорадо', 21.4)

,(N'МВВ08240830', N'Сибас', 28.6)
,(N'МВВ08240830', N'Форель', 15)
,(N'МВВ08240830', N'Дорадо', 10.2)

,(N'СМЩ05280615', N'Сибас', 17)
,(N'СМЩ05280615', N'Дорадо', 26)

,(N'ЧЖБ06220709', N'Форель', 54.6)
,(N'ЧЖБ06220709', N'Дорадо', 31.3)

,(N'БУ07110727', N'Сибас', 53.6)

---- 1)
----По указанному типу и интервалу дат вывести все катера,
----осуществлявшие выход в море, указав для каждого 
----в хронологическом порядке записи о выход в море и значением улова.
----тип малая рыболовная
----даты с 5 июня по 28 июля 2020 года

--SELECT vuxod_v_more.name_lodka AS N'Название катера', DATENAME(DD, date_vuhoda)
--				+' '+DATENAME(MM, date_vuhoda)
--				+' '+DATENAME(YY, date_vuhoda) AS N'Выход в море', SUM(ves) AS N'Значение улова'
--FROM Registor.vuxod_v_more
--INNER JOIN Registor.passport ON passport.name_lodka = vuxod_v_more.name_lodka
--INNER JOIN Registor.ulov_s_zapluva ON metka = metka_ulova_s_zapluva
--WHERE tip = N'малая рыболовная' AND '20200605' <= date_vuhoda AND date_vozvrashenia <= '20200728'
--GROUP BY vuxod_v_more.name_lodka, date_vuhoda
--ORDER BY vuxod_v_more.name_lodka, date_vuhoda
--GO

---- 2)
----Для указанного интервала дат вывести для каждого сорта рыбы
----список катеров с наибольшим уловом.
----даты с 25 июня по 7 августа 2020 года

--SELECT lov.sort_rubu AS N'Сорт рыбы', name_lodka AS N'Название лодки', lov.vess AS N'Вес рыбы' FROM Registor.vuxod_v_more
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
----Для указанного интервала дат вывести список банок,
----с указанием среднего улова за этот период.
----Для каждой банки вывести список катеров, осуществлявших лов
----даты с 25 июня по 7 августа 2020 года

--SELECT id_banki AS N'ID Банки', name_lodka AS N'Название лодки', AVG(kol_vo) AS N'Средний улов'
--FROM Registor.banki
--INNER JOIN Registor.ulov_s_banki 
--ON metka = metka_ulova_s_banki
--WHERE '20200625' <= date_prihoda AND date_otpluva <= '20200807'
--GROUP BY id_banki, name_lodka
--ORDER BY id_banki
--GO

---- 4)
----Для заданной банки вывести список катеров,
----которые получили улов выше среднего.
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
SELECT t.name_lodka AS N'Название лодки', t.kolvo AS N'Улов' FROM
(SELECT name_lodka , SUM(kol_vo) AS kolvo
FROM Registor.ulov_s_banki
INNER JOIN Registor.banki 
ON metka = metka_ulova_s_banki
WHERE id_banki = 2 
GROUP BY name_lodka) AS t
WHERE t.kolvo > @sred_ulov
GO

---- 5)
----Вывести список сортов рыбы и для каждого сорта – список рейсов
----с указанием даты выхода и возвращения, величины улова. 
----При этом список показанных рейсов должен быть ограничен интервалом дат.
----даты с 25 июня по 7 августа 2020 года

--SELECT sort_rubu AS N'Сорт рыбы', ves AS N'Величина улова',  DATENAME(DD, date_vuhoda)
--				+' '+DATENAME(MM, date_vuhoda)
--				+' '+DATENAME(YY, date_vuhoda) AS N'Выход в море',
--				DATENAME(DD, date_vozvrashenia)
--				+' '+DATENAME(MM, date_vozvrashenia)
--				+' '+DATENAME(YY, date_vozvrashenia) AS N'Возвращение из моря' 
--FROM Registor.ulov_s_zapluva
--INNER JOIN Registor.vuxod_v_more 
--ON metka = metka_ulova_s_zapluva
--WHERE '20200625' <= date_vuhoda AND date_vozvrashenia <= '20200807'
--ORDER BY sort_rubu
