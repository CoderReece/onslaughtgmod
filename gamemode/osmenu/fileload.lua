// Xera

local PANEL = { }

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Loading file list.." )
	self.Label:SizeToContents( )

	self.List = vgui.Create( "DListView", self )
	self.List:AddColumn( "Files" )
	function self.List.DoDoubleClick( list, rowid, row )
		RunConsoleCommand( "prop_load", row:GetColumnText( 1 ) )
		self:Close( )
	end

	self:SetTitle( "Load file" )
	self:SetDeleteOnClose( true )
	self:Center( )
	self:MakePopup( )

	RunConsoleCommand( "admin", "getfiles" )
end

function PANEL:PerformLayout( )
	self:SetSize( 200, 200 )

	self.Label:SizeToContents( )
	self.Label:SetPos( 2, 22 )

	self.List:StretchToParent( 2, self.Label:GetTall( ) + 24, 2, 2 )

	DFrame.PerformLayout( self )
end

usermessage.Hook( "RecvLoadfiles", function( msg )
	if not MENU.FileLoad or not MENU.FileLoad:IsValid( ) then
		return
	end
	local len = msg:ReadShort( )
	if len == 0 then
		LocalPlayer( ):ChatPrint( "Got no files" )
		MENU.FileLoad.Label:SetText( "No files." )
		return
	end
	for i = 1, len do
		local str = msg:ReadString( )
		MENU.FileLoad.List:AddLine( string.sub( str, 1, -5 ) )
	end
	MENU.FileLoad.Label:SetText( "Got " .. len .. " file(s)." )
end )

vgui.Register( "onslaught_fileload", PANEL, "DFrame" )