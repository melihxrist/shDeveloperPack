/****** Script for SelectTopNRows command from SSMS  ******/

update a 
set TargetType = 2 -- Old value was 4
	,ApplyRange = 0 -- Old values was 8,15,15 for lvl 1,2,3
-- SELECT *
FROM 
	[PS_GameDefs].[dbo].[Skills] a
where 
	SkillID = 181 and SkillName like 'dayfly%'
	
	
/*
where
	(	SkillName like 'Untouch%'
		or SkillName like 'Dayfly%' )
	and ReqLevel > 0
*/