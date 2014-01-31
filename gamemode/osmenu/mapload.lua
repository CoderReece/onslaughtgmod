// Xera

local PANEL = { }

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Loading file list.." )
	self.Label:SizeToContents( )

	self.List = vgui.Create( "DListView", self )
	self.List:AddColumn( "Maps" )
	function self.List.DoDoubleClick( list, rowid, row )
		RunConsoleCommand( "votemap", row:GetColumnText( 1 ) )
		self:Close( )
	end

	self:SetTitle( "Load file" )
	self:SetDeleteOnClose( true )
	self:Center( )
	self:MakePopup( )

	timer.Simple(0.5, function() RunConsoleCommand("getmaps") end)
end

function PANEL:PerformLayout()
	self:SetSize( 200, 200 )

	self.Label:SizeToContents()
	self.Label:SetPos( 2, 22 )

	self.List:StretchToParent( 2, self.Label:GetTall( ) + 24, 2, 2 )

	DFrame.PerformLayout( self )
end

function PANEL:Close()
	self:SetVisible( false )
	RememberCursorPosition( )
	gui.EnableScreenClicker( false )
	self:Remove()
end


usermessage.Hook( "sendmaps", function( msg )
	if not MENU.MapLoad or not MENU.MapLoad:IsValid( ) then
		return
	end
	local len = msg:ReadShort( )
	if len == 0 then
		LocalPlayer( ):ChatPrint( "Got no files" )
		MENU.MapLoad.Label:SetText( "No files." )
		return
	end
	for i = 1, len do
		local str = msg:ReadString( )
		MENU.MapLoad.List:AddLine(str)
	end
	MENU.MapLoad.Label:SetText( "Got " .. len .. " file(s)." )
end )

vgui.Register( "onslaught_mapvote", PANEL, "DFrame" )

function ForceMapVote()
	gui.EnableScreenClicker( true )
	MENU.MapLoad = vgui.Create("onslaught_mapvote")
end

concommand.Add("openmap",ForceMapVote)
