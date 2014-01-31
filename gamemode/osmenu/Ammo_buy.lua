local ammoup = false

local PANEL = { }

function PANEL:Init( )
	ammoup = true
	self.IconList = vgui.Create( "DPanelList", self )
	self.IconList:EnableVerticalScrollbar( true )
	self.IconList:EnableHorizontal( true )
	self.IconList:SetPadding( 4 )
	self.IconList:SetVisible( true )
	self:SetDraggable(false)

	self:SetTitle("Click on the ammo icon to buy it!")
	local ammos = 0
	for k,v in pairs(LocalPlayer().AMMOS[convCTable[LocalPlayer():GetNWInt("class")]]) do
		local AMMO = AMMOS[v]
			local ammo = vgui.Create( "DModelPanel", self )
			ammo:SetModel(AMMO.MODEL)
			ammo.DoClick = function( ammo ) local amt if LocalPlayer():KeyDown(IN_SPEED) then amt=3 else amt = 1 end RunConsoleCommand("buy_ammo", v, amt) end
			ammo:SetSize( 80,80 )

			local ent = ents.CreateClientProp(AMMO.MODEL) -- lol ailias filthy hack
			ent:SetAngles(Angle(0,0,0))
			ent:SetPos(Vector(0,0,0))
			ent:Spawn()
			ent:Activate()
			ent:PhysicsInit( SOLID_VPHYSICS )

			ammo:SetCamPos(Vector(25,-10,15))
			ammo:SetLookAt(Vector( 0, 0, 0 ))
			
			ent:Remove()

			ammo:InvalidateLayout( true )
			ammo:SetToolTip( AMMO.NAME.." \nCost: "..AMMO.PRICE.."\nAmount: "..AMMO.QT )
			self.IconList:AddItem( ammo )
			ammos = ammos + 1
	end
	self:SetSize( 18+ammos*80, 118)
	self:Center()
end

function PANEL:PerformLayout()
	self.IconList:StretchToParent( 4, 26, 4, 4 )
	self.IconList:InvalidateLayout()
	DFrame.PerformLayout( self )
end

function PANEL:Close()
	--self:SetVisible( false )
	RememberCursorPosition( )
	gui.EnableScreenClicker( false )
	RunConsoleCommand("ammo_closed")
	ammoup = false
	self:Remove()
end

vgui.Register( "onslaught_ammobuy", PANEL, "DFrame" )

local function create()
	AMMO = vgui.Create( "onslaught_ammobuy" )
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
end

usermessage.Hook("openammo", create)