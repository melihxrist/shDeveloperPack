USE PS_ChatLog;
GO
IF OBJECT_ID ('Chat', 'TR') IS NOT NULL
BEGIN
 DROP TRIGGER Chat
 PRINT 'Exploit removed!'
END

ELSE
 PRINT 'Does not exist!'
GO 