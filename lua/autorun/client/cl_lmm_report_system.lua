surface.CreateFont( "LMMRSfontclose", {
	font = "Lato Light",
	size = 25,
	weight = 250,
	antialias = true,
	strikeout = false,
	additive = true,
} )
 
surface.CreateFont( "LMMRSTitleFont", {
	font = "Lato Light",
	size = 30,
	weight = 250,
	antialias = true,
	strikeout = false,
	additive = true,
} )
 
surface.CreateFont( "LMMRSHeadingFont", {
	font = "Arial",
	size = 25,
	weight = 500,
} )
 
surface.CreateFont( "LMMRSMoneyFont", {
	font = "Arial",
	size = 20,
	weight = 500,
} ) 

local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount) --Panel blur function
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 6 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

local function drawRectOutline( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawOutlinedRect( x, y, w, h )
end

net.Receive( "LMMRSSendAdminMenu", function()

	local thetable = net.ReadTable()

	function MainMenu()
		local menu = vgui.Create( "DFrame" )
		menu:SetSize( 600, 600 )
		menu:Center()
		menu:SetDraggable( true )
		menu:MakePopup()
		menu:SetTitle( "" )
		menu:ShowCloseButton( false )
		menu.Paint = function( self, w, h )
			DrawBlur(menu, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 85))
			drawRectOutline( 2, 2, w - 4, h / 8.9, Color( 0, 0, 0, 85 ) )
			draw.RoundedBox(0, 2, 2, w - 4, h / 9, Color(0,0,0,125))
			draw.SimpleText( "Report System (unread reports)", "LMMRSTitleFont", menu:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local frameclose = vgui.Create( "DButton", menu )
		frameclose:SetSize( 35, 35 )
		frameclose:SetPos( menu:GetWide() - 34,10 )
		frameclose:SetText( "X" )
		frameclose:SetFont( "LMMRSfontclose" )
		frameclose:SetTextColor( Color( 255, 255, 255 ) )
		frameclose.Paint = function()
			
		end
		frameclose.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( false )			
		end	
 
		local DListViewUnRead = vgui.Create( "DListView", menu )
		DListViewUnRead:SetSize( menu:GetWide() - 20, menu:GetTall() - 145 )
		DListViewUnRead:SetPos( 10, 80 )
		DListViewUnRead:AddColumn( "Report by" )
		DListViewUnRead:AddColumn( "Date" )
		DListViewUnRead:AddColumn( "Person" )
		DListViewUnRead:AddColumn( "Problem" )
		DListViewUnRead:AddColumn( "ID" )
		for k, v in pairs( thetable ) do
			if tobool(v[6]) == false then
				DListViewUnRead:AddLine( v[1].."("..v[2]..")", v[3], v[4], v[5], v[7] )
			end
		end
		DListViewUnRead.OnRowRightClick = function( id, line)
			local reportby = DListViewUnRead:GetLine( line ):GetValue( 1 )
			local person = DListViewUnRead:GetLine( line ):GetValue( 3 )
			local problem = DListViewUnRead:GetLine( line ):GetValue( 4 )
			local id = DListViewUnRead:GetLine( line ):GetValue( 5 )
			local Dmenu = DermaMenu()
			Dmenu:AddOption( "Read full report", function()
				Derma_Message( "Report By: "..reportby.."\nPerson: "..person.."\nProblem: "..problem, "Report System", "OK" )
			end )								
			Dmenu:AddOption( "Copy reporter's info", function()
				SetClipboardText( reportby )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )
			Dmenu:AddOption( "Copy person's info", function()
				SetClipboardText( person )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )			
			Dmenu:AddOption( "Copy bug/reason", function()
				SetClipboardText( problem )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )	
			Dmenu:AddOption( "Copy report id", function()
				SetClipboardText( id )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )					
			Dmenu:AddOption( "Mark Read", function()
				net.Start("LMMRSMarkRead")
					net.WriteString(id)
				net.SendToServer()
				menu:Close()
				menu:Remove()
				gui.EnableScreenClicker(true)
				net.Start("LMMRSRefresh")
				net.SendToServer()					
			end	)
			Dmenu:AddOption( "Delete Report", function()
				net.Start("LMMRSDeleteReport")
					net.WriteString(id)
				net.SendToServer()
				menu:Close()
				menu:Remove()
				gui.EnableScreenClicker(true)
				net.Start("LMMRSRefresh")
				net.SendToServer()					
			end )		
			Dmenu:Open()
		end
		
		local SearchBtn = vgui.Create("DButton", menu)
		SearchBtn:SetPos( 10, 540 )
		SearchBtn:SetSize( menu:GetWide() - 20,20 )
		SearchBtn:SetText("Search for report")
		SearchBtn:SetTextColor(Color(255,255,255))
		SearchBtn.Paint = function( self, w, h )
			DrawBlur(SearchBtn, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
		end
		SearchBtn.DoClick = function()
--			menu:Close()
--			menu:Remove()
--			gui.EnableScreenClicker( true )
--			ReadMainMenu()
			Derma_StringRequest(
			"Report System",
			"What is the report ID?",
			"",
			function( text )
				net.Start("LMMRSSearchForReport")
					net.WriteString(text)
				net.SendToServer()
			end,
			function( text )
				menu:Close()
				menu:Remove()
				gui.EnableScreenClicker(true)
				MainMenu()
			end
			)
		end
		
		local ReadBtn = vgui.Create("DButton", menu)
		ReadBtn:SetPos( 10, 570 )
		ReadBtn:SetSize( menu:GetWide() - 20,20 )
		ReadBtn:SetText("View read reports")
		ReadBtn:SetTextColor(Color(255,255,255))
		ReadBtn.Paint = function( self, w, h )
			DrawBlur(ReadBtn, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
		end
		ReadBtn.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( true )
			ReadMainMenu()
		end
		
	end

	function ReadMainMenu()
		local menu = vgui.Create( "DFrame" )
		menu:SetSize( 600, 600 )
		menu:Center()
		menu:SetDraggable( true )
		menu:MakePopup()
		menu:SetTitle( "" )
		menu:ShowCloseButton( false )
		menu.Paint = function( self, w, h )
			DrawBlur(menu, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 85))
			drawRectOutline( 2, 2, w - 4, h / 8.9, Color( 0, 0, 0, 85 ) )
			draw.RoundedBox(0, 2, 2, w - 4, h / 9, Color(0,0,0,125))
			draw.SimpleText( "Report System (read reports)", "LMMRSTitleFont", menu:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local frameclose = vgui.Create( "DButton", menu )
		frameclose:SetSize( 35, 35 )
		frameclose:SetPos( menu:GetWide() - 34,10 )
		frameclose:SetText( "X" )
		frameclose:SetFont( "LMMRSfontclose" )
		frameclose:SetTextColor( Color( 255, 255, 255 ) )
		frameclose.Paint = function()
			
		end
		frameclose.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( false )			
		end	

		local DListViewUnRead = vgui.Create( "DListView", menu )
		DListViewUnRead:SetSize( menu:GetWide() - 20, menu:GetTall() - 145 )
		DListViewUnRead:SetPos( 10, 80 )
		DListViewUnRead:AddColumn( "Report by" )
		DListViewUnRead:AddColumn( "Date" )
		DListViewUnRead:AddColumn( "Person" )
		DListViewUnRead:AddColumn( "Problem" )
		DListViewUnRead:AddColumn( "ID" )
		for k, v in pairs( thetable ) do
			if tobool(v[6]) then
				DListViewUnRead:AddLine( v[1].."("..v[2]..")", v[3], v[4], v[5], v[7] )
			end
		end
		DListViewUnRead.OnRowRightClick = function( id, line)
			local reportby = DListViewUnRead:GetLine( line ):GetValue( 1 )
			local person = DListViewUnRead:GetLine( line ):GetValue( 3 )
			local problem = DListViewUnRead:GetLine( line ):GetValue( 4 )
			local id = DListViewUnRead:GetLine( line ):GetValue( 5 )
			local Dmenu = DermaMenu()
			Dmenu:AddOption( "Read full report", function()
				Derma_Message( "Report By: "..reportby.."\nPerson: "..person.."\nProblem: "..problem, "Report System", "OK" )
			end )								
			Dmenu:AddOption( "Copy reporter's info", function()
				SetClipboardText( reportby )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )
			Dmenu:AddOption( "Copy person's info", function()
				SetClipboardText( person )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )			
			Dmenu:AddOption( "Copy bug/reason", function()
				SetClipboardText( problem )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )	
			Dmenu:AddOption( "Copy report id", function()
				SetClipboardText( id )
				notification.AddLegacy( "Info copied to clipboard", NOTIFY_GENERIC, 3 )
			end )					
			Dmenu:AddOption( "Mark UnRead", function()
				net.Start("LMMRSMarkUnRead")
					net.WriteString(id)
				net.SendToServer()
				menu:Close()
				menu:Remove()
				gui.EnableScreenClicker(true)
				net.Start("LMMRSRefresh")
				net.SendToServer()					
			end	)
			Dmenu:AddOption( "Delete Report", function()
				net.Start("LMMRSDeleteReport")
					net.WriteString(id)
				net.SendToServer()
				menu:Close()
				menu:Remove()
				gui.EnableScreenClicker(true)
				net.Start("LMMRSRefresh")
				net.SendToServer()					
			end )		
			Dmenu:Open()
		end
		
		local ReadBtn = vgui.Create("DButton", menu)
		ReadBtn:SetPos( 10, 570 )
		ReadBtn:SetSize( menu:GetWide() - 20,20 )
		ReadBtn:SetText("View unread reports")
		ReadBtn:SetTextColor(Color(255,255,255))
		ReadBtn.Paint = function( self, w, h )
			DrawBlur(ReadBtn, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
		end
		ReadBtn.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( true )
			MainMenu()
		end
		
		local SearchBtn = vgui.Create("DButton", menu)
		SearchBtn:SetPos( 10, 540 )
		SearchBtn:SetSize( menu:GetWide() - 20,20 )
		SearchBtn:SetText("Search for report")
		SearchBtn:SetTextColor(Color(255,255,255))
		SearchBtn.Paint = function( self, w, h )
			DrawBlur(SearchBtn, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
		end
		SearchBtn.DoClick = function()
--			menu:Close()
--			menu:Remove()
--			gui.EnableScreenClicker( true )
--			ReadMainMenu()
			Derma_StringRequest(
			"Report System",
			"What is the report ID?",
			"",
			function( text )
				net.Start("LMMRSSearchForReport")
					net.WriteString(text)
				net.SendToServer()
			end,
			function( text )
				menu:Close()
				menu:Remove()
				gui.EnableScreenClicker(true)
				MainMenu()
			end
			)
		end
		
	end
	
	MainMenu()
	
end )

net.Receive("LMMRSSendReportMenu", function()
	
	local thetable = net.ReadTable()
	
	function MainMenu()
		local menu = vgui.Create( "DFrame" )
		menu:SetSize( 250, 300 )
		menu:Center()
		menu:SetDraggable( true )
		menu:MakePopup()
		menu:SetTitle( "" )
		menu:ShowCloseButton( false )
		menu.Paint = function( self, w, h )
			DrawBlur(menu, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 85))
			drawRectOutline( 2, 2, w - 4, h / 6.9, Color( 0, 0, 0, 85 ) )
			draw.RoundedBox(0, 2, 2, w - 4, h / 7, Color(0,0,0,125))
			draw.SimpleText( "Report System", "LMMRSTitleFont", menu:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		local frameclose = vgui.Create( "DButton", menu )
		frameclose:SetSize( 35, 35 )
		frameclose:SetPos( menu:GetWide() - 34,10 )
		frameclose:SetText( "X" )
		frameclose:SetFont( "LMMRSfontclose" )
		frameclose:SetTextColor( Color( 255, 255, 255 ) )
		frameclose.Paint = function()
			
		end
		frameclose.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( false )			
		end		
		
		local ReportSelect = vgui.Create("DComboBox", menu)
		ReportSelect:SetPos(2, 50)
		ReportSelect:SetSize(menu:GetWide() - 4,20)
		ReportSelect:SetText("Report Type")
		ReportSelect:AddChoice("Bug Report")
		ReportSelect:AddChoice("Player Report")
		ReportSelect.OnSelect = function( index, value, data )
			if data == "Bug Report" then
			
				local TextEntry = vgui.Create( "DTextEntry", menu )	-- create the form as a child of frame
				TextEntry:SetPos( 2, 80 )
				TextEntry:SetSize( menu:GetWide() - 4, 120 )
				TextEntry:SetText( "Enter bug report here..." )
				TextEntry.OnEnter = function( self )

				end					
			
				local SubmitButton = vgui.Create("DButton", menu)
				SubmitButton:SetPos( 2, 210 )
				SubmitButton:SetSize( menu:GetWide() - 4,20 )
				SubmitButton:SetText("Submit Report")
				SubmitButton:SetTextColor(Color(255,255,255))
				SubmitButton.Paint = function( self, w, h )
					DrawBlur(SubmitButton, 2)
					drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
					draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
				end
				SubmitButton.DoClick = function()							
					local player = "Bug Report"
					local reason = TextEntry:GetValue()
					net.Start("LMMRSWriteReport")
						net.WriteString(player)
						net.WriteString(reason)
					net.SendToServer()	
					menu:Close()
					menu:Remove()
					gui.EnableScreenClicker( false )										
				end					
			
--				Derma_StringRequest(
--				"Report System",
--				"Input the reason for the report",
--				"",
--				function( text ) 
--					net.Start("LMMRSWriteReport")
--						net.WriteString("Bug")
--						net.WriteString(text)
--					net.SendToServer()	
--					menu:Close()
--					menu:Remove()
--					gui.EnableScreenClicker( false )										
--				end,
--				function( text )
--					menu:Close()
--					menu:Remove()
--					gui.EnableScreenClicker( true )
--					MainMenu()										
--				end
--			 )
			else
				local PlayerReport = vgui.Create("DComboBox", menu)
				PlayerReport:SetPos(2, 80)
				PlayerReport:SetSize(menu:GetWide() - 4,20)
				PlayerReport:SetText("Select a player")
				for k, v in pairs(player.GetAll()) do
					PlayerReport:AddChoice(v:Nick())
				end
				PlayerReport.OnSelect = function( index, value, data )
					local PlayerReasonReport = vgui.Create("DComboBox", menu)
					PlayerReasonReport:SetPos(2, 110)
					PlayerReasonReport:SetSize(menu:GetWide() - 4,20)
					PlayerReasonReport:SetText("Select a reason")
					for k, v in pairs(LMMRSConfig.PlayerReportReasons) do
						PlayerReasonReport:AddChoice(v)
					end
					PlayerReasonReport:AddChoice("Other")
					PlayerReasonReport.OnSelect = function( index, value, reason )
						if PlayerReasonReport:GetSelected() == "Other" then
							local player = PlayerReport:GetSelected()
							local TextEntry = vgui.Create( "DTextEntry", menu )	-- create the form as a child of frame
							TextEntry:SetPos( 2, 140 )
							TextEntry:SetSize( menu:GetWide() - 4, 60 )
							TextEntry:SetText( "Enter reason here..." )
							TextEntry.OnEnter = function( self )
								
							end					

							local SubmitButton = vgui.Create("DButton", menu)
							SubmitButton:SetPos( 2, 210 )
							SubmitButton:SetSize( menu:GetWide() - 4,20 )
							SubmitButton:SetText("Submit Report")
							SubmitButton:SetTextColor(Color(255,255,255))
							SubmitButton.Paint = function( self, w, h )
								DrawBlur(SubmitButton, 2)
								drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
								draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
							end
							SubmitButton.DoClick = function()							
								local player = PlayerReport:GetSelected()
								local reason = TextEntry:GetValue()
								net.Start("LMMRSWriteReport")
									net.WriteString(player)
									net.WriteString(reason)
								net.SendToServer()
								menu:Close()
								menu:Remove()
								gui.EnableScreenClicker(false)
							end								
							
						else
						
							local SubmitButton = vgui.Create("DButton", menu)
							SubmitButton:SetPos( 2, 210 )
							SubmitButton:SetSize( menu:GetWide() - 4,20 )
							SubmitButton:SetText("Submit Report")
							SubmitButton:SetTextColor(Color(255,255,255))
							SubmitButton.Paint = function( self, w, h )
								DrawBlur(SubmitButton, 2)
								drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
								draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
							end
							SubmitButton.DoClick = function()							
								local player = PlayerReport:GetSelected()
								local reason = PlayerReasonReport:GetSelected()
								net.Start("LMMRSWriteReport")
									net.WriteString(player)
									net.WriteString(reason)
								net.SendToServer()
								menu:Close()
								menu:Remove()
								gui.EnableScreenClicker(false)
							end						
						end
					end
				end
			end
		end

		local CheckOnReportStatusBtn = vgui.Create("DButton", menu)
		CheckOnReportStatusBtn:SetPos( 2, 240 )
		CheckOnReportStatusBtn:SetSize( menu:GetWide() - 4,20 )
		CheckOnReportStatusBtn:SetText("Check report ID status")
		CheckOnReportStatusBtn:SetTextColor(Color(255,255,255))
		CheckOnReportStatusBtn.Paint = function( self, w, h )
			DrawBlur(CheckOnReportStatusBtn, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
		end
		CheckOnReportStatusBtn.DoClick = function()
			local TheMenu = DermaMenu()
			for k, v in pairs(thetable) do
				TheMenu:AddOption( v[1], function()
					net.Start("LMMRSCheckOnReportStatus")
						net.WriteString(v[1])
					net.SendToServer()
					menu:Close()
					menu:Remove()
					gui.EnableScreenClicker(false)					
				end )
			end
			TheMenu:Open()
		
--			Derma_StringRequest(
--				"Check On report",
--				"Input the report ID (report_XXXX)",
--				"",
--				function(text)
--					net.Start("LMMRSCheckOnReportStatus")
--						net.WriteString(text)
--					net.SendToServer()
--					menu:Close()
--					menu:Remove()
--					gui.EnableScreenClicker(false)					
--				end,
--				function(text)
--					menu:Close()
--					menu:Remove()
--					gui.EnableScreenClicker(false)
--				end
--			)
		end	
		
		local RestartBtn = vgui.Create("DButton", menu)
		RestartBtn:SetPos( 2, 270 )
		RestartBtn:SetSize( menu:GetWide() - 4,20 )
		RestartBtn:SetText("Restart")
		RestartBtn:SetTextColor(Color(255,255,255))
		RestartBtn.Paint = function( self, w, h )
			DrawBlur(RestartBtn, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))	
		end
		RestartBtn.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( true )
			MainMenu()
		end		
	end
	
	MainMenu()
end)

net.Receive("LMMRSNotifyAboutReport", function()
	local player = net.ReadString()
	local playerid = net.ReadString()
	local date = net.ReadString()
	local person = net.ReadString()
	local problem = net.ReadString()

	local message =
	[[
	Report By: ]]..player..[[
	
	Reporter ID: ]]..playerid..[[
	
	Date: ]]..date..[[
	
	Reported On: ]]..person..[[
	
	Problem: ]]..problem
	
	Derma_Message(message, "Report", "Alright!")
	
end)

net.Receive("LMMRSNotify", function()
	local message = net.ReadString()
	
	chat.AddText(Color(255,0,0), "[Report System] ", Color(255,255,255), message)
end)

net.Receive("LMMRSCopyItem", function()
	local text = net.ReadString()
	SetClipboardText(text)
end)