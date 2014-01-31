-- DO NOT REDISTRIBUTE THIS GAMEMODE
GM.Name 	= "Onslaught 2.0 BETA"
GM.Author	= "Conman420, Ailia, Scooby, Xera & Matt Damon" -- DO NOT CHANGE THIS
GM.Email	= ""
GM.Website	= ""
-- DO NOT REDISTRIBUTE THIS GAMEMODE

PHASE = "BUILD"
ZOMBIEMODE_ENABLED = false //Hardmode basically. NPCs take half damage while players take double.
//This is normally on
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CLASSES = {}
CLASSES[1] = {NAME = "Scout", 	SPEED = 650, 	JUMP = 260, 			WEAPON_SET = 1, HEALTH = 100, 	AMMO = {2,11}, 		MODEL = "models/player/Group03/Female_02.mdl",	DSCR = "A fast and agile class, the scout is perfect for those who like to be in the action."}
CLASSES[2] = {NAME = "Soldier", SPEED = 250, 	JUMP = 120, ARMOR = 50, WEAPON_SET = 2, HEALTH = 200,	AMMO = {1,2,8,6}, 	MODEL = "models/player/Group03/male_08.mdl",	DSCR = "A perfect for those defensive players. Featuring a wide range of weapons, the soldier is a perfect well balanced class." }
CLASSES[3] = {NAME = "Engineer",SPEED = 300, 	JUMP = 160, 			WEAPON_SET = 3, HEALTH = 120, 	AMMO = {2,4}, 		MODEL = "models/player/Group03/Female_03.mdl",	DSCR = "With the ability to make turrets and place mines, the engineer is truly an invaluable class."  }
CLASSES[4] = {NAME = "Sniper", 	SPEED = 310, 	JUMP = 160, 			WEAPON_SET = 4, HEALTH = 80,	AMMO = {7,5}, 		MODEL = "models/player/Group03/male_06.mdl",	DSCR = "The sniper is a long-ranged class with low health, but extremely high damage."}
CLASSES[5] = {NAME = "Pyro", 	SPEED = 375, 	JUMP = 210, 			WEAPON_SET = 5, HEALTH = 175, 	AMMO = {2,10,12,8}, MODEL = "models/player/Group03/male_07.mdl",	DSCR = "The pyro comes with a flamethrower, which makes it easy to deal with many enemies at once."	}
CLASSES[6] = {NAME = "Support", SPEED = 450, 	JUMP = 220, 			WEAPON_SET = 6, HEALTH = 120, 	AMMO = {}, 			MODEL = "models/player/Group03/Female_04.mdl",	DSCR = "Acting as the team medic, the support helps keep the team alive."  }

TAUNTS = {}
TAUNTS[1] = {"vo/episode_1/npc/female01/cit_kill02.wav","vo/npc/female01/gotone01.wav","vo/episode_1/npc/female01/cit_kill04.wav", "vo/episode_1/npc/female01/cit_kill09.wav", "vo/episode_1/npc/female01/cit_kill06.wav","vo/episode_1/npc/female01/cit_kill11.wav","vo/episode_1/npc/female01/cit_kill16.wav"}
TAUNTS[2] = {"vo/episode_1/npc/male01/cit_kill03.wav", "vo/episode_1/npc/male01/cit_kill14.wav", "vo/episode_1/npc/male01/cit_kill19.wav", "vo/npc/male02/reb2_buddykilled13.wav","vo/episode_1/npc/male01/cit_kill03.wav"}
TAUNTS[3] = {"vo/coast/odessa/male01/nlo_cheer01.wav", "vo/coast/odessa/male01/nlo_cheer02.wav", "vo/coast/odessa/male01/nlo_cheer03.wav", "vo/coast/odessa/male01/nlo_cheer04.wav" }
TAUNTS[4] = {"vo/episode_1/npc/male01/cit_kill15.wav","vo/npc/male01/gotone01.wav","vo/npc/barney/ba_gotone.wav", "vo/npc/male01/gotone02.wav"}
TAUNTS[5] = {"vo/ravenholm/monk_kill01.wav","vo/ravenholm/monk_kill03.wav","vo/ravenholm/madlaugh01.wav","vo/ravenholm/monk_kill08.wav","vo/ravenholm/monk_kill05.wav","vo/ravenholm/madlaugh02.wav", "vo/ravenholm/madlaugh04.wav"}
TAUNTS[6] = {"vo/episode_1/npc/female01/cit_kill02.wav","vo/npc/female01/gotone01.wav","vo/episode_1/npc/female01/cit_kill04.wav", "vo/episode_1/npc/female01/cit_kill09.wav", "vo/episode_1/npc/female01/cit_kill06.wav","vo/episode_1/npc/female01/cit_kill11.wav","vo/episode_1/npc/female01/cit_kill16.wav"}

//this dictates the default weaponset given to a class. see HL2_WEPS
WEAPON_SET = {}
WEAPON_SET[1] = {}
WEAPON_SET[1][1] = 13
WEAPON_SET[1][2] = 2
WEAPON_SET[1][3] = 8
WEAPON_SET[2] = {}
WEAPON_SET[2][1] = 13
WEAPON_SET[2][2] =	2
WEAPON_SET[2][3] =	1
WEAPON_SET[2][4] = 	3
WEAPON_SET[3] = {}
WEAPON_SET[3][1] = 7
WEAPON_SET[3][2] = 2
WEAPON_SET[3][3] = 11
WEAPON_SET[3][4] = 4
WEAPON_SET[4] = {}
WEAPON_SET[4][1] = 13
WEAPON_SET[4][2] = 5
WEAPON_SET[4][3] = 6
WEAPON_SET[5] = {}
WEAPON_SET[5][1] = 13
WEAPON_SET[5][2] =	2
WEAPON_SET[5][3] =	12
WEAPON_SET[5][4] = 3
WEAPON_SET[6] = {}
WEAPON_SET[6][1] = 13
WEAPON_SET[6][2] = 9
WEAPON_SET[6][3] = 10

convCTable = {"sct","sld","eng","snp","pyr","sup"} //convertClassTable, used to convert class numbers to respective class strings. Used on EItems and Items.

				--Default weapons that are spawned with. This is used for prefixes.

HL2_WEPS = {
/*1*/	{NAME="AR2",			WC="ose_ar2",				SLOT=3,	AD={1,6},	MODEL = "models/weapons/w_IRifle.mdl",					DESC="Combine Pulse Rifle, standard issue to combine units.\nSecondary Fire spits out a combine ball!"},
/*2*/	{NAME="9MM Pistol",		WC="ose_pistol",			SLOT=2,	AD={2},		MODEL = "models/weapons/W_pistol.mdl",					DESC="Generic 9mm Pistol, standard issue to metropolice."},
/*3*/	{NAME="Grenade",		WC="ose_frag",				SLOT=4,	AD={8},		MODEL = "models/weapons/w_grenade.mdl",					DESC="Thrown explosive that affects a medium radius.",													NOPRF=true},
/*4*/	{NAME="Turret Maker",	WC="ose_turretmaker",		SLOT=4,				MODEL = "models/Combine_turrets/Floor_turret.mdl",		DESC="Creates friendly turrets in the blink of an eye!\nRequires a large amount of resources, though.",	NOPRF=true},
/*5*/	{NAME=".357 Magnum",	WC="ose_357",				SLOT=2,	AD={5},		MODEL = "models/weapons/w_357.mdl",						DESC="A high-powered handgun that still works somehow."},
/*6*/	{NAME="Crossbow",		WC="swep_xbow",				SLOT=3, AD={7},		MODEL = "models/weapons/w_crossbow.mdl",				DESC="Created years ago, and still proves useful.",														NOPRF=true},
/*7*/	{NAME="Wrench",			WC="swep_repair",			SLOT=1,				MODEL = "models/weapons/w_crowbar.mdl",					DESC="Repairs stuff faster than your hands can.",														NOPRF=true},
/*8*/	{NAME="Scattergun",		WC="swep_scatter",			SLOT=3, AD={11},	MODEL = "models/weapons/w_shotgun.mdl",					DESC="High-powered shotgun. Pretty light, too."},
/*9*/	{NAME="Medi-Cannon",	WC="swep_healthcharge",		SLOT=3,				MODEL = "models/weapons/w_physics.mdl",					DESC="Created by Combine Scientists. Unfortunately,\nthe instructions came in their language.",			NOPRF=true},
/*10*/	{NAME="Dispensers",		WC="swep_dispensermaker",	SLOT=4,				MODEL = "models/props_combine/health_charger001.mdl",	DESC="Place dispensers that heal people.",																NOPRF=true},
	//{NAME="Gravity Gun",	WC="weapon_physcannon",		SLOT=3,				MODEL = "models/weapons/w_physics.mdl",					DESC="Created by Dr. Kleiner. Cloned by Magnusson.\n Copyrighted by Magnusson.",						NOPRF=true},
/*11*/	{NAME="Shotgun",		WC="ose_shotgun",			SLOT=1,	AD={4},		MODEL = "models/weapons/w_shotgun.mdl",					DESC="Extreme damage in a reliable package.\nSecondary Fire fires 2 shells at once!"},
/*12*/	{NAME="Flamethrower",	WC="swep_flamethrower",		SLOT=1, AD={10},	MODEL = "models/weapons/w_smg1.mdl",					DESC="Roasted enemies by the dozen!",																	NOPRF=true},
/*13*/	{NAME="Crowbar",		WC="ose_crowbar",			SLOT=1,				MODEL = "models/weapons/w_crowbar.mdl",					DESC="Symbolic to some. Godlike to others.",															NOPRF=true}
}


// Negative values increase damage and enlarge cone.
WEP_PREFIXES = {}
WEP_PREFIXES[1] = {NAME = "",DESC="A generic weapon.",CHANCE=100,DMG=0,CONE=0}
WEP_PREFIXES[2] = {NAME = "Fiery ",DESC="This weapon has a chance to light people on fire!\n+15% Damage\n-5% Accuracy",CHANCE=7.5,DMG=-.15,CONE=-0.05,FX=function(atk,tr,dmg) //2.5% damage boost, but 10% worse cone
        local impact = EffectData()
        impact:SetOrigin(dmg:GetDamagePosition())
        impact:SetNormal(tr.HitNormal) 
		util.Effect("onslaught_fire",impact)
	end} --Every 14 bullets an NPC is lit on fire.
WEP_PREFIXES[3] = {NAME = "Plagued ",DESC="This weapon has a chance to poison enemies.\n-10% Damage",CHANCE=15,DMG=0.1,FX=function(atk,tr,dmg)
        local impact = EffectData()
        impact:SetOrigin(dmg:GetDamagePosition())
        impact:SetNormal(tr.HitNormal) 
		util.Effect("onslaught_poison",impact)
	end} --Every 6-7 bullets an NPC is poisoned.
WEP_PREFIXES[4] = {NAME = "Explosive ",DESC="This weapon has a chance to deal splash damage!\n+20% Damage\n-20% Accuracy",CHANCE=17.5,DMG=-0.2,CONE=-0.2,FX=function(atk,tr,dmg) //10% damage boost, 20% worse cone
        local impact = EffectData()
        impact:SetOrigin(dmg:GetDamagePosition())
        impact:SetNormal(tr.HitNormal) 
		util.Effect("onslaught_explode",impact)
	end} --Every 5-6 bullets a small explosion happens.
WEP_PREFIXES[5] = {NAME = "Lucky ",DESC="This weapon has a chance to deal devastating damage!\n-20% Damage",CHANCE=6.67,DMG=0.2} --Critical hits every 16 bullets, but messes up damage for the rest.
WEP_PREFIXES[6] = {NAME = "Vampiric ",DESC="This weapon has a chance to give the player health.\n-4 Damage",CHANCE=30,DMG=0.1} -- -10% Damage, but gives health every 3-4 shots.
WEP_PREFIXES[7] = {NAME = "Tormented ",DESC="This weapon takes away health every shot, but knocks people back!\n+30% Damage!",CHANCE=100,DMG=-0.3} --Player takes damage every bullet, but with a huge damage boost.
WEP_PREFIXES[8] = {NAME = "Precise ",DESC="This weapon has a 33% chance to fire a bullet exactly where you aim!\n+20% accuracy",CONE=0.2,CHANCE=33} --this is too good on bullet sprayers. see about that.

AMMOS = {}
AMMOS[1] = 	{AMMO = "AR2", 			NAME = "Pulse ammo", 				QT = 120, 	PRICE = 150, MODEL = "models/Items/combine_rifle_cartridge01.mdl"}
AMMOS[6] = 	{AMMO = "AR2AltFire", 	NAME = "Combine Ball",	SMULT = 2, 	QT = 1, 	PRICE = 400, MODEL = "models/Items/combine_rifle_ammo01.mdl"}

AMMOS[3] = 	{AMMO = "SMG1",			NAME = "SMG ammo", 					QT = 90, 	PRICE = 150, MODEL = "models/Items/BoxMRounds.mdl"}
AMMOS[9] = 	{AMMO = "SMG1_Grenade", NAME = "SMG Grenade", 	SMULT =	3,	QT = 1, 	PRICE = 250, MODEL = "models/Items/AR2_Grenade.mdl"}

AMMOS[4] = 	{AMMO = "BuckShot", 	NAME = "Buckshot", 					QT = 32,	PRICE = 200, MODEL = "models/Items/BoxBuckshot.mdl"}
AMMOS[11] = {AMMO = "BuckShot", 	NAME = "Heavy Buckshot", 			QT = 32, 	PRICE = 200, MODEL = "models/Items/BoxFlares.mdl"}

AMMOS[5] = 	{AMMO = "357", 			NAME = ".357 ammo", 				QT = 18, 	PRICE = 200, MODEL = "models/Items/357ammo.mdl"}
AMMOS[2] = 	{AMMO = "Pistol", 		NAME = "Pistol ammo", 				QT = 72, 	PRICE = 100, MODEL = "models/Items/BoxSRounds.mdl"}

AMMOS[7] = 	{AMMO = "xbowbolt", 	NAME = "Crossbow Bolt", SMULT = 2, 	QT = 10, 	PRICE = 500, MODEL = "models/Items/CrossbowRounds.mdl"}
AMMOS[8] = 	{AMMO = "grenade", 		NAME = "Grenade", 		SMULT = 2, 	QT = 1, 	PRICE = 300, MODEL = "models/Items/grenadeAmmo.mdl"}
AMMOS[12] = {AMMO = "SMG1", 		NAME = "Mine", 			SMULT = 2, 	QT = 1, 	PRICE = 300, MODEL = "models/props_combine/combine_mine01.mdl"}
AMMOS[10] = {AMMO = "AR2", 			NAME = "Fuel",						QT = 100, 	PRICE = 350, MODEL = "models/props_junk/gascan001a.mdl"}
AMMOS[13] = {AMMO = "xbowbolt", 	NAME = "Railgun Bolt", 	SMULT = 2, 	QT = 2, 	PRICE = 350, MODEL = "models/Items/CrossbowRounds.mdl"}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NPC_TARGETS = {}
NPC_TARGETS["sent_prop"] = true
NPC_TARGETS["flameturret"] = true
NPC_TARGETS["sent_turretcontroller"] = true
NPC_TARGETS["sent_ammodispenser"] = true
NPC_TARGETS["sent_dispenser"] = true
NPC_TARGETS["sent_ladder"] = true
NPC_TARGETS["sent_spawpoint"] = true

NPCS = {}
NPCS["npc_combine_s"] = {}
NPCS["npc_combine_s"][1] =		{ENTITY = "snpc_combine_s",		FLAGS = 262144+131072+512+1024+8192+16384, 	MONEY = 120,	MODEL = "models/combine_soldier.mdl",				KEYS = "additionalequipment weapon_smg1"}
NPCS["npc_combine_s"][2] =		{ENTITY = "snpc_combine_s",		FLAGS = 262144+131072+512+1024+8192+16384, 	MONEY = 140,	MODEL = "models/combine_super_soldier.mdl",			KEYS = "additionalequipment weapon_ar2"}
NPCS["npc_combine_s"][3] =		{ENTITY = "snpc_combine_s",		FLAGS = 262144+131072+512+1024+8192+16384, 	MONEY = 120,	MODEL = "models/combine_soldier_prisonguard.mdl",	KEYS = "additionalequipment weapon_shotgun"}
NPCS["npc_metropolice"]  =		{ENTITY = "snpc_police",		FLAGS = 33554432+512+1024+8192+16384,		MONEY = 50,		MODEL = "models/police.mdl",						KEYS = "additionalequipment weapon_pistol"}
--NPCS["npc_hunter"]	=			{ENTITY = "snpc_combine_s",		FLAGS = 256+512+1024+8192,	 				MONEY = 500,	MODEL = "models/hunter.mdl"}
NPCS["npc_manhack"]  =			{								FLAGS = 256+512+1024+8192+262144, 			MONEY = 50,		MODEL = "models/manhack.mdl"}
NPCS["npc_zombie"]	=			{ENTITY = "snpc_zombie",		FLAGS = 1796,	 							MONEY = 75,		MODEL = "models/zombie/classic.mdl"}
NPCS["npc_fastzombie"]	=		{ENTITY = "snpc_zombie_fast",	FLAGS = 1796,	 							MONEY = 100,	MODEL = "models/zombie/fast.mdl"}
--NPCS["npc_zombine"]  =			{ENTITY = "snpc_zombie_fast",	FLAGS = 1796,	 							MONEY = 100,	MODEL = "models/zombie/zombie_soldier.mdl"}
NPCS["npc_antlion"] =			{								FLAGS = 256+512+1024+8192,	 				MONEY = 50,		MODEL = "models/antlion.mdl",						KEYS = "radius 512"}
NPCS["npc_headcrab"] =			{								FLAGS = 1796,	 							MONEY = 33,		MODEL = "models/headcrabclassic.mdl"}
NPCS["npc_headcrab_fast"] = 	{								FLAGS = 1796,	 							MONEY = 40,		MODEL = "models/headcrab.mdl"}
NPCS["npc_antlionguard"] =		{								FLAGS = 4+256+512+1024+8192,	 			MONEY = 700,	MODEL = "models/antlion_guard.mdl"}
NPCS["npc_rollermine"] =		{								FLAGS = 4+256+512+1024+8192,	 			MONEY = 175,	MODEL = "models/roller.mdl",						KEYS = "uniformsightdist 1"}
NPCS["npc_poisonzombie"] =		{ENTITY = "snpc_zombie_poison",	FLAGS = 4+256+512+1024+8192,	 			MONEY = 125,	MODEL = "models/zombie/poison.mdl", 				KEYS = "crabcount 3"}
NPCS["npc_headcrab_black"] =	{								FLAGS = 4+256+512+1024+8192,	 			MONEY = 120,	MODEL = "models/headcrabblack.mdl"}
NPCS["npc_zombie_torso"] =		{								FLAGS = 1796,	 							MONEY = 50,		MODEL = "models/zombie/classic.mdl"}
NPCS["npc_fastzombie_torso"] =	{								FLAGS = 1796,	 							MONEY = 75,		MODEL = "models/zombie/fast.mdl"}

npcs = {
	npc_combine_s = "Combine Soldier",
	npc_hunter = "Hunter",
	npc_antlion = "Antlion",
	npc_manhack = "Manhack",
	npc_zombie = "Zombie",
	npc_zombie_torso = "Zombie",
	npc_zombine = "Zombine",
	npc_fastzombie = "Fast Zombie",
	npc_fastzombie_torso = "Fast Zombie",
	npc_headcrab = "Headcrab",
	npc_headcrab_fast = "Fast Headcrab",
	npc_headcrab_black = "Poison Headcrab",
	npc_metropolice = "Metro Police",
	npc_rollermine = "Rollermine",
	npc_poisonzombie = "Poison Zombie",
	npc_antlionguard = "Antlion Guard"
}

Zombies = {"npc_zombine", "npc_zombie", "npc_fastzombie", "npc_antlion", "npc_antlionguard", "npc_poisonzombie"}

TIPS = {"Press reload with your physgun to delete the prop you are looking at.",
		"To earn money to spawn props, kills NPCs in the battle phase.",
		"As an engineer, you can only make dispensers on vertical walls.",
		"Remember, all props are destructable in Onslaught Evolved so one layer will not do!",
		"Type !give <partial player name> <amount to give> to give a player money",
		"As an engineer, your wrench tool - slot 2 - is a vital repairing and killing tool.",
		"Dieing less in battle round keeps your \'live bonus\' high!",
		"As a scout, keep moving to avoid enemy fire.",
		"To hide this bar, type \"ose_hidetips 1\" in the console!",
		"As an engineer, your building spawning weapons are on slot 3",
		"Want to make your base neater? Right click whilst holding a prop with your Physgun to make it nocollide.",
		"As a soldier, you have 200 health and 50 armor (which regenerates), so don't be afraid to get out on the front line.",
		"Say !spawn to set a custom spawnpoint where you are standing",
		"say !resetspawn to reset your custom spawnpoint",
		"say !voteskip to vote to skip the build phase"
		}
TIP_DELAY = 30

team.SetUp( 1, "Dead", Color( 70, 70, 70, 255 ) )

RANKS = {}
RANKS[1] = {NAME = "Scientist",					KILLS = 0, 		COLOR = Color(255, 	255, 	255, 	255)}
RANKS[2] = {NAME = "Citizen", 					KILLS = 50, 	COLOR = Color(0, 	100, 	220, 	255)}
RANKS[3] = {NAME = "Metrocop", 					KILLS = 200, 	COLOR = Color(80, 	150, 	80,  	255)}
RANKS[4] = {NAME = "Rebel", 					KILLS = 500, 	COLOR = Color(120,	120,	120, 	255)}
RANKS[5] = {NAME = "Combine Soldier", 			KILLS = 1000, 	COLOR = Color(100, 	70, 	70,  	255)} //yes, all of these are combine. the rebels were retarded in HL2.
RANKS[6] = {NAME = "Combine Shotgunner", 		KILLS = 2500, 	COLOR = Color(100,	29,		0,  	255)}
RANKS[7] = {NAME = "Combine Prison Guard", 		KILLS = 5000, 	COLOR = Color(20, 	80, 	20,  	255)}
RANKS[8] = {NAME = "Combine Super Soldier", 	KILLS = 10000, 	COLOR = Color(150, 	0, 		0,		255)}
RANKS[10] = {NAME = "Hunter Chopper Gunner", 	KILLS = 25000, 	COLOR = Color(0, 	20, 	80, 	255)}
RANKS[11] = {NAME = "Advisor",					KILLS = 50000, 	COLOR = Color(150,	150,	180, 	255)}
RANKS[12] = {NAME = "Eli's Librarian",			KILLS = 75000,	COLOR = Color(150,	200,	150, 	255)} //movie reference (eli's book)
RANKS[12] = {NAME = "A Free Man", 				KILLS = 100000, COLOR = Color(225, 	125, 	125, 	255)}

for k,v in pairs(RANKS) do
	team.SetUp( k + 1, v.NAME, v.COLOR )  -- yay for awesome ranks
end


	for k,v in pairs(CLASSES) do
		util.PrecacheModel(v.MODEL)
	end

	for k,v in pairs(NPCS) do
		if v[1] then
			for _,x in ipairs(v) do
				if type(x)=="table" and x.MODEL then
					util.PrecacheModel(x.MODEL)
				end
			end
		else
			util.PrecacheModel(v.MODEL)
		end
	end


function InRange(number, min, max) --Basically math.Clamp without the Clamp.
	return min<=number and number<=max
end
