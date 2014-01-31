if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Crossbow"
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
SWEP.Purpose = "Shoot and kill"
SWEP.Instructions = "Shoot and kill"
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.ViewModel	= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel	= "models/weapons/w_crossbow.mdl"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "xbowbolt"
SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.Zoomed = false

SWEP.LastReload = CurTime()

function SWEP:Initialize( )
	if SERVER then
		self:SetWeaponHoldType( "crossbow" )
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:SetNextPrimaryFire(CurTime() + 3)
	if SERVER then
		local bolt = ents.Create("ose_bolt")
		bolt:SetOwner(self.Owner)
		local ang = self.Owner:GetAimVector()
		local pos = self.Owner:GetShootPos()
		bolt:SetPos(pos + (ang * 10))
		bolt:SetAngles(ang:Angle())
		bolt:SetVelocity(ang * 3500)
		bolt:SetPhysicsAttacker( self.Owner )
		bolt:Spawn()
		bolt:Activate()
	end
	self.Weapon:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo( 1 )
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 )
	self.Owner:ViewPunch(Angle(-10,0,0))
	self:Reload()
end

function SWEP:SecondaryAttack( )
	if !self.Zoomed then
		self.Owner:SetFOV( 30, 0 )
		self.Zoomed = true
	else
		self.Zoomed = false
		self.Owner:SetFOV( 80, 0 )
	end
end


