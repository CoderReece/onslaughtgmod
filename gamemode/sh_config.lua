GM.Config = {}
--VARIABLES---
	--Core Gamemode Vars--
	GM.Config.BUILDTIME = 600
	GM.Config.BATTLETIME = 720	--
	GM.Config.MINBATTLETIME = 600 -- If everyone loses a lot this is the minimum time battle needs to be.
	GM.Config.ADD_SPAWN_TIME = 5 -- Every player that is in the server multiplied by this number will be added to SPAWN_TIME
	GM.Config.SPAWN_TIME = 10 -- this is the base spawn time. The game adds X seconds to the spawn time for every player present on the server. You can change how many seconds it adds for each player above
	//GM.Config.ANTILAG = false --turn on with caution! //this apparently isn't anywhere in the code.
	//GM.Config.BUILD_NOCLIP = true -- whether or not noclip should be allowed in build //this also isn't in the code.
	GM.Config.VOTE_TIME = 30 -- how long players have to vote for a map.
	GM.Config.VOTE_ENABLE_TIME = 660 -- how long the current map has to go on for until map voting is allowed -- once a vote has passed it redisables it then reenables it again after this time.
	GM.Config.PROP_DELETE_TIME = 180 -- how long a player has to leave for until his money and props are deleted.
	GM.Config.FLAMABLE_PROPS = false
	GM.Config.PROP_CLEANUP = false --props cleaned up after a round ends
	GM.Config.PROP_LIMIT = 35
	GM.Config.STARTING_MONEY = 20000
	GM.Config.LIVE_BONUS = 5000 --if you live a round, you get this much money
	GM.Config.DEATH_PENALTY = -2500 --if you die a round, this much is subtracted from your living bonus
	GM.Config.PING_LIMIT = 300 -- This is NOT a ping kicker this is where if the gamemode feels that everyone is getting a bit laggy then start lowering the max npcs available :)
	GM.Config.MAXHUNTERS = 0 -- MAXHUNTERS + Number of Players/4
	GM.Config.MAXHACKS = 10
	GM.Config.SPAWN_DELAY = .5 --NPC spawn delay (they spawn in waves, so 4 or 5 will spawn at once)
	GM.Config.S_MAX_NPCS = 60
	GM.Config.MAX_NPCS = 25 -- S is for singleplayer normal is multiplayer
	GM.Config.DISP_RATE = 100 -- lower is faster
	GM.Config.TURRET_HEALTH = 100
	GM.Config.ADVANCED_DAMAGE = true -- ONLY TURN THIS ON IF YOU ARE NOT EXPERIENCING ANY LAG. //this shouldn't be laggy at all.
 
--MODELS. these appear in the spawnmenu.

	MODELGROUPS = {}/*
	MODELGROUPS[1] = "Walls"
	MODELGROUPS[2] = "Boxes"
	MODELGROUPS[3] = "Beams"
	MODELGROUPS[4] = "Other"
	MODELGROUPS[5] = "Junk"*/
	MODELGROUPS[1] = "Strong"
	MODELGROUPS[2] = "Medium"
	MODELGROUPS[3] = "Weak"
	MODELGROUPS[6] = "Special"

	MODELS =   {}
	MODELS["models/props_c17/display_cooler01a.mdl"] = {ANG = Angle(0,-90,0), GROUP = 4, NAME = "Rack"}
	MODELS["models/props_c17/furniturestove001a.mdl"] = {GROUP = 2, NAME = "Stove",HEIGHT=1}
	MODELS["models/props_combine/breendesk.mdl"] = {GROUP = 2, NAME = "Desk"}
	MODELS["models/props_lab/blastdoor001c.mdl"] = {GROUP = 1, NAME = "Blast Door"}
	MODELS["models/props_lab/blastdoor001b.mdl"] = {GROUP = 1, NAME = "Blast Door"}
	MODELS["models/props_junk/wood_crate001a.mdl"] = {GROUP = 2, NAME = "Crate"}
	MODELS["models/props_junk/wood_crate002a.mdl"] = {GROUP = 2, NAME = "Crate"}
	MODELS["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {GROUP = 5}
	MODELS["models/props_wasteland/wood_fence01a.mdl"] = {ANG = Angle(0,90,0), GROUP = 1, NAME = "Fence",HEIGHT=1}
	MODELS["models/props_wasteland/wood_fence02a.mdl"] = {ANG = Angle(0,90,0), GROUP = 1, NAME = "Fence",HEIGHT=1}
	MODELS["models/props_wasteland/kitchen_counter001b.mdl"] = {GROUP = 2, NAME = "Table"}
	MODELS["models/props_interiors/vendingmachinesoda01a_door.mdl"] = {GROUP = 1, NAME = "Vending Machine Door",HEIGHT=1}
	MODELS["models/props_interiors/vendingmachinesoda01a.mdl"] = {GROUP = 2, NAME = "Vending Machine",HEIGHT=1}
	MODELS["models/props_pipes/concrete_pipe001a.mdl"] = {GROUP = 4, NAME = "Pipe",HEIGHT=1}
	MODELS["models/props_c17/door01_left.mdl"] = {GROUP = 5, NAME = "Door",HEIGHT=1}
	MODELS["models/props_c17/shelfunit01a.mdl"] = {ANG = Angle(0,-90,0),GROUP = 1, NAME = "Shelf"}
	MODELS["models/props_interiors/furniture_couch02a.mdl"] = {GROUP = 5, NAME = "Couch",HEIGHT=1}
	MODELS["models/props_wasteland/kitchen_fridge001a.mdl"] = {GROUP = 2, NAME = "Fridge"}
	MODELS["models/props_wasteland/kitchen_stove002a.mdl"] = {GROUP = 2, NAME = "Large Stove"}
	MODELS["models/props_combine/combine_barricade_short01a.mdl"] = {ANG = Angle(0,180,0),GROUP = 4, NAME = "Combine Barricade",HEIGHT=1}
	MODELS["models/props_junk/trashdumpster02b.mdl"] = {GROUP = 4, NAME = "Dumpster"}
	MODELS["models/props_c17/oildrum001.mdl"] = {GROUP = 5, NAME = "Oil Drum"}
	MODELS["models/props_c17/gravestone_coffinpiece002a.mdl"] = {GROUP = 3, NAME = "Gravestone"}
	MODELS["models/props_junk/pushcart01a.mdl"] = {GROUP = 5, NAME = "Cart",HEIGHT=1}
	MODELS["models/props_c17/furniturecouch001a.mdl"] = {GROUP = 5, NAME = "Couch",HEIGHT=1}
	MODELS["models/props_wasteland/laundry_cart001.mdl"] = {GROUP = 5, NAME = "Cart",HEIGHT=1}
	MODELS["models/props_trainstation/traincar_rack001.mdl"] = {GROUP = 3, NAME = "Rack"}
	MODELS["models/props_wasteland/laundry_basket001.mdl"] = {GROUP = 5, NAME = "Basket",HEIGHT=1}
	MODELS["models/props_wasteland/prison_celldoor001a.mdl"] = {GROUP = 1, NAME = "Cell Door"}
	MODELS["models/props_wasteland/prison_bedframe001b.mdl"] = {GROUP = 5, NAME = "Bedframe"}
	MODELS["models/props_junk/ibeam01a.mdl"] = {ANG = Angle(0,-90,0),GROUP = 3, NAME = "I-Beam"}
	MODELS["models/props_debris/metal_panel01a.mdl"] = {GROUP = 1, NAME = "Sheet Metal",HEIGHT=1}
	MODELS["models/props_debris/metal_panel02a.mdl"] = {GROUP = 1, NAME = "Sheet Metal",HEIGHT=1}
	MODELS["models/props_c17/concrete_barrier001a.mdl"] = {GROUP = 4, NAME = "Barricade"}
	MODELS["models/props_c17/furniturefridge001a.mdl"] = {GROUP = 2, NAME = "Fridge"}

	MODELS["models/props_c17/metalladder002.mdl"] = {GROUP = 6, COST = 800, CLASS = "sent_ladder", NAME = "Ladder", LIMIT = 3}

	MODELS["models/items/ammocrate_smg1.mdl"] = {GROUP = 6, CLASS = "sent_ammo_dispenser", NAME = "Ammo Crate", LIMIT = 1,HEIGHT=1}

	MODELS["models/combine_turrets/floor_turret.mdl"] = {ANG = Angle(0,180,0),GROUP = 6, PLYCLASS = 3, CLASS = "npc_turret_floor", NAME = "Turret", LIMIT = 2, COST = 700, EXTBUILD = nil, ALLOWBATTLE = true, RANGE = 200}

	MODELS["models/props_combine/combine_mine01.mdl"] = {GROUP = 6, PLYCLASS = 3, CLASS = "ose_mines", NAME = "Mine", LIMIT = 10, COST = 300, EXTBUILD = nil, ALLOWBATTLE = true, RANGE = 150}

	MODELS["models/props_combine/health_charger001.mdl"] = {GROUP = 6, CLASS = "sent_dispenser", NAME = "Dispenser", LIMIT = 1, COST = 600, EXTBUILD = nil, DONTSPAWN = true, RANGE = 200}

	--MODELS["models/Combine_turrets/Ceiling_turret.mdl"] = {SPAWNFLAGS = "32", ANG = Angle(0,180,0),GROUP = 6, PLYCLASS = 3, CLASS = "npc_turret_ceiling", NAME = "Turret", LIMIT = 2, COST = TURRET_COST, EXTBUILD = nil, ALLOWBATTLE = true, RANGE = 200}
	for k,v in pairs(MODELS) do
		util.PrecacheModel(k)
	end

MASS={
["models/props_pipes/concrete_pipe001a.mdl"] = 5000,
["models/props_c17/furniturestove001a.mdl"] = 1500,
["models/props_combine/breendesk.mdl"] = 1000,
["models/items/ammocrate_smg1.mdl"] = 600,
["models/props_interiors/vendingmachinesoda01a.mdl"] = 600,
["models/props_trainstation/traincar_rack001.mdl"] = 500,
["models/props_junk/ibeam01a.mdl"] = 499.99996948242,
["models/props_wasteland/prison_celldoor001a.mdl"] = 300,
["models/props_c17/furniturecouch001a.mdl"] = 300,
["models/props_c17/furniturefridge001a.mdl"] = 250,
["models/props_wasteland/kitchen_fridge001a.mdl"] = 203.76559448242,
["models/props_interiors/vendingmachinesoda01a_door.mdl"] = 200,
["models/props_wasteland/kitchen_counter001b.mdl"] = 199.99998474121,
["models/props_interiors/furniture_couch02a.mdl"] = 180,
["models/props_lab/blastdoor001c.mdl"] = 177.02734375,
["models/props_debris/metal_panel01a.mdl"] = 150,
["models/props_c17/display_cooler01a.mdl"] = 131.58682250977,
["models/combine_turrets/floor_turret.mdl"] = 100.00000762939,
["models/props_junk/pushcart01a.mdl"] = 100,
["models/props_lab/blastdoor001b.mdl"] = 92.261032104492,
["models/props_c17/shelfunit01a.mdl"] = 550,
["models/props_wasteland/kitchen_stove002a.mdl"] = 85,
["models/props_wasteland/laundry_basket001.mdl"] = 85,
["models/props_c17/concrete_barrier001a.mdl"] = 75,
["models/props_combine/combine_barricade_short01a.mdl"] = 60.000003814697,
["models/props_wasteland/controlroom_filecabinet002a.mdl"] = 60,
["models/props_junk/wood_crate002a.mdl"] = 59.999996185303,
["models/props_wasteland/laundry_cart001.mdl"] = 50,
["models/props_junk/trashdumpster02b.mdl"] = 50,
["models/props_c17/door01_left.mdl"] = 50,
["models/props_c17/metalladder002.mdl"] = 50,
["models/props_debris/metal_panel02a.mdl"] = 37.627296447754,
["models/props_wasteland/prison_bedframe001b.mdl"] = 35,
["models/props_c17/gravestone_coffinpiece002a.mdl"] = 30.000001907349,
["models/props_c17/oildrum001.mdl"] = 30,
["models/props_junk/wood_crate001a.mdl"] = 30,
["models/props_combine/health_charger001.mdl"] = 30,
["models/props_wasteland/wood_fence02a.mdl"] = 30,
["models/props_combine/combine_mine01.mdl"] = 10,
["models/props_wasteland/wood_fence01a.mdl"] = 10,
}