include("shared.lua")

--This function is run when the turret is damaged
local function TurretDamaged(message)
	local ent=message:ReadShort()
	local damage=message:ReadShort()
	local etable=ents.GetByIndex(ent):GetTable()
	etable.AlphaFade=255			   --How much to fade out
	etable.FadeLength=1			   --This is the fade length, from start to finish, used for the ratio
	etable.EndFade=CurTime()+etable.FadeLength --This is the time the fade ends - stops fading after that
end


local function TurretDeath(message)
	local ent=message:ReadEntity()
	local etable=ent:GetTable()
	etable.AlphaFade=255			   --How much to fade out
	etable.FadeLength=3			   --This is the fade length, from start to finish, used for the ratio
	etable.EndFade=CurTime()+etable.FadeLength --This is the time the fade ends - stops fading after that
end


--Texture stuff.
local TEX_SIZE		= 200 --256
usermessage.Hook("turret_hook",TurretDamaged)
usermessage.Hook("turret_death",TurretDeath)
	
function ENT:Initialize()
	self.Entity:SetNWEntity("target",NullEntity())
	self.Entity:SetNWBool("alive",true)
	self.Entity:SetNWInt("maxhp",100)
	self.Entity:SetNWInt("hp",100)
	self.Entity:SetNWBool("havetarget",false)
	
	self.HitMat = Material( "sprites/turretlight" )
	self.aID=0
	self.aID2=0
	self.AlphaFade=0
	self.EndFade=0
	self.FadeLength=0
end

function ENT:Think()
	local target=self.Entity:GetNWEntity("target")
	if target and target:IsValid() then
		self:Aim(target:LocalToWorld(target:OBBCenter()))
	end
end


function ENT:Draw()
	--Draw model
	self.Entity:DrawModel()
	
	--If attachment ID for gun barrel hasn't been found, look it up.
	if self.aID==0 then
		self.aID=self.Entity:LookupAttachment("eyes")
		self.ap = self.Entity:GetAttachment(self.aID)
	end
	
	--If attachment ID for gun flashlight hasn't been found, look it up.
	if self.aID2==0 then
		self.aID2=self.Entity:LookupAttachment("light")
	end

	--Calculate laser and hit-sprite alpha - Fades smoothly when hit
	local alpha=255;
	if (self.AlphaFade >0 && self.EndFade >= CurTime() && self.FadeLength>0) then
		alpha=alpha-( self.AlphaFade * ( (self.EndFade-CurTime()) / self.FadeLength) )
	end

	--Calculate light color - red when it has a target, orange when it is scanning. Will fade if hit, or if dying.
	local lightcolor = Color(255,128,0,alpha)		--Orange
	if(self.Entity:GetNWBool("havetarget") == true) then
		lightcolor = Color(255,0,0,alpha)		--Red
	end

	if (!self.Entity:GetNWBool("alive")) then
		self.Entity:SetColor(Color(255-alpha,255-alpha,255-alpha,255-alpha))
		lightcolor = Color(255,math.Clamp(255-alpha*2,0,255),0,255-alpha)
	end
	
	--Draw turret flashlight sprite
	render.SetMaterial(self.HitMat)
	local ap2 = self.Entity:GetAttachment( self.aID2 )
	render.DrawSprite(ap2.Pos, 16, 16, lightcolor )
end