AddCSLuaFile()
 
ENT.Base			= "snpc_police"

ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Combine Flamer"
ENT.Category = "SNPCs"
ENT.Walk = ACT_RUN_RIFLE
ENT.Model = "models/combine_soldier.mdl"

ENT.WalkSpeed = 160
ENT.ChaseSpeed = 160

ENT.NPCHealth = 140
ENT.StartBodyGroup = 0

ENT.DeathSound = Sound("NPC_MetroPolice.Die")
ENT.HurtSound = Sound("NPC_MetroPolice.Pain")
ENT.AlertSound = Sound("NPC_MetroPolice.Attack")
ENT.MissSound = Sound("NPC_MetroPolice.AttackMiss")
ENT.HitSound = Sound("NPC_MetroPolice.AttackHit")
ENT.IdleSounds = {Sound("NPC_MetroPolice.Idle")}

function ENT:GetGuns()
	return {"combine_flamer"}
end

function ENT:SecondInit()
	self:SetColor(Color(255,0,0))
	self:SetSkin(1)
	self.NextActionDelay = CurTime()+math.random(3,7)
end

hook.Add("ShouldCollide","HZG.DisableFlameCollisions",function(a,b)
	if a:GetClass()=="proj_cflamer_ball" then
		return not (b:GetClass():find("proj_") or b:GetClass():find("npc_"))
	end
end)

local function GetTrajectoryVelocity(startingPosition, targetPosition, lob, gravity)

	local physicsTimestep = 1/66
	local timestepsPerSecond = 66
 
	local n = lob * timestepsPerSecond;
 
	local a = physicsTimestep * physicsTimestep * gravity;
	local p = targetPosition;
	local s = startingPosition;
 
	local velocity = (s + (((n * n + n) * a) / 2) - p) * -1 / n

	//This will give us velocity per timestep. The physics engine expects velocity in terms of meters per second
	velocity = velocity / physicsTimestep;
	return velocity;
end

ENT.NextExplode = 0
ENT.NextGrenade = 0
function ENT:RanBehavior()
	if not IsValid(self.Enemy) then return end
	if self.NextActionDelay > CurTime() then return end
	local dist = self.Enemy:GetPos():DistToSqr(self:GetPos())
	if self.NextExplode < CurTime() then
		if dist < (200*200) then
			self.NextExplode = CurTime()+math.random(3,5)
			self.NextActionDelay = CurTime()+math.random(3,7)

			self:StartActivity(ACT_DO_NOT_DISTURB)
			local seq = self:LookupSequence("jump_holding_jump")
			self:SetSequence(seq)
			coroutine.wait(0.2)
			self.loco:Jump()
			coroutine.wait(0.6)
			local max = 20
			for i = 1,max do	
				local ball = ents.Create("proj_cflamer_ball")
				ball:SetPos(self:GetPos())
				ball.Owner = self
				ball:SetCustomCollisionCheck(true)
				ball:Spawn()
				local phys = ball:GetPhysicsObject()
				phys:EnableGravity(false)
				phys:SetVelocityInstantaneous(Vector(0,0,0))
				local ang = self:GetForward():Angle() + Angle(math.random(-25,0),-20+(i*2),0)
				timer.Simple(0,function() phys:ApplyForceCenter(ang:Forward()*1000) end)
			end

			self:StartActivity(ACT_DO_NOT_DISTURB)
			local seq = self:LookupSequence("jump_holding_land")
			self:SetSequence(seq)

			coroutine.wait(0.8)
			self:StartActivity(ACT_RUN_RIFLE)
		end
	end

	if self.NextGrenade < CurTime() then
		if IsValid(self.Enemy) then
			if self:GetRangeSquaredTo(self.Enemy) < 500*500 then
				self.NextActionDelay = CurTime()+math.random(3,7)
				self.NextGrenade = CurTime()+math.random(7,20)
				self.Grenading = true

				self:StartActivity(ACT_DO_NOT_DISTURB)
				local seq = self:LookupSequence("grenThrow")
				self:ResetSequence(seq)
				coroutine.wait(0.7)
				self.Grenading = false
				local pos = self:GetPos()+Vector(0,0,70)+(self:GetRight()*-5)
				local ball = ents.Create("proj_grenade_big")
				ball:SetPos(pos)
				ball:SetOwner(self)
				ball.Owner = self
				ball:Spawn()
				ball:Fire( "SetTimer", 5 )


				local phys = ball:GetPhysicsObject()
				phys:Wake()
				local lobs = math.Round(self:GetRangeTo(self.Enemy)/1000)
				local v = GetTrajectoryVelocity(pos,self.Enemy:GetPos(),1,Vector(0,0,-600))
				phys:SetVelocityInstantaneous(v)
				coroutine.wait(0.5)
				self:StartActivity(ACT_RUN_RIFLE)
				return
			end
		end
	end
end