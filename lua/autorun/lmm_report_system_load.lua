if (SERVER) then
	AddCSLuaFile("lmm_report_system_config.lua")
	include("lmm_report_system_config.lua")
	
	if !file.Exists("lmm_reportsystem_data", "DATA") then
		file.CreateDir("lmm_reportsystem_data", "DATA")
	end
	
	local message = [[
	
	-------------------------------
	| Report system               |
	| Made By: XxLMM13xXgaming    |
	| Project started: 1/30/2016  |
	| Version: 1.0                |
	-------------------------------
	
	]]
	MsgC(Color(140,0,255), message) 
end

if (CLIENT) then
	include("lmm_report_system_config.lua")

	local message = [[
	
	-------------------------------
	| Report system               |
	| Made By: XxLMM13xXgaming    |
	| Project started: 1/12/2016  |
	| Version: 1.0                |
	-------------------------------
	
	]]
	MsgC(Color(140,0,255), message) 
end