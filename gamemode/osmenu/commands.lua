// Xera

local PANEL = { }

local bCursorEnter = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

local bCursorExit = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Click on a button to choose a class." )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SizeToContents( )
	self.Buttons = { }
	--------------------------------------------------------------------
	local b = vgui.Create("DButton",self)
	b:SetText("Set SpawnPoint")
	function b.DoClick( b )
		RunConsoleCommand("spawnpoint")
	end
	table.insert( self.Buttons, b )
	--------------------------------------------------------------------
	local b = vgui.Create("DButton",self)
	b:SetText("Reset custom spawnpoint")
	function b.DoClick( b )
		RunConsoleCommand("resetspawn")
	end
	table.insert( self.Buttons, b )
	--------------------------------------------------------------------
	local b = vgui.Create("DButton",self)
	b:SetText("Voteskip Build")
	function b.DoClick( b )
		RunConsoleCommand("voteskip")
	end
	table.insert( self.Buttons, b )
	--------------------------------------------------------------------
	local b = vgui.Create("DButton",self)
	b:SetText("Sell all props")
	function b.DoClick( b )
		RunConsoleCommand("sellall")
	end
	table.insert( self.Buttons, b )
	--------------------------------------------------------------------
	local b = vgui.Create("DButton",self)
	b:SetText("Help I'm stuck!")
	function b.DoClick( b )
		RunConsoleCommand("stuck")
	end
	table.insert( self.Buttons, b )
	--------------------------------------------------------------------
	local b = vgui.Create("DButton",self)
	b:SetText("Votemap")
	function b.DoClick( b )
		MENU.MapLoad = vgui.Create( "onslaught_mapvote" )
	end
	table.insert( self.Buttons, b )
	--------------------------------------------------------------------
	local b = vgui.Create("DButton",self)
	b:SetText("Save Kills")
	function b.DoClick( b )
		RunConsoleCommand("saveprof")
	end
	table.insert( self.Buttons, b )
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	local y = self.Label:GetTall( ) + 4
	for k,v in pairs( self.Buttons ) do
		v:SetPos( 2, y )
		v:SetSize( self:GetWide( ) - 4, 25 )
		y = y + 27
	end
end

vgui.Register( "onslaught_commands", PANEL, "DPanel" )