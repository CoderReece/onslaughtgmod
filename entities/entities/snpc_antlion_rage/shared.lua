AddCSLuaFile()
 
ENT.Base			= "snpc_antlion"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Raging Lion"
ENT.Category = "SNPCs"
ENT.Walk = ACT_RUN
ENT.Model = "models/antlion.mdl"

ENT.IdleSpeed = 200
ENT.ChaseSpeed = 200

ENT.AttackBeforeDamageDelay = 0.75
ENT.AttackAfterDamageDelay = 0.25
ENT.Damage = 4
ENT.Range = 60

ENT.NPCHealth = 600 --lol
ENT.JumpChance = 5

function ENT:SecondInit()
	self:SetModelScale(0.5,0)
	self.IdleSpeed = 200
	self.ChaseSpeed = 200
end

function ENT:Injured()
	if self.Damage == 4 and self:Health() < 450 then
		self:SetModelScale(2,5)
		local desiredTime = CurTime()+5
		local curTime = CurTime()
		timer.Create("SetColor.Antlion."..self:EntIndex(),5/20,20,function()
			if not IsValid(self) then return end
			local mins = 40 - (36*(desiredTime-CurTime())/5)
			self:SetCollisionBounds(Vector(-mins,-mins,0),Vector(mins,mins,64))
			self.Damage = 50 - (46*(desiredTime-CurTime())/5)
			self.Range = 170 - (130*(desiredTime-CurTime())/5)
			self.IdleSpeed = 500 - (300*(desiredTime-CurTime())/5)
			self.ChaseSpeed = 500  - (300*(desiredTime-CurTime())/5)
			self:SetColor(Color(100 + (155*(desiredTime-CurTime())/5),0+(255*(desiredTime-CurTime())/5),0+(255*(desiredTime-CurTime())/5)))
		end)
	end
end