AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Npc = "npc_manhack"
ENT.pathname = "path"
ENT.Delay = GAMEMODE.Config.SPAWN_DELAY
ENT.Flags = 0
ENT.namecpy = "NuLL"
ENT.sptime = nil
ENT.cpykeys = nil

function ENT:KeyValue( key, value )
	if key == "copykeys" then
		self.cpykeys = string.Explode(" ", value)
		if self.cpykeys[1] == nil then
			Error("WARNING!: sent_spawonce keyvalues set up incorrectly!\n See a mapper!\n")
		end
	end
	if key == "npc" then
		self.Npc = value
	end
	if key == "path" then
		self.pathname = value
	end
	if key == "spawndelay" then
		self.Delay = value
	end
	if key == "spawnflags" then
		self.Flags = value
	end
	if key == "namecpy" then
		self.namecpy = value
	end
	if key == "sptime" then
		self.sptime = tonumber(value)
	end
end

function ENT:Initialize( )
	self.Entity:SetModel( "models/props_junk/wood_crate002a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )

	self:SetNotSolid( true )
	self:SetNoDraw( true )
	self:DrawShadow( false )

	local phys = self.Entity:GetPhysicsObject( )
	if phys:IsValid( ) then
		phys:Wake( )
		phys:EnableMotion( false )
		phys:EnableCollisions( false )
	end
end

function ENT:Think( )
	if PHASE == "BATTLE" then

		if #player.GetAll( ) == 0 then return end

		if #ents.FindByName(self.namecpy) >= 1 then
			self.Entity:NextThink( CurTime( ) + self.Delay )
			return true
		end
		if self.sptime != nil then
			if TimeLeft > self.sptime then
				self.Entity:NextThink( CurTime( ) + self.Delay )
				return true
			end
		end


		local ent = ents.Create( self.Npc )
		ent:SetPos( self.Entity:GetPos( ) )
		ent:SetAngles( self.Entity:GetAngles( ) )

		ent:SetKeyValue("spawnflags", self.Flags)
		ent:SetName(self.namecpy)

		if self.cpykeys != nil then
			for k,v in pairs(self.cpykeys) do
				if (k / 2) != math.Round(k / 2) then
				ent:SetKeyValue(v, self.cpykeys[k + 1])
				end
			end
		end

		ent:SetKeyValue("target",self.pathname)

		local ED = EffectData( )
		ED:SetEntity( ent )
		util.Effect( "npc_spawn", ED )

		for k,v in pairs(player.GetAll()) do
			ent:AddEntityRelationship(v, 1, 999 )
		end

		for k,v in pairs(NPCS) do
			ent:Fire( "setrelationship", k .. " D_LI 99" ) -- make the npcs like eachother
		end

		ent:Fire( "setrelationship", "npc_bullseye D_HT 1" )
		ent:Spawn( )
		ent:Activate( )

	end
	self.Entity:NextThink( CurTime( ) + self.Delay )
	return true
end
