/****** Script for SelectTopNRows command from SSMS  ******/
select 
	c.CharName
	,cl.*
from 
	[PS_GameLog].[dbo].[ActionLog] cl
	inner join PS_GameData.dbo.Chars c
		on cl.CharID = c.CharID
		where 1=1
	and c.CharName = 'xxx' -- charname here in ''
--	and ChatTime like '%okt 9%'
