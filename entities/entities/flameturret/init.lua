
include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
//AddCSLuaFile("entemu.lua")

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos+Vector(0,0,90)
	local ent = ents.Create("flameturret")
	ent:SetPos(SpawnPos)
	ent:SetAngles(ply:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:DropToFloor()
	return ent	
end

function ENT:Initialize()
	self.Entity:SetNWEntity("target",NullEntity())
	self.Entity:SetNWBool("alive",true)
	self.Entity:SetNWInt("maxhp",50)
	self.Entity:SetNWInt("hp",50)
	self.Entity:SetNWBool("havetarget",false)
	
	self.aID=1
	self.ap=0
	self.yaw=0
	self.yawDir=0
	self.ThinkTimer=0
	self.ThinkDelay=0.05
	self.FireDelay = 0.1
	self.LastBall=CurTime()
	self.FirePos=Vector(0,0,0)
	self.AimVector=Vector(0,0,0)
	self.LastFire = 0
	self.DoThink=function()
		self:ThinkT()
	end
	
	self.Sounds={
	["death"] = "npc/combine_gunship/gunship_pain.wav",
	["fire"] = Sound("fire_large"),
	}
	for k,v in pairs(self.Sounds) do
		util.PrecacheSound(v)
	end
	
	self.Entity:SetModel("models/combine_turrets/floor_turret.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	
	
	self:RestPose()
	self.ThinkTimer=timer.Simple(self.ThinkDelay,self.DoThink)
end

function ENT:OnRemove()
	timer.Destroy(self.ThinkTimer)
end

function ENT:OnTakeDamage(dmg)
	if self.Entity:GetNWBool("alive") then
		--Turret HP
		local amount = dmg:GetDamage()
		
		local recipfilter=RecipientFilter()
		recipfilter:AddAllPlayers()
		
		umsg.Start("turret_hook",recipfilter)
		umsg.Short(self.Entity:EntIndex())
		umsg.Short(amount)
		umsg.End()
		
		self:SetHP(self.Entity:GetNWInt("hp")-amount)
		if self.Entity:GetNWInt("hp")>0 then
			self.Entity:TakePhysicsDamage(dmg)
		end
	end
	self.Entity:TakePhysicsDamage(dmg)
end

--Wrapper for SWEP think
function ENT:Think()
	local target=self.Entity:GetNWEntity("target")
	if target && self:IsValidTarget(target) then 
		local pos=target:LocalToWorld(target:OBBCenter())
		if self:Aim(pos) then
			self.Entity:EmitSound(self.Sounds["fire"])
		end
	else
		self.Entity:StopSound(self.Sounds["fire"])
	end
end

--Actual entity's think function... faster, it needs to be to shoot bullets - varies think speed... when searching targets, slower.
function ENT:ThinkT()
	--Turret is alive
	if(self.Entity && self.Entity:IsValid() && self.Entity:GetNWBool("alive")) then
			local ap=self.Entity:GetAttachment(self.aID)
			local target=self.Entity:GetNWEntity("target")
			
			if target && self:IsValidTarget(target) && !target:IsOnFire() then 
				local pos=target:LocalToWorld(target:OBBCenter())
				
				
				if self:Aim(pos) then
					self:FirePrimary(pos)
				else
					self:LostTarget()
					self:AcquireTarget()
				end
			else
				self:LostTarget()
				self:AcquireTarget()
			end
		self.ThinkTimer=timer.Simple(self.ThinkDelay,self.DoThink)
	end
end

--The turret picks a target to shoot at. If the target dies, or if it doesn't have one, it tries to find one every time it thinks.
function ENT:AcquireTarget()
	local entities=ents.FindInSphere(self.Entity:GetPos(),400)
	for k,v in pairs(entities) do
		if self:IsValidTarget(v) then
			self.ThinkDelay=0.02
			self.Entity:SetNWEntity("target",v)
			self.Entity:SetNWBool("havetarget",true)
			return
		end
	end
end

function ENT:IsValidTarget(ent)
	--Valid ent? Can it aim twoards it? Is it a live player or NPC?
	if ent:IsValid() && self:GetYawPitch(ent:GetPos())!=false && ent:IsNPC() then
		
		--Make sure nothing is blocking the path
		local tr={};
		tr.start=self.Entity:LocalToWorld(Vector(0,0,50))
		tr.endpos=ent:LocalToWorld(ent:OBBCenter())
		
		tr.filter=self.Entity
		
		local traceRes=util.TraceLine(tr)
		if tr.endpos:Distance(traceRes.HitPos)<=400 then
			return true
		end
	end
	return false
end

--Turret "rests", loses the target and slows down it's thinking process
function ENT:LostTarget() --Changed the name to match the action's context
	self:RestPose()
	self.Entity:SetNWEntity("target",NullEntity())
	self.ThinkDelay=0.5
	self.Entity:SetNWBool("havetarget",false)
end

--The turret faces nothing and stops firing
function ENT:RestPose()
	self.Entity:SetPoseParameter("aim_yaw",0)
	self.Entity:SetPoseParameter("aim_pitch",0)
	self.Entity:SetSequence( "idle" )
end
 



--Fires a bullet. This calls the SWEP's primary attack function.
function ENT:FirePrimary(vec)
		if not self.LastFire + self.FireDelay > CurTime() then return end
		self.LastFire = CurTime()
		--Set the fire position. This ensures that aim is spot on.
		self.FirePos=vec
		if self.aID==0 then
			self.aID=self.Entity:LookupAttachment("eyes")
			self.ap = self.Entity:GetAttachment(self.aID)
		end
		local ap=self.Entity:GetAttachment(self.aID)

		local tr={};
		tr.start=self.Entity:LocalToWorld(Vector(0,0,50))
		tr.endpos=vec
		tr.filter=self.Entity
		
		local trace = util.TraceLine( tr )
		if (!trace.Hit) then return end
		local hitpos = trace.HitPos
		
		local bullet = {}
		bullet.Num = 1
		bullet.Src=self:GetPos()
		bullet.Dir=(self.FirePos-ap.Pos):Normalize()
		bullet.Spread=Vector(0.06,0.06,0)
		bullet.Tracer="AR2Tracer"
		bullet.Force=2
		bullet.Damage=1
 
		self:FireBullets(bullet)
		self:MuzzleFlash()
		/*local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( ap.Pos )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Entity)
		effectdata:SetNormal((self.FirePos-ap.Pos):Normalize())
		util.Effect( "flamer", effectdata )
		if self.LastBall + 0.25 <= CurTime() then
			local dmg = 8
			local victims=ents.FindInCone(ap.Pos,(self.FirePos-ap.Pos):Normalize(), 400, 0 )
			for k,v in pairs(victims) do
				if v:IsNPC() && v:GetClass() != "npc_turret_floor" then
					if !v:IsOnFire() then
						v:TakeDamage(dmg,self.Owner,self.Owner)
						dmg = dmg / 1.5
					end
					if v:Health() / v:GetMaxHealth() < .20 then
						v.Igniter = self:GetOwner()
						v:Ignite(10,40)
					end
				end
			end
			self.LastBall = CurTime()
		end*/
end

function ENT:SetHP(amount)
	self.Entity:SetNWInt("hp",amount)
	
	--HP drops below 0 and it's still alive, so kill it
	if(self.Entity:GetNWInt("hp") <= 0 and self.Entity:GetNWBool("alive")) then
		self.Entity:EmitSound(self.Sounds["death"])
		self.Entity:SetNWBool("alive",false)
		
		local recipfilter=RecipientFilter()
		recipfilter:AddAllPlayers()
			
		umsg.Start("turret_death",recipfilter)
			umsg.Entity(self.Entity)
		umsg.End()
		
		local function removeMe()
			self.Entity:Remove()
		end
		timer.Simple(3,removeMe)
		
		local PhysObj=self.Entity:GetPhysicsObject()
		if PhysObj:IsValid() then
			--self.Entity:SetSolid(SOLID_NONE)
			PhysObj:EnableMotion(true)
			PhysObj:Wake()
		end
	end
end