// Conman

local PANEL = { }

local bCursorEnter = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

local bCursorExit = function( b )
	if b.m_colTextHovered then DLabel.ApplySchemeSettings( self ) end
end

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Player Settings." )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SizeToContents( )
	self.Checks = {}
	local lab = vgui.Create( "DLabel", self )
	lab:SetText("Options:")
	lab:SetTextColor( Color( 255, 255, 255, 255 ) )
	lab:SizeToContents()
	lab:SetPos(4, 17)
	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Use modern HUD" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetConVar( "ose_hud" )
	chk:SetValue( GetConVarNumber( "ose_hud" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)

	local chk = vgui.Create( "DCheckBoxLabel" , self )
	chk:SetText( "Hide Tips" )
	chk:SetConVar( "ose_hidetips" )
	chk:SetTextColor( Color(255,255,255,255) )
	chk:SetValue( GetConVarNumber( "ose_hidetips" ) )
	chk:SizeToContents()
	table.insert(self.Checks, chk)
	self:InvalidateLayout()
end

function PANEL:Paint()
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	for k,v in pairs(self.Checks) do
		v:SetPos(10,(k * 20) + 18)
	end
end

vgui.Register( "onslaught_stats", PANEL, "DPanel" )