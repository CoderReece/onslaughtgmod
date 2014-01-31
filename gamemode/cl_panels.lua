
if SERVER then
	AddCSLuaFile( "osmenu/admin.lua" )
	AddCSLuaFile( "osmenu/prop_spawn.lua" )
	AddCSLuaFile( "osmenu/fileload.lua" )
	AddCSLuaFile( "osmenu/Ammo_buy.lua")
	AddCSLuaFile( "osmenu/commands.lua" )
	AddCSLuaFile( "osmenu/mapload.lua" )
	AddCSLuaFile( "osmenu/player_stats.lua" )
	AddCSLuaFile( "osmenu/propedit.lua")
	AddCSLuaFile( "osmenu/class.lua" )
	AddCSLuaFile( "osmenu/osemodel.lua")
	return
end
include("osmenu/osemodel.lua")
include( "osmenu/admin.lua" )
include( "osmenu/prop_spawn.lua" )
include( "osmenu/fileload.lua" )
include( "osmenu/Ammo_buy.lua" )
include( "osmenu/commands.lua" )
include( "osmenu/mapload.lua")
include( "osmenu/player_stats.lua")
include( "osmenu/class.lua")
include( "osmenu/propedit.lua")

local W, H = ScrW(), ScrH()

------------------------- SPAWN MENU ------------------------
if MENU then MENU:Remove() end
function GM:OnSpawnMenuOpen( )
	if MENU == nil or not MENU:IsValid( ) then
		MENU=vgui.Create( "onslaught_menu" )
		MENU:SetSkin("ose")
	else
		MENU:SetVisible( true )
	end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
end

function GM:OnSpawnMenuClose( )
	if MENU and MENU:IsValid( ) and MENU:IsVisible( ) then
		MENU:SetVisible( false )
	end
	RememberCursorPosition( )
	gui.EnableScreenClicker( false )
end

local PANEL = { }

function PANEL:Init( )

	MENU = self
	self:SetSize(360+256,750)
	self:SetPos(0,W * 0.024)
	self:SetTitle( "Onslaught Menu" )
	self.ContentPanel = vgui.Create( "DPropertySheet", self )
	self:ShowCloseButton( false )
	self.ContentPanel:AddSheet( "Build", vgui.Create( "onslaught_PropSpawn", self ), "icon16/brick_add.png", true, true )
	self.ContentPanel:AddSheet( "Class", vgui.Create( "onslaught_classselect", self ), "icon16/group.png", true, true )
	self.ContentPanel:AddSheet( "Commands", vgui.Create("onslaught_commands", self), "icon16/application_osx_terminal.png", true, true )
	self.ContentPanel:AddSheet( "Settings", vgui.Create("onslaught_stats", self), "icon16/page_red.png", true, true )

	if LocalPlayer( ):IsAdmin( ) then
		self.ContentPanel:AddSheet( "Admin", vgui.Create( "onslaught_admin", self ), "icon16/star.png", true, true )
	end

end

function PANEL:Close( )
end

function PANEL:PerformLayout( )

	self.ContentPanel:StretchToParent( 4, 26, 4, 4 )

	DFrame.PerformLayout( self )

end

vgui.Register( "onslaught_menu", PANEL, "DFrame" )

----------------- HELP MENU ------------------------
function HelpMenu( )
	if HELP == nil or not HELP:IsValid( ) then
		vgui.Create( "onslaught_help" )
	else
		HELP:SetVisible( true )
	end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition( )
end

local PANEL = { }

function PANEL:Init( )

	HELP = self
	self:SetSize(360+256,750)
	self:SetPos(0,W * 0.024)
	self:SetTitle( "Onslaught Help" )

	self.ListList = vgui.Create( "DPanelList", self )
	self.List = {}
	self.ListWeapons = {}
	self.ListCollapse = {}

	self.ListCollapse[0] = vgui.Create( "DCollapsibleCategory", self.ListList )
	self.ListCollapse[0].Header.OnMousePressed = function(mcode)
			for k,v in pairs (self.ListCollapse) do
				if v:GetExpanded() == true then v:Toggle() end
			end
			self.ListCollapse[k]:Toggle()
		end

	self.ListList:AddItem( self.ListCollapse[0] )

	for k,v in pairs (CLASSES) do
		self.ListCollapse[k] = vgui.Create( "DCollapsibleCategory", self.ListList )
		self.ListCollapse[k]:SetSize( 610,20 )
		self.ListCollapse[k]:SetLabel( v.NAME )
		self.ListCollapse[k]:SetVisible( true )
		self.ListCollapse[k]:SetExpanded( 0 )
		self.ListList:AddItem( self.ListCollapse[k] )
		self.ListCollapse[k].Header.OnMousePressed = function(mcode)
			self.ListCollapse[k]:Toggle()
		end

		self.List[k] = vgui.Create( "DPanelList", self.ListCollapse[k] )
		self.List[k]:EnableVerticalScrollbar( false )
		self.List[k]:EnableHorizontal( true )
		self.List[k]:SetPadding( 4 )
		self.List[k]:SetVisible( true )
		self.ListCollapse[k]:SetContents(self.List[k])

		local text = vgui.Create("DLabel",self.List[k])
		text:SetText(v.DSCR)
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,5)

		text = vgui.Create("DLabel",self.List[k])
		text:SetText("Health: "..v.HEALTH)
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,20)

		text = vgui.Create("DLabel",self.List[k])
		if v.ARMOR then text:SetText("Armor: "..v.ARMOR) else text:SetText("Armor: 0") end
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,35)

		text = vgui.Create("DLabel",self.List[k])
		text:SetText("Speed: "..math.Round(v.SPEED/3).."%")
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,50)

		text = vgui.Create("DLabel",self.List[k])
		text:SetText("Jump: "..math.Round(v.JUMP/1.6).."%")
		text:SizeToContents()
		text:SetWidth(360+256-8)
		text:SetPos(5,65)

		local bpos = 80

		for _,w in pairs(WEAPON_SET[k])do
			if WEAPON_MDL[w] then
				local ent = ents.Create("prop_physics") -- lol ailias filthy hack
				ent:SetAngles(Angle(0,0,0))
				ent:SetPos(Vector(0,0,0))
				ent:SetModel(WEAPON_MDL[w].MODEL)
				ent:Spawn()
				ent:Activate()
				ent:PhysicsInit( SOLID_VPHYSICS )
				local ico = vgui.Create( "DModelPanel", self.List[k] )
				ico:SetModel(WEAPON_MDL[w].MODEL)
				ico.Skin = math.random(0,util.GetModelInfo(k).SkinCount-1)
				ico.Entity:SetSkin(ico.Skin)
				ico:SetSize(80,80)
				ico:SetPos(bpos,20)
				bpos = bpos + 80

				if IsValid(ent:GetPhysicsObject()) then
					local center = ent:OBBCenter()
					local dist = ent:BoundingRadius()*1.2
					ico:SetLookAt( center )
					ico:SetCamPos( center+Vector(dist,dist,dist) )
				end

				ico:SetToolTip( WEAPON_MDL[w].NAME )
				ico:InvalidateLayout( true )
				ent:Remove()
			end
		end
	end
	self.ListCollapse[1]:SetExpanded( 1 )
end

function PANEL:Close( )
	if HELP and HELP:IsValid( ) and HELP:IsVisible( ) then
		HELP:SetVisible( false )
	end
	RememberCursorPosition( )
	gui.EnableScreenClicker( false )
end

function PANEL:PerformLayout( )
	self.ListList:StretchToParent( 4, 26, 4, 4 )
	self.ListList:InvalidateLayout()
	for k,v in pairs (self.List) do
		v:SetSize(360+256,100)
		v:InvalidateLayout()
	end
	for k,v in pairs (self.ListCollapse) do
		v:SizeToContents( )
		v:InvalidateLayout()
	end
	self:SizeToContents( )
	DFrame.PerformLayout( self )
end

vgui.Register( "onslaught_help", PANEL, "DFrame" )
