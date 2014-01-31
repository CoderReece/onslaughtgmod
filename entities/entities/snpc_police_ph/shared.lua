AddCSLuaFile()
 
ENT.Base			= "snpc_police"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Phantom Police"
ENT.Category = "SNPCs"
ENT.Walk = ACT_RUN_AIM_RIFLE
ENT.Model = "models/Police.mdl"

ENT.WalkSpeed = 140
ENT.ChaseSpeed = 140

ENT.NPCHealth = 45
ENT.StartBodyGroup = 0

ENT.DeathSound = Sound("NPC_MetroPolice.Die")
ENT.HurtSound = Sound("NPC_MetroPolice.Pain")
ENT.AlertSound = Sound("NPC_MetroPolice.Attack")
ENT.MissSound = Sound("NPC_MetroPolice.AttackMiss")
ENT.HitSound = Sound("NPC_MetroPolice.AttackHit")
ENT.IdleSounds = {Sound("NPC_MetroPolice.Idle")}

--ENT.Guns = {"weapon_smg1","weapon_pistol"}
function ENT:GetGuns()
	return {"combine_silsmg"} 
end

function ENT:SecondInit()
	self:SetRenderMode(1)
	self:SetColor(Color(100,0,200,200))
	self.Weapon:SetRenderMode(1)
end

function ENT:FireWeapon()
	if self:GetColor().a < 200 then return 0.115 end
	local d = self.BaseClass.FireWeapon(self)
	return d
end

function ENT:Teleport()
	local ep = self.Enemy:EyePos()
	--range is 500, radius will be 500
	local centerPoint = ep
	local result      = Vector(0,0,0)
	local angle      = Angle(0,math.random(0,360),0) //between 0 and 2 * PI, angle is in radians
	local distance      = 500;

	local tr = {}
	tr.start = centerPoint
	tr.endpos = centerPoint + angle:Forward() * distance
	tr.filter = {self,self.Weapon}
	local trace = util.TraceLine(tr)

	self:SetPos(trace.HitPos and trace.HitPos + (trace.HitNormal * 16) or tr.endpos)
end

ENT.LastTeleport = 0
function ENT:Injured(dmginfo)
	if self.LastTeleport + 5 > CurTime() then return end
	self.LastTeleport = CurTime()
	self:SetColor(Color(100,0,200,0))
	self.Weapon:SetColor(Color(255,255,255,0))
	self:Teleport()
	timer.Simple(math.random(0.5,2),function()
		if not IsValid(self) then return end
		self:SetColor(Color(100,0,200,200))
		self.Weapon:SetColor(Color(255,255,255,255))
	end)
end