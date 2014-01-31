if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if (CLIENT) then
	SWEP.PrintName			= "Shotgun"
	SWEP.DrawCrosshair		= true
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 60
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.Slot = 2
end

--Swep info and other stuff

SWEP.Base = "ose_base_shotgun"

SWEP.Author	= "Conman420 + Matt"
SWEP.Contact = "FP thread"
SWEP.Purpose = "Pumping lead into enemies."
SWEP.Instructions = "Primary : Fires 8 lead pellets.\nSecondary : Fires 16 lead pellets."
SWEP.AdminSpawnable	= false
SWEP.Spawnable	= false
SWEP.HoldType			= "shotgun"
SWEP.ViewModel	= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel	= "models/weapons/w_shotgun.mdl"
SWEP.Primary.ClipSize = 6
SWEP.Primary.Damage = 11.6
SWEP.Primary.Bullets = 8
SWEP.Primary.Delay = 0.8
SWEP.Primary.Cone = 0.08
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.Damage = 11.6
SWEP.Secondary.Bullets = 16
SWEP.Secondary.Delay = 1
SWEP.Secondary.Cone = 0.0875
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "None"
SWEP.Secondary.Sound = Sound("Weapon_Shotgun.Double")