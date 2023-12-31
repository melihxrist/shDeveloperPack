/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
[UserID]
	,[UserUID]
	,[CharID]
	,[CharName]
	,[CharLevel]
	,[CharExp]
	,[MapID]
	,[PosX]
	,[PosY]
	,[PosZ]
	,[ActionTime]
	,[ActionType]
	,case	when [ActionType] = 103 then 'Killed' 
			when [ActionType] = 104 then 'GotKilled' 
			else 'Other' end as 'ActionTypeText'
	,[Text1]
	,[Text2]
FROM 
	[PS_GameLog].[dbo].[ActionLog] with (nolock)
where
	ActionType in ('103','104')
	and CharName = 'xxx' -- charname in ''
order by
	ActionTime