ENT.Base = "base_entity"
ENT.Type = "brush"
ENT.npcs = {}
function ENT:KeyValue(key,val)
	if key == "npcfilter" then
		self.npcs = string.Explode(" ", val)
		if self.npcs[1] == nil then
			Error("WARNING!: trigger_forcelose keyvalues set up incorrectly!\n See a mapper!\n")
		end
	end
end

function ENT:Initialize()
end

function ENT:Touch(ent)
end

function ENT:StartTouch(ent)
	if table.HasValue(self.npcs, ent:GetClass()) then
		print("[Force Lose] NPC has entered a force lose brush!")
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("You failed to keep the objective free of npcs!")
		end
		GAMEMODE:StartBuild()
	end
end

function ENT:EndTouch(ent)
end

function ENT:Think()

end
