local PANEL = { }

function PANEL:Init( )
	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetText( "Click on an icon to spawn a prop." )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SizeToContents( )

	self.ListList = vgui.Create( "DListLayout", self )

	self.IconList = {}
	self.IconListCollapse = {}
	for k,v in pairs (MODELGROUPS) do
		self.IconList[k] = vgui.Create( "DIconLayout", self )
		self.IconList[k]:SetVisible( true )
		//self.IconList[k]:DockMargin(-5,-5,-5,-5)
		//self.IconList[k]:DockPadding(-5,-5,-5,-5)
		self.IconListCollapse[k] = self.ListList:Add("DCollapsibleCategory")
		self.IconListCollapse[k]:SetSize( 610,78+22 )
		self.IconListCollapse[k]:SetLabel( v )
		self.IconListCollapse[k]:SetContents(self.IconList[k])
		//self.ListList:AddItem( self.IconListCollapse[k] )
	end

	for k,v in pairs( MODELS ) do
		local ent = ents.CreateClientProp(k)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(Vector(0,0,0))
		ent:Spawn()
		ent:Activate()
		ent:PhysicsInit( SOLID_VPHYSICS )
		local hlth = math.Round(MASS[k]) //global mass table
		if v.COST then hlth = v.COST end
		local ico
		if v.GROUP==6 then
			ico = self.IconList[6]:Add( "DModelPanel" )
		elseif hlth >= 500 then
			ico = self.IconList[1]:Add( "DModelPanel" )
		elseif hlth <= 100 then
			ico = self.IconList[3]:Add( "DModelPanel" )
		else
			ico = self.IconList[2]:Add( "DModelPanel" )
		end
		ico:DockMargin(-5,-5,-5,-5)
		ico:DockPadding(-5,-5,-5,-5)
		ico:SetModel(k)
		ico.Skin = math.random(0,util.GetModelInfo(k).SkinCount-1)
		ico.Entity:SetSkin(ico.Skin)
		ico.DoClick = function( ico ) RunConsoleCommand("ose_prop",k) RunConsoleCommand("use","swep_propspawner") end
		ico.DoRightClick = function(ico) PANEL:OpenMen(ico, k) end

		ico:SetSize(64,64)

		ico:SetToolTip("Cost: $"..math.Round(hlth*1.05) .."\nHealth: "..hlth )

		ico:InvalidateLayout( true )
		ico.PaintOver = function(ico,w,h)
			draw.RoundedBox(0,0,h-12,w,16,Color(40,40,40,100))
			draw.SimpleText(hlth,"DermaDefault",24,h-13,Color(255,255,255))
		end
		ent:Remove()
	end
end

function PANEL:OpenMen(ico, model)
	local icomenu = DermaMenu()
	if util.GetModelInfo(model).SkinCount > 1 then
		icomenu:AddOption("Change skin",function()
										ico.Skin = ico.Skin or math.random(0,util.GetModelInfo(model).SkinCount-1)
										ico.Skin = ico.Skin + 1
										if ico.Skin == util.GetModelInfo(model).SkinCount then
											ico.Skin = 0
										end
										ico.Entity:SetSkin(ico.Skin)
										ico:InvalidateLayout( true )
									end)
		icomenu:AddSpacer()
	end
	icomenu:AddOption("Delete all of type", function() print(model) RunConsoleCommand("deletemodel", model) end)
	icomenu:Open()

end

function PANEL:PerformLayout( )
	self:StretchToParent( 2, 24, 2, 2 )
	self.Label:SetPos( 2, 2 )
	self.ListList:StretchToParent( 4, 26, 4, 4 )
 	self.ListList:InvalidateLayout()
	for k,v in pairs (self.IconList) do
	--v:StretchToParent( 4, 26, 4, 4 )
	v:SizeToContents( )
 	v:InvalidateLayout()
	end
end

vgui.Register( "onslaught_PropSpawn", PANEL, "DPanel" )