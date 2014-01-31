if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Dispenser Spawner"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= true
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Makes dispensers that heal you"
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

function SWEP:Initialize()

end

function SWEP:Deploy()
	if SERVER then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:Message("Fire: Spawn dispenser.")
		self.Owner:Message("Alt Fire: Delete dispenser.")
		self.Owner:Message("Reload: Delete all dispensers.")
		return true
	end
end

function SWEP:CanSpawnBuilding( )
	if DISP_COST > self.Owner:GetNetworkedInt( "money") then
		self.Owner:Message("Insufficient funds!", Color(255,100,100,255))
		return false
	end
	local c = 0

	for k,v in pairs(ents.FindByClass("sent_dispenser")) do
		if v.Owner == self.Owner then c=c+1 end
	end
	if PHASE == "BATTLE" then
		return c < 2
	else
		return c < 1
	end
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end
	if ( !self:CanSpawnBuilding() ) then
		self.Owner:Message("You can't spawn any more dispensers!", Color(255,100,100,255))
		self.Owner:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	end
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 200)
	trace.filter = self.Owner
	local trc = util.TraceLine(trace)
	if !trc.Hit then return end
	if trc.Entity then
		if trc.Entity:IsPlayer() || trc.Entity:GetClass() == "sent_dispenser" || trc.Entity:GetClass() == "npc_turret_floor" || trc.Entity:GetClass() == "sent_turretcontroller" then return end
	end

	local ang = trc.HitNormal:Angle()
	if ang.pitch < 10 || ang.pitch > 350 then
		local disp = ents.Create("sent_dispenser")
		disp:SetPos(trc.HitPos)
		disp:SetAngles(ang)
		disp.Owner = self.Owner
		disp:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		disp:Spawn()
		disp:Activate()
		disp.Class = self.Owner:GetNWInt("class")
		disp.Type = PHASE
		if trc.Entity && trc.HitNonWorld then
			disp:SetParent(trc.Entity)
		end
		disp:GetPhysicsObject():EnableMotion(false)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Owner:Message((DISP_COST * -1).." [Dispenser Spawned]",Color(100,255,100,255))
		self.Owner:SetNetworkedInt( "money", self.Owner:GetNetworkedInt( "money" ) - DISP_COST )
		self.Weapon:EmitSound( "npc/scanner/scanner_electric1.wav" )
		self.Owner:SendLua( [[ surface.PlaySound( "npc/scanner/scanner_electric1.wav" ) ]] )
	else
		self.Owner:Message("Must be spawned on a vertical wall!")
	end
end

function SWEP:SecondaryAttack()
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

	--local ed = EffectData( )
	--ed:SetEntity( tr.Entity )
	--util.Effect( "propspawn", ed )

	if tr.Entity:GetClass() == "sent_dispenser" && tr.Entity.Owner == self.Owner then
	tr.Entity:Remove( )
	else
	return
	end

	self.Owner:EmitSound( "npc/scanner/scanner_electric1.wav" )
	self.Owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_electric1.wav" )]] )
end

function SWEP:Reload()
	if SERVER then
		if self.LastReload + 0.5 < CurTime() then

		for k,v in pairs(ents.FindByClass("sent_dispenser")) do
			if v.Owner == self.Owner then v:Remove() end
			end
		self.LastReload = CurTime()
		self.Owner:Message("Deleted all dispensers.", Color(100,255,100,255))
		end
	end
end
