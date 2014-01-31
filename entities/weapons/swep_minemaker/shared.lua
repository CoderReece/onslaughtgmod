if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Mine Spawner"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 5
end

--Swep info and other stuff
SWEP.Author	= "Conman420"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Makes freindly mines"
SWEP.Instructions = "look and spawn"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_hands.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "SMG1"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.LastReload = CurTime()

function SWEP:Initialize( )
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end
	if ( !self:CanPrimaryAttack() ) then
			self.Owner:SendLua([[surface.PlaySound("common/wpn_denyselect.wav")]])
		return
	end
	self:TakePrimaryAmmo(1)
	local mine = ents.Create("ose_mines")
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	mine:SetPos(pos + ang * 10)
	local ang2 = self.Owner:GetAimVector():Angle()
	ang2 = Angle(ang2.p, ang2.y, ang2.r)
	mine:SetAngles(ang2)
	mine:SetOwner(self.Owner)
	mine:Spawn()
	mine:Activate()
	mine:GetPhysicsObject():SetVelocity(ang * 200)
	self.Owner:EmitSound( "npc/scanner/scanner_siren1.wav" )
	self.Owner:SendLua( [[surface.PlaySound( "npc/scanner/scanner_siren1.wav" )]] )
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
end
