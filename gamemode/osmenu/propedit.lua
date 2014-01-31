local PANEL = { }

function PANEL:Init( )
	self.IconList = vgui.Create( "DPanelList", self )
	//self.IconList:EnableVerticalScrollbar( true )
	self.IconList:EnableHorizontal( false )
	self.IconList:SetPadding( 4 )
	self.IconList:SetVisible( true )
	self:SetDraggable(false)
	self.PHeight = 0
	self.PYaw = 0
	self.PPitch = 0
	self.PRoll = 0

	local slid1 = vgui.Create("DNumSlider",self)
	slid1:SetText("Height")
	//slid1:SetWide(100)
	slid1:SetValue(0)
	slid1:SetMin(-100)
	slid1:SetMax(200)
	self.EditHeight = slid1
	slid1.ValueChanged = function(frame,value)
		value = tonumber(value)
		if value > 200 or value < -100 then
			frame:SetValue(0)
			return
		end
		self.Target.PHeight = value
	end
	self.IconList:AddItem(slid1)

	local slidp = vgui.Create("DNumSlider",self)
	slidp:SetText("Pitch")
	//slidp:SetWide(100)
	slidp:SetValue(0)
	slidp:SetMin(0)
	slidp:SetMax(360)
	self.EditPitch = slidp
	slidp.ValueChanged = function(frame,value)
		value = tonumber(value)
		if value > 360 or value < 0 then
			frame:SetValue(0)
			return
		end
		self.Target.PPitch = value
	end
	self.IconList:AddItem(slidp)

	local slidp = vgui.Create("DNumSlider",self)
	slidp:SetText("Yaw")
	//slidp:SetWide(100)
	slidp:SetValue(0)
	slidp:SetMin(0)
	slidp:SetMax(360)
	self.EditYaw = slidp
	slidp.ValueChanged = function(frame,value)
		value = tonumber(value)
		if value > 360 or value < -100 then
			frame:SetValue(0)
			return
		end
		self.Target.PYaw = value
	end
	self.IconList:AddItem(slidp)

	local slidp = vgui.Create("DNumSlider",self)
	slidp:SetText("Roll")
	//slidp:SetWide(100)
	slidp:SetValue(0)
	slidp:SetMin(0)
	slidp:SetMax(360)
	self.EditRoll = slidp
	slidp.ValueChanged = function(frame,value)
		value = tonumber(value)
		if value > 360 or value < 0 then
			frame:SetValue(0)
			return
		end
		self.Target.PRoll = value
	end
	self.IconList:AddItem(slidp)

	self:SetSize(300,32*4+22+4)
	self:SetPos(self.IconList:GetWide(),self.IconList:GetTall())
end

function PANEL:PerformLayout()
	self.IconList:StretchToParent( 4, 26, 4, 4 )
	self.IconList:InvalidateLayout()
	DFrame.PerformLayout( self )
end

function PANEL:Close()
	self:SetVisible( false )
	//self:Remove()
end

vgui.Register( "onslaught_propedit", PANEL, "DFrame" )
