local PANEL = {}

function PANEL:Init()
	self:SetModel("models/weapons/w_pistol.mdl")
	//self:FixCamera()
end

function PANEL:SetWeapon(weapon)
	local weapontable = weapon < 14 and HL2_WEPS[weapon] or NEW_WEAPONS[weapon] or HL2_WEPS[1]
	self:SetModel(weapontable.MODEL)
	self.WeaponTable = weapons.Get(weapontable.WC)
	self.ModelTable = {}
	for k,v in pairs(self.WeaponTable.WElements or {}) do
		self.ModelTable[k] = {}
		self.ModelTable[k].table = v
		self.ModelTable[k].entity = ClientsideModel(v.model, RENDERGROUP_OPAQUE)
		self.ModelTable[k].entity:SetMaterial(v.material)
		self.ModelTable[k].entity:SetColor(v.color)		
	end
	self:FixCamera()
end

function PANEL:FixCamera()
	local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
	self:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.30, 0.30, 0.25) + Vector(30, 0, 15))
	self:SetLookAt((PrevMaxs + PrevMins) / 2)
end

function PANEL:Paint()
	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end

	local w, h = self:GetSize()
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096 )
	cam.IgnoreZ( true )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end
	self.Entity:DrawModel()
	self:DrawOtherModels()
	
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()

	self.LastPaint = RealTime()
end

function PANEL:DrawOtherModels()
	
	if self.ModelTable then
		for k,v in pairs(self.ModelTable) do
			local model = v.entity
			if not model then continue end
			local id = self.Entity:LookupBone("ValveBiped.Bip01_R_Hand")
			local pos,ang = self.Entity:GetBonePosition(id)

			pos = self.Entity:LocalToWorld(pos + v.table.pos)
			ang = ang + v.table.angle
			if v.table.rel and v.table.rel !="" and (self.ModelTable[v.table.rel] and self.ModelTable[v.table.rel].pos and self.ModelTable[v.table.rel].angle) then
				pos = self.Entity:LocalToWorld(self.Entity:WorldToLocal(self.ModelTable[v.table.rel].pos)+v.table.pos)
				ang = self.ModelTable[v.table.rel].angle + v.table.angle
			end
			//ang:RotateAroundAxis(ang:Up(), v.table.angle.y)
			//ang:RotateAroundAxis(ang:Right(), v.table.angle.p)
			//ang:RotateAroundAxis(ang:Forward(), v.table.angle.r)

			local matrix = Matrix()
			matrix:Scale(v.table.size)
			model:EnableMatrix( "RenderMultiply", matrix )
			model:SetPos(pos)
			model:SetAngles(ang)
			
			model:DrawModel()
		end
	end
end

vgui.Register('OSEModelPanel', PANEL, 'DModelPanel')