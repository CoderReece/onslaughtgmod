// Xera

local PANEL = { }

function PANEL:Init( )

	self.Rows = { }

	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Admin-only functions." )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SizeToContents( )

	self.PanelList = vgui.Create( "DPanelList", self )
	self.PanelList:SetPadding( 2 )
	self.PanelList:EnableVerticalScrollbar( true )

	self:AddAdminButton( "Start build", "Forces the game to switch to build mode.", function( ) RunConsoleCommand( "Admin", "2" ) end, "onslaught/brick_add" )
	self:AddAdminButton( "Start battle", "Forces the game to switch to battle mode.", function( ) RunConsoleCommand( "Admin", "1" ) end, "gui/silkicons/bomb" )
	self:AddAdminButton( "Set spawn time", "Allows you to set the amount of time before players respawn.", function( )
		Derma_StringRequest( "Spawn time",
			"Amount of time between player spawns",
			tostring( GAMEMODE.Config.SPAWN_TIME ),
			function( Str )
				RunConsoleCommand( "Admin", "6", Str )
			end,
			function( ) end,
			"Set", "Cancel" )
	end )
	self:AddAdminButton( "Set maximum NPCs", "Allows you to set the maximum amount of NPCs.", function( )
		Derma_StringRequest( "Max NPCs",
			"Maximum amount of NPCs",
			tostring( GAMEMODE.Config.MAX_NPCS ),
			function( Str )
				RunConsoleCommand( "Admin", "3", Str )
			end,
			function( ) end,
			"Set", "Cancel" )
	end )
	self:AddAdminButton( "Set build time", "Allows you to set the time allowed for building.", function( )
		Derma_StringRequest( "Build time",
			"Time in seconds to allow for building",
			tostring( GAMEMODE.Config.BUILDTIME ),
			function( Str )
				RunConsoleCommand( "Admin", "4", Str )
			end,
			function( ) end,
			"Set", "Cancel" )
	end )
	self:AddAdminButton( "Set battle time", "Allows you to set the time allowed for battling.", function( )
		Derma_StringRequest( "Battle time",
			"Time in seconds to allow for battling",
			tostring( GAMEMODE.Config.BATTLETIME ),
			function( Str )
				RunConsoleCommand( "Admin", "5", Str )
			end,
			function( ) end,
			"Set", "Cancel" )
	end )
	self:AddAdminButton( "Change Map", "Force an instant change map.", function( )
		Derma_StringRequest( "Map name",
			"Enter map name (without .bsp)",
			tostring( GetMap() ),
			function( Str )
				RunConsoleCommand( "Admin", "map", Str )
			end,
			function( ) end,
			"ChangeMap!", "Cancel" )
	end )
	self:AddAdminButton( "Kill", "Kill Selected Player", function( )
		local menu = DermaMenu()
		menu:SetPos(gui.MouseX( ),gui.MouseY( ))
		for k,v in pairs(player.GetAll()) do
			if v != LocalPlayer() && v:Alive() then
				menu:AddOption(v:Nick(), function() RunConsoleCommand( "Admin", "kill", v:EntIndex()) end )
			end
		end
		menu:AddOption("Close Menu")
		menu:Open()
	end )
	self:AddAdminButton( "Kick", "Kick Selected Player", function( )
		local menu = DermaMenu()
		menu:SetPos(gui.MouseX( ),gui.MouseY( ))
		for k,v in pairs(player.GetAll()) do
			if v != LocalPlayer() then
				menu:AddOption(v:Nick(), function() RunConsoleCommand( "Admin", "kick", v:Nick()) end )
			end
		end
		menu:AddOption("Close Menu")
		menu:Open()
	end )
	self:AddAdminButton( "Ban", "Ban Selected Player", function( )
		local menu = DermaMenu()
		menu:SetPos(gui.MouseX( ),gui.MouseY( ))
		for k,v in pairs(player.GetAll()) do
			if v != LocalPlayer() then
				menu:AddOption(v:Nick(), function() RunConsoleCommand( "Admin", "ban", v:Nick()) end )
			end
		end
		menu:AddOption("Close Menu")
		menu:Open()
	end )

	self:AddAdminButton( "Give selection SWEP", "Gives you the SWEP used to select props for saving.", function( )
		RunConsoleCommand( "admin", "select" )
	end )
	self:AddAdminButton( "Set owner", "Allows you to set the owner of the selected props.", function( )
		local menu = DermaMenu( )
		for k,v in pairs( player.GetAll( ) ) do
			menu:AddOption( v:Nick( ), function( ) RunConsoleCommand( "admin", "owner", tostring( k ) ) end )
		end
		menu:Open( )
	end )
	self:AddAdminButton( "Save selected", "Saves the selected props to a file.", function( )
		Derma_StringRequest( "File",
		"File to save select props to",
		"",
		function( Str )
			RunConsoleCommand( "prop_save", string.gsub( Str, " ", "_" ) )
		end,
		function( ) end,
		"Save", "Cancel" )
	end )
	self:AddAdminButton( "Load file", "Opens the load file dialog.", function( )
		MENU.FileLoad = vgui.Create( "onslaught_fileload" )
	end )
end

local function AdminButtonDoClick( b )
	if not LocalPlayer( ):IsAdmin( ) then
		Derma_Message( "Not an admin!", "Error", "OK" )
	else
		b:AdminClick( )
	end
end

function PANEL:AddAdminButton( txt, ttip, func, img )
	local btn = vgui.Create( "onslaught_iconbutton", self )
	btn.DoClick = AdminButtonDoClick
	btn.AdminClick = func
	btn:SetText( txt )
	btn:SetSize( self:GetWide( ) - 4, 20 )

	if ttip then
		btn:SetTooltip( ttip )
	end

	if img then
		btn:Setup( img )
	end
	self.PanelList:AddItem( btn )
end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	self.PanelList:StretchToParent( 2, 2, 2, 2 )
end

vgui.Register( "onslaught_admin", PANEL, "DPanel" )

PANEL = { }

function PANEL:Init( )
end

function PANEL:PerformLayout( )
	if self.Image then
		self.Image:SetSize( 16, 16 )
		self.Image:SetPos( self:GetWide( ) - 18, 2 )
	end
end

function PANEL:Setup( mat )
	self.Image = vgui.Create( "DImage", self )
	self.Image:SetMaterial( Material( mat ) )
end

vgui.Register( "onslaught_iconbutton", PANEL, "DButton" )

function GetMap()
	local worldspawn = ents.GetByIndex(0)
	local mapname = worldspawn:GetModel()

	mapname = string.gsub(mapname,"(%w*/)","")
	mapname = string.gsub(mapname,".bsp","")

	return mapname
end