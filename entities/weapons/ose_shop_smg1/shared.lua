
SWEP.Base = "ose_base"

if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "SMG1"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

--Swep info and other stuff


SWEP.Author	= "Conman420 + Matt"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Firing inaccurately at short distances"
SWEP.Instructions = "Primary : Fires a bullet.\nSecondary : Fires an impact grenade."
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.HoldType			= "smg"
SWEP.ViewModel	= "models/weapons/v_smg1.mdl"
SWEP.WorldModel	= "models/weapons/w_smg1.mdl"
SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.035
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "SMG1_Grenade"
SWEP.Ball = nil

function SWEP:Holster(wep)

	return true
end

function SWEP:PrimaryAttack()
 	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 )
	self.Owner:SetAnimation(ACT_RANGE_ATTACK_SMG1)

	self.Weapon:SetNextPrimaryFire( CurTime( ) + .07 )
	local prf = WEP_PREFIXES[self.Weapon.Prefix] or {}
	
	local dmgmod = prf.DMG or 0
	local conemod = prf.CONE or 0
	
	local dmg = self.Primary.Damage - (self.Primary.Damage * dmgmod)
	local cone = self.Primary.Cone - (self.Primary.Cone * conemod)
	//if SERVER then
		self:ShootBullet(dmg, self.Primary.Bullets, cone)
	//end
	self:TakePrimaryAmmo( 1 )
	self.Weapon:EmitSound("Weapon_SMG1.Single")
	self.Owner:ViewPunch( Angle( math.random(-1.25,1.25), math.random(-1.25,1.25), 0 ) )
end

function SWEP:Shoot( damage, num_bullets, aimcone )

	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self.Owner:GetShootPos() // Source
	bullet.Dir = self.Owner:GetAimVector() // Dir of bullet
	bullet.Spread = Vector( aimcone, aimcone, 0 ) // Aim Cone
	bullet.Tracer = 3 // Show a tracer on every x bullets
	//bullet.TracerName = "Tracer"
	bullet.Force = 3 // Amount of force to give to phys objects
	bullet.Damage = damage

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end

function SWEP:Reload()

	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end

	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		self:DefaultReload(ACT_VM_RELOAD)
			local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
			self.ReloadingTime = CurTime() + AnimationTime
			self:SetNextPrimaryFire(CurTime() + AnimationTime)
			self:SetNextSecondaryFire(CurTime() + AnimationTime)
 
	end
end

function SWEP:SecondaryAttack( )
	if ( self:Ammo2() < 1 ) then return end
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self.Weapon:EmitSound( "weapons/ar2/ar2_altfire.wav" )
	if SERVER then
		self.Weapon:SetNextPrimaryFire(CurTime()+1)
		self.Weapon:SetNextSecondaryFire(CurTime() + 1)
		self.Ball = ents.Create("grenade_ar2")
		self.Ball:SetOwner(self.Owner)
		self.Ball:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50)
		self.Ball:SetAngles(self.Owner:GetAimVector():Angle())
		self.Ball:SetVelocity(self.Owner:GetAimVector() * 1500) --Lol'd.
		self.Ball:Spawn()
		self.Ball:Activate()
		self:TakeSecondaryAmmo(1)
	end
end