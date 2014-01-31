if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Turret Spawner"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Makes freindly turrets"
SWEP.Instructions = "look and spawn"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_hands.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.LastReload = CurTime()

function SWEP:Initialize( )

end

function SWEP:Deploy()
	if SERVER then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:Message("Fire: Spawn turret.")
		self.Owner:Message("Alt Fire: Delete turret.")
		self.Owner:Message("Reload: Delete all turrets.")
		return true
	end
end

function SWEP:CanSpawnBuilding( )
	if 700 > self.Owner:GetNetworkedInt( "money") then
		self.Owner:Message("Insufficient funds!", Color(255,100,100,255))
		return false
	end
	local c = 0
	for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
		if v:GetOwner() == self.Owner then c=c+1 end
	end
	return c < 2
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end
	if not self:CanSpawnBuilding( ) then
		self.Owner:Message("You can't spawn any more turrets!", Color(255,100,100,255))
		self.Owner:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	end
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 200)
	trace.filter = self.Owner
	local trc = util.TraceLine(trace)
	if !trc.Hit then return end

	local trt = ents.Create("npc_turret_floor")
	trt:SetPos(trc.HitPos + Vector(0,0,1))
	local ang = self.Owner:EyeAngles()
	trt:SetAngles(Angle(0,ang.yaw,0))
	trt:SetKeyValue("spawnflags","512")
	trt:SetOwner(self.Owner)
	trt:Spawn()
	trt:Activate()
	trt:GetPhysicsObject():EnableMotion(false)
	trt:SetNetworkedEntity("owner",self.Owner)
	local trtctrl = ents.Create("sent_turretcontroller") --this entity controls the turrets health and kills it etc.
	trtctrl:SetPos(trt:GetPos())
	trtctrl:SetParent(trt)
	trtctrl:Spawn()
	trtctrl:Activate()
	trtctrl:SetOwner(self.Owner)
	trt.Controller = trtctrl
	trt:SetNWInt("health",trtctrl.Shealth)
	self.Owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	self.Owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	self.Owner:Message((TURRET_COST * -1).." [Spawned Turret]", Color(255,100,100,255))
	self.Owner:SetNetworkedInt( "money", self.owner:GetNetworkedInt( "money" ) - TURRET_COST )
end

function SWEP:SecondaryAttack( )

	if CLIENT then
		return
	end

	local trace = { }
	trace.start = self.Owner:GetShootPos( )
	trace.endpos = trace.start + ( self.Owner:GetAimVector( ) * 1000 )
	trace.filter = self.Owner
	local tr = util.TraceLine( trace )

	if not tr.Hit then return end
	if not IsValid( tr.Entity ) then return end

	if tr.Entity:GetClass() == "npc_turret_floor" && tr.Entity:GetOwner() == self.Owner then
		tr.Entity.Controller:Remove( )
		tr.Entity:Remove( )
	elseif tr.Entity:GetClass() == "sent_turretcontroller" && tr.Entity:GetOwner() == self.Owner  then
		tr.Entity.Turret:Remove( )
		tr.Entity:Remove( )
	else
		return
	end

	self.Owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	self.Owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
	self.Weapon:SetNextSecondaryFire( CurTime( ) + 0.5 )

end

function SWEP:Reload()
	if SERVER then
		if self.LastReload + 1 < CurTime() then

		for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
			if v:GetOwner() == self.Owner then v.Controller:Remove() v:Remove() end
		end
		self.LastReload = CurTime()
		self.Owner:Message("Deleted all turrets.", Color(100,255,100,255))
		end
	end
end
