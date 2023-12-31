USE [PS_UserData]
GO

/****** Object:  Table [dbo].[GM_Hackers_Log]    ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[GM_Hackers_Log](
	[IDX] [int] IDENTITY(1,1) NOT NULL,
	[IDGM] [varchar](50) NULL,
	[IPGM] [varchar](50) NULL,
	[SESSIONID] [bigint] NULL,
	[LOGINTIME] [datetime] NULL,
	[STATUS] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[GM_Hackers_Log] ADD  CONSTRAINT [DF_GM_Hackers_Log_LOGINTIME]  DEFAULT (getdate()) FOR [LOGINTIME]
GO

ALTER TABLE [dbo].[GM_Hackers_Log] ADD  CONSTRAINT [DF_GM_Hackers_Log_STATUS]  DEFAULT ('Login Error') FOR [STATUS]
GO



Then use: 

USE [PS_UserData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Try_GameLogin_Taiwan]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER  Proc [dbo].[usp_Try_GameLogin_Taiwan]

@UserID 	varchar(18),
@InPassword	varchar(32),

@SessionID 	bigint,
@UserIP 	varchar(15),



@UserUID 	int = 0,
@LoginType 	smallint = 1, 
@LoginTime 	datetime = NULL

AS

SET NOCOUNT ON

DECLARE 



@Leave 		tinyint,
@Status 		smallint,

@gm1IP 	varchar(15),
@gm2IP 	varchar(15),
@gm3IP 	varchar(15),
@TempIP 	varchar(15),
@Check		int

SET @Status =		 -1
SET @LoginTime = 	GETDATE()

--------------------------------------------------
SET @gm1IP = 	'10.0.0.199'
SET @gm2IP = 	'10.0.0.198'
SET @gm3IP = 	'10.0.0.197'

SET @UserIP =		LTRIM( RTRIM(@UserIP) )
--------------------------------------------------
SET @Check = 0
--------------------------------------------------

SELECT @UserUID=UserUID, @Status=Status, @Leave=Leave FROM Users_Master WHERE UserID = @UserID

-- NotExist User OR Leave User
IF( @UserUID = 0 OR @Leave = 1 )
BEGIN
	SET @Status = -3
END
ELSE
BEGIN
	-- Check Password
	EXEC dbo.sp_LoginSuccessCheck @UserID, @InPassword, @Check output
	IF ( @@ERROR = 0 )
	BEGIN
		IF( @Check <> 1 )
		BEGIN
			SET @Status = -1
		END
	END
	ELSE
	BEGIN
		SET @Status = -1
	END

	/* Old
	SET @InEnPassword = master.dbo.fn_md5(@InPassword)
	IF ( @InEnPassword <> @EnPassword )
	BEGIN
		SET @Status = -1
	END
	*/
END

-- BlockUser Check
IF( (@Status >= 2) AND (@Status <= 6) )
BEGIN
	-- Get Block Limit Date AND Replace date text
	DECLARE @BlockEndDate datetime
	SELECT @BlockEndDate = BlockEndDate FROM Users_Block WHERE UserUID = @UserUID
	IF ( @@ROWCOUNT <> 0 )
	BEGIN
		-- Block Release
		IF ( @BlockEndDate <= @LoginTime )
		BEGIN
			SET @Status = 0
			UPDATE Users_Master SET Status = @Status WHERE UserUID = @UserUID
		END
	END
END

-- Admin IP Check(********.com [Twilight] - FIXED)

IF(@Status = 16 OR @Status = 32 OR @Status = 48 OR @Status = 64 OR @Status = 80 )
BEGIN
	SET @TempIP = LEFT(@UserIP, 9)
IF(@UserIP = @gm1IP OR @UserIP = @gm2IP OR @UserIP = @gm2IP)
	BEGIN
		--SET @Status = -999
	insert into PS_userdata.dbo.GM_Hackers_Log(IDGM,IPGM,SESSIONID,[STATUS]) values(@UserID,@UserIP,@SessionID,'Correct GM Login')
END
---------------------
ELSE
	BEGIN
		SET @Status = -999
	insert into PS_userdata.dbo.GM_Hackers_Log(IDGM,IPGM,SESSIONID) values(@UserID,@UserIP,@SessionID)
END
---------------------
END


-- Select 
SELECT @Status AS Status, @UserUID AS UserUID

-- Log Insert
IF( @Status = 0 OR @Status = 16 OR @Status = 32 OR @Status = 48 OR @Status = 64 OR @Status = 80 )
BEGIN
	EXEC usp_Insert_LoginLog_E @SessionID=@SessionID, @UserUID=@UserUID, @UserIP=@UserIP, @LogType=0, @LogTime=@LoginTime, @LoginType=@LoginType

if @useruid=(select useruid from PS_userdata.dbo.UserLoginStatus
	where useruid=@useruid)
		update PS_userdata.dbo.UserLoginStatus
			set loginstatus=1,LoginTime=@LoginTime,LogoutTime=@LoginTime,loginSession=@SessionID,lastplaytime=0
				where useruid=@useruid
		else
insert into PS_userdata.dbo.UserLoginStatus(useruid,userid,loginstatus,logintime,logouttime,loginsession,lastplaytime) values(@useruid,@userid,1,@LoginTime,@LoginTime,@SessionID,0)

END
SET NOCOUNT OFF