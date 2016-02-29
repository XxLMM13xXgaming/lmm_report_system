------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG --------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
LMMRSEmailConfig = {}
LMMRSEmailConfig.UseEmailNotify = false -- Should you use email notify

LMMRSEmailConfig.ReportPHPLocation = "http://yourwebsite.com/emailreport.php" -- ONLY IF LMMRSConfig.UseEmailNotify IS TRUE

LMMRSEmailConfig.OwnersEmail = "your@website.com"

LMMRSEmailConfig.EmailsToSend = {"your@website.com", "another@website.com"} -- ONLY IF LMMRSConfig.UseEmailNotify IS TRUE
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG --------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("LMMRSSendReportMenu")
util.AddNetworkString("LMMRSSendAdminMenu")
util.AddNetworkString("LMMRSMarkRead")
util.AddNetworkString("LMMRSMarkUnRead")
util.AddNetworkString("LMMRSDeleteReport")
util.AddNetworkString("LMMRSWriteReport")
util.AddNetworkString("LMMRSRefresh")
util.AddNetworkString("LMMRSCopyItem")
util.AddNetworkString("LMMRSNotifyAboutReport")
util.AddNetworkString("LMMRSSearchForReport")
util.AddNetworkString("LMMRSCheckOnReportStatus")
util.AddNetworkString("LMMRSNotify")

local LMMRSCoolDownTableForPlayers = {}

local function GenerateID()
	local str = ""
	for i=1, 5 do
		str = str .. string.char(math.random(97, 122))
	end
	return "report_"..str
end

local function LMMRSNotifyFuncton(ply, message)
	if LMMRSConfig.WhatNotifySystemToUse == "darkrp" then
		DarkRP.notify(ply, 1, 10, message)			
	elseif LMMRSConfig.WhatNotifySystemToUse == "darkrpandtext" then
		DarkRP.notify(ply, 1, 10, message)
		net.Start("LMMRSNotify")
			net.WriteString(message)
		net.Send(ply)
	elseif LMMRSConfig.WhatNotifySystemToUse == "text" then
		net.Start("LMMRSNotify")
			net.WriteString(message)
		net.Send(ply)
	else
		net.Start("LMMRSNotify")
			net.WriteString(message)
		net.Send(ply)
	end
end

local function GetPlayerByName( ply )
	local Players = player.GetAll()
	for i=1, table.Count( Players ) do
		if string.find( string.lower( Players[i]:Nick() ), string.lower( ply ) ) then
			return Players[i]
		end
	end
	return nil
end

local function LMMRSPlayerOnCooldown(ply)
	if table.HasValue(LMMRSCoolDownTableForPlayers, ply) then
		return true
	end
	return false
end

local function LMMRSAddToCooldown(ply)
	table.insert(LMMRSCoolDownTableForPlayers, ply)
	timer.Simple( LMMRSConfig.TimeForCooldown * 60, function()
		for k, v in pairs(LMMRSCoolDownTableForPlayers) do
			if v == ply then
				table.remove(LMMRSCoolDownTableForPlayers, k)
			end
		end
	end	)
end

local function LMMRSOpenMenuF(ply)
	local reports = {}
	local playerreports = {}
	
	if !table.HasValue(LMMRSConfig.AdminGroups, ply:GetUserGroup()) then
		for k, v in pairs(file.Find("lmm_reportsystem_data/*.txt", "DATA")) do
			local reportsfile = file.Read("lmm_reportsystem_data/"..v)
			local tbl = string.Explode("|", reportsfile)
			local playerid = tbl[2]
			
			if playerid == ply:SteamID() then
				table.insert(playerreports, {string.StripExtension(v)})				
			end
		end	
	
		net.Start("LMMRSSendReportMenu")
			net.WriteTable(playerreports)
		net.Send(ply)
	else
		for k, v in pairs(file.Find("lmm_reportsystem_data/*.txt", "DATA")) do
			local reportsfile = file.Read("lmm_reportsystem_data/"..v)
			local tbl = string.Explode("|", reportsfile)
			local player = tbl[1]
			local playerid = tbl[2]
			local date = tbl[3]
			local person = tbl[4]
			local problem = tbl[5]
			local read = tbl[6]
			local id = string.StripExtension(v)
			table.insert(reports, {player, playerid, date, person, problem, read, id})
		end
		
		net.Start("LMMRSSendAdminMenu")
			net.WriteTable(reports)
		net.Send(ply)
	end
end

net.Receive("LMMRSMarkRead", function(len, ply)
	local thefile = net.ReadString()
	
	if !table.HasValue(LMMRSConfig.AdminGroups, ply:GetUserGroup()) then
		LMMRSNotifyFuncton(ply, "You are not allowed!")
		return
	end
	
	for k, v in pairs(file.Find("lmm_reportsystem_data/*.txt", "DATA")) do
		if v == thefile..".txt" then
			local thereport = file.Read("lmm_reportsystem_data/"..thefile..".txt", "DATA")
			local tbl = string.Explode("|", thereport)
			local player = tbl[1]
			local playerid = tbl[2]
			local date = tbl[3]
			local person = tbl[4]
			local problem = tbl[5]
			local read = "true"
			file.Write("lmm_reportsystem_data/"..thefile..".txt", player.."|"..playerid.."|"..date.."|"..person.."|"..problem.."|"..read)
			LMMRSNotifyFuncton(ply, "File has been marked read!")		
			return
		end
	end
	LMMRSNotifyFuncton(ply, "File not found!")
end)

net.Receive("LMMRSMarkUnRead", function(len, ply)
	local thefile = net.ReadString()
	
	if !table.HasValue(LMMRSConfig.AdminGroups, ply:GetUserGroup()) then
		LMMRSNotifyFuncton(ply, "You are not allowed!")
		return
	end
	
	for k, v in pairs(file.Find("lmm_reportsystem_data/*.txt", "DATA")) do
		if v == thefile..".txt" then
			local thereport = file.Read("lmm_reportsystem_data/"..thefile..".txt", "DATA")
			local tbl = string.Explode("|", thereport)
			local player = tbl[1]
			local playerid = tbl[2]
			local date = tbl[3]
			local person = tbl[4]
			local problem = tbl[5]
			local read = "false"
			file.Write("lmm_reportsystem_data/"..thefile..".txt", player.."|"..playerid.."|"..date.."|"..person.."|"..problem.."|"..read)
			LMMRSNotifyFuncton(ply, "File has been marked read!")		
			return
		end
	end
	LMMRSNotifyFuncton(ply, "File not found!")

end)

net.Receive("LMMRSWriteReport", function(len, ply)
	local typeorname = net.ReadString()
	local reason = net.ReadString()
	
	if LMMRSPlayerOnCooldown(ply) then
		LMMRSNotifyFuncton(ply, "You are on a cooldown for writing reports! You need to wait "..LMMRSConfig.TimeForCooldown.." min(s)!")
		return
	end
	
	if !typeorname == "Bug" then
		reportOnNick = GetPlayerByName(typeorname):Nick()
		reportOnSteamID = GetPlayerByName(typeorname):SteamID()
	else
		reportOnNick = typeorname
		reportOnSteamID = "N/A"
	end
	
	local reportid = GenerateID()
	
	local Day = os.date( "%d")
	local Month = os.date( "%m")
	local Year = os.date( "%Y")
	
	local Hour = os.date("%I")
	local Min = os.date("%M")
	local AMPM = os.date("%p")
	 
	local date = Month.."/"..Day.."/"..Year.." - "..Hour..":"..Min.." "..AMPM
	
	if !file.Exists("lmm_reportsystem_data/"..reportid..".txt", "DATA") then
		file.Write("lmm_reportsystem_data/"..reportid..".txt", ply:Nick().."|"..ply:SteamID().."|"..date.."|"..reportOnNick.."("..reportOnSteamID..")".."|"..reason.."|".."false")
	end
	
	for k, v in pairs(player.GetAll()) do
		if table.HasValue(LMMRSConfig.AdminGroups, v:GetUserGroup()) then
			LMMRSNotifyFuncton(v, "A new report has been submitted! Type !report to check it out! ("..reportid..")")
		end
	end
	LMMRSNotifyFuncton(ply, "Your report has been submitted! The report id has been copied to your clipbored!")	
	net.Start("LMMRSCopyItem")
		net.WriteString(reportid)
	net.Send(ply)
	LMMRSAddToCooldown(ply)
	
	if LMMRSEmailConfig.UseEmailNotify then 		
		for i=1, #LMMRSEmailConfig.EmailsToSend do
			phptbl = {}
			phptbl.sendto = LMMRSEmailConfig.EmailsToSend[i]
			phptbl.type = typeorname
			phptbl.reportonperson = reportOnNick.. "("..reportOnSteamID..")"
			phptbl.thedate = date
			phptbl.thereason = reason
			phptbl.from = ply:Nick().."("..ply:SteamID()..")"
			phptbl.idreport = reportid
			phptbl.serverip = GetConVarString("ip")
			phptbl.serverport = GetConVarString("hostport")
			phptbl.host = GetConVarString("hostname")
			phptbl.email = LMMRSEmailConfig.OwnersEmail		
			http.Post( LMMRSEmailConfig.ReportPHPLocation, phptbl, function() print("Email report sent to: "..LMMRSEmailConfig.EmailsToSend[i]) end, function() MsgC(Color(255,0,0), "Email eport was not sent!\n") end )
		end
	end
end)

net.Receive("LMMRSRefresh", function(len, ply)
	LMMRSOpenMenuF(ply)
end)

net.Receive("LMMRSDeleteReport", function(len, ply)
	local thefile = net.ReadString()
	 
	if !table.HasValue(LMMRSConfig.AdminGroups, ply:GetUserGroup()) then
		LMMRSNotifyFuncton(ply, "You are not allowed!")
		return
	end
	
	if file.Exists("lmm_reportsystem_data/"..thefile..".txt", "DATA") then
		file.Delete("lmm_reportsystem_data/"..thefile..".txt", "DATA")
		LMMRSNotifyFuncton(ply, "File has been deleted!")		
	else
		LMMRSNotifyFuncton(ply, "File not found!")
	end

end)

net.Receive("LMMRSCheckOnReportStatus", function(len, ply)
	local id = net.ReadString()
	
	for k, v in pairs(file.Find("lmm_reportsystem_data/*", "DATA")) do
		if v == id..".txt" then
			local thereport = file.Read("lmm_reportsystem_data/"..id..".txt", "DATA")
			local tbl = string.Explode("|", thereport)
			local read = tbl[6]	
			
			if read == true then
				readtxt = "solved/read"
			else
				readtxt = "unsolved/unread"
			end
			LMMRSNotifyFuncton(ply, "This report has been marked "..readtxt)
			return
		end
	end
	LMMRSNotifyFuncton(ply, "No report ID found!")	
end)

net.Receive("LMMRSSearchForReport", function(len, ply)
	local id = net.ReadString()
	
	for k, v in pairs(file.Find("lmm_reportsystem_data/*", "DATA")) do
		if v == id..".txt" then
			local thereport = file.Read("lmm_reportsystem_data/"..id..".txt", "DATA")
			local tbl = string.Explode("|", thereport)
			local player = tbl[1]
			local playerid = tbl[2]
			local date = tbl[3]
			local person = tbl[4]
			local problem = tbl[5]			
			net.Start("LMMRSNotifyAboutReport")
				net.WriteString(player)
				net.WriteString(playerid)
				net.WriteString(date)
				net.WriteString(person)
				net.WriteString(problem)
			net.Send(ply)
			return
		end
	end
	LMMRSNotifyFuncton(ply, "No report found!")
end)

local function LMMRSOpenMenu(ply, text)
	local text = string.lower(text)
	if(string.sub(text, 0, 7)== "!report" or string.sub(text, 0, 7)== "/report") then
		LMMRSOpenMenuF(ply)
		return ''
	end
end 
hook.Add("PlayerSay", "LMMRSOpenMenu", LMMRSOpenMenu)