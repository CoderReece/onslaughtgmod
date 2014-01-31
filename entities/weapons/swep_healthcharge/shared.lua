
if SERVER then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight	= 1
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom	= false
end

if CLIENT then
	SWEP.PrintName = "Health Charger"
	SWEP.DrawCrosshair = true
	SWEP.DrawAmmo = true
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false
	SWEP.Slot = 1
	
	SWEP.VElements = {
		["some_unique_name"] = { type = "Quad", bone = "square", rel = "", pos = Vector(-3.569, -5.895, 4), angle = Angle(-167.663, 0, 0), size = 0.09, draw_func = nil}
	}

end

SWEP.Instructions = "Primary : Damage Beam | Secondary : Heal Beam \n Reload : Health Explosion"
SWEP.ViewModel	= "models/weapons/v_physics.mdl"
SWEP.WorldModel	= "models/weapons/w_physics.mdl"
SWEP.mdl = "models/weapons/v_physics.mdl"


SWEP.Heat = 100
SWEP.Overheat = false --For now..
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

function SWEP:Deploy()
	return true
end

local tick = CurTime()
function SWEP:Think( )
	if !self.Owner:KeyDown( IN_ATTACK ) && !self.Owner:KeyDown( IN_ATTACK2 ) then
		if self:GetNWInt("mode") != 0 then
			self:SetNWInt("mode",0)
		end
	end
	
	if self.Heat <= 0 and self.Overheat == false then
		self.Overheat = true
		timer.Simple(10,function() self.Overheat=false self.Heat = 100 end)
	end
	
	if self.Overheat==true then
		--Smoke effect here
	end
	
	if tick + 0.05 < CurTime() and self:GetNWInt("mode")==0 and not self.Overheat then
		tick = CurTime()
		self.Heat = self.Heat + 1
		if self.Heat > 100 then self.Heat = 100 end
	end
end

function SWEP:PrimaryAttack( )
	if self:GetNWInt("mode") != 1 then
		self:SetNWInt("mode",1)
	end
	
	if self.Heat <= 0 then return end --We're overheated. Don't shoot.
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .05 )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + .05 )
	
	self.Heat = self.Heat - 1

	local tr = util.GetPlayerTrace( self.Owner )
 	local trace = util.TraceLine( tr )
 	if (!trace.Hit) then return end
	local ent = trace.Entity
	local hitpos = trace.HitPos
	if CLIENT then
		self.mdl = "models/weapons/v_physcannon.mdl"
	else
		if IsValid(ent) && ent:IsNPC() && !ent:IsProp() then
			ent:SetHealth(ent:Health() - 3)
			if ent:Health() <= 0 then
				ent:TakeDamage(1,self.Owner, self.Owner)
			end
		end
	end
end

function SWEP:SecondaryAttack( )
	if self:GetNWInt("mode") != 2 then
		self:SetNWInt("mode",2)
	end
	
	if self.Heat <= 0 then return end --We're overheated. Don't shoot.
	self.Weapon:SetNextPrimaryFire( CurTime( ) + .1 )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + .1 )

	self.Heat = self.Heat - 1
	
	local tr = util.GetPlayerTrace( self.Owner )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	local ent = trace.Entity
	local hitpos = trace.HitPos

	if CLIENT then
		self.mdl = "models/weapons/v_superphyscannon.mdl"
	else
		if IsValid(ent) && ent:IsPlayer() && ent:Health() < ent:GetMaxHealth() then
			ent:AddHealth(4)
		end
	end
end

function SWEP:GetViewModelPosition(pos,ang)
	local ViewModel = LocalPlayer():GetViewModel()
	if !ViewModel:IsValid() then return pos,ang end
	ViewModel:SetModel( self.mdl )
	return pos,ang
end

function SWEP:Reload()
	if self.Heat > 60 then return end
	if SERVER then
		for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(),500)) do
			if v:IsPlayer() then v:AddHealth(200) end
		end
	end
	local effectdata = EffectData()
	effectdata:SetOrigin( self.Owner:GetPos() )
	effectdata:SetEntity( self.Owner )
	util.Effect( "support_healthexplode", effectdata )
	self.Heat = self.Heat - 40
end

// Here on is all SWEP construction kit code. Without it, you wouldn't be able to tell which weapons are which.

function SWEP:Initialize()
	// other initialize code goes here
	if SERVER then
		self:SetWeaponHoldType( "physgun" )
	else
	
		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		self.BuildViewModelBones = function( s )
			if LocalPlayer():GetActiveWeapon() == self and self.ViewModelBoneMods then
				for k, v in pairs( self.ViewModelBoneMods ) do
					local bone = s:LookupBone(k)
					if (!bone) then continue end
					local m = s:GetBoneMatrix(bone)
					if (!m) then continue end
					m:Scale(v.scale)
					m:Rotate(v.angle)
					m:Translate(v.pos)
					s:SetBoneMatrix(bone, m)
				end
			end
		end
		
	    self.VElements["some_unique_name"].draw_func = function( weapon ) --Matt's Code
			draw.RoundedBox(2,-30,0,85,20,Color(80,80,80,200))

			local heat = 100-self.Heat
			
			local col = Color(255/(100/heat),0,255/(100/self.Heat))
			
			if heat < 100 then
				draw.SimpleText("Heat: "..heat.."%", "HUD", -30, 0, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			else				
				draw.SimpleText("OVERHEAT!","HUD",-30,0,Color(255,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
        end	--End Matt's Code
	end
end


function SWEP:OnRemove()
	
	// other onremove code goes here
	
	if CLIENT then
		self:RemoveModels()
	end
	
end
	

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		local ViewModel = LocalPlayer():GetViewModel()
		if !ViewModel:IsValid() then return end
 		local spos = ViewModel:GetAttachment(1)

		local TexOffset = CurTime()*-2.0
		
		if not self.Overheat then
			if self:GetNWInt("mode") == 1 then //Begin old code
				local tr = util.GetPlayerTrace( self.Owner )
				local trace = util.TraceLine( tr )
				if (!trace.Hit) then return end

				render.SetMaterial( Material( "onslaught/refract_ring") )
				render.UpdateRefractTexture()
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial( Material( "cable/redlaser" )  )
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial(Material("sprites/redglow1"))
				render.DrawSprite(trace.HitPos, 20, 20, Color( 255, 50, 50 ))

			elseif self:GetNWInt("mode") == 2 then
				local tr = util.GetPlayerTrace( self.Owner )
				local trace = util.TraceLine( tr )
				if (!trace.Hit) then return end

				render.SetMaterial( Material( "onslaught/refract_ring"))
				render.UpdateRefractTexture()
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial(Material( "cable/physbeam"))
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial(Material("sprites/animglow02"))
				render.DrawSprite(trace.HitPos, 10, 10, Color( 50, 50, 255 ))
			end	//End old code
		end
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		if vm.BuildBonePositions ~= self.BuildViewModelBones then
			vm.BuildBonePositions = self.BuildViewModelBones
		end

		if (self.ShowViewModel == nil or self.ShowViewModel) then
			vm:SetColor(Color(255,255,255,255))
		else
			// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
			vm:SetColor(Color(255,255,255,1))
		end
		
		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
		
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				model:SetModelScale(v.size)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		local spos = self.Weapon:GetAttachment(1) //Begin old code

		local TexOffset = CurTime()*-2.0

		if not self.Overheat then
			if self:GetNWInt("mode") == 1 then
				local tr = util.GetPlayerTrace( self.Owner )
				local trace = util.TraceLine( tr )
				if (!trace.Hit) then return end

				render.SetMaterial( Material( "onslaught/refract_ring") )
				render.UpdateRefractTexture()
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial( Material( "cable/redlaser" )  )
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial(Material("sprites/redglow1"))
				render.DrawSprite(trace.HitPos, 20, 20, Color( 255, 50, 50 ))

			elseif self:GetNWInt("mode") == 2 then
				local tr = util.GetPlayerTrace( self.Owner )
				local trace = util.TraceLine( tr )
				if (!trace.Hit) then return end

				render.SetMaterial( Material( "onslaught/refract_ring"))
				render.UpdateRefractTexture()
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial(Material( "cable/physbeam"))
				render.DrawBeam( spos.Pos, trace.HitPos, 15,TexOffset*-0.4,TexOffset*-0.4, Color( 255, 255, 255, 255 ) )

				render.SetMaterial(Material("sprites/animglow02"))
				render.DrawSprite(trace.HitPos, 10, 10, Color( 50, 50, 255 ))
			end	//End old code
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				model:SetModelScale(v.size)
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists ("../"..v.model) ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("../materials/"..v.sprite..".vmt")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end

	function SWEP:OnRemove()
		self:RemoveModels()
	end

	function SWEP:RemoveModels()
		if (self.VElements) then
			for k, v in pairs( self.VElements ) do
				if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
			end
		end
		if (self.WElements) then
			for k, v in pairs( self.WElements ) do
				if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
			end
		end
		self.VElements = nil
		self.WElements = nil
	end

end
