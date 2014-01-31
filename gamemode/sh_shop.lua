--Matt (shared file)

defEItems = {}		//mel 	//sec 	//prim 	//spc
	defEItems.sct={{13,1},	{2,1},	{8,1}}
	defEItems.sld={{13,1},	{2,1},	{1,1},	{3,1}}
	defEItems.eng={{7,1},	{2,1},	{11,1},	{4,1}}
	defEItems.snp={{13,1},	{5,1},	{6,1}}
	defEItems.pyr={{13,1},	{2,1},	{12,1},	{3,1}}
	defEItems.sup={{13,1},	{9,1},	{10,1}}

defItems = {{1,1},{2,1},{3,1},{4,1},{5,1},{6,1},{7,1},{8,1},{9,1},{10,1},{11,1},{12,1},{13,1}}

defSClass = {} //sub classes
defSClass.sct = 1 //for example, hotshot: shoots faster
defSClass.sld = 1 //juggernaut: lots of health, no armor, also gunner: shoots faster etc
defSClass.eng = 1 //nothing i can really make up for him
defSClass.snp = 1 //
defSClass.pyr = 1 //
defSClass.sup = 1 //
// each subclass needs downsides

local baseWeapon = {NAME = "Base Weapon",WC="none",SLOT=1,VALUE=0,AD={},MODEL="models/weapons/w_crowbar.mdl",DESC="If you're seeing this, tell Matt.",CLASS=1,LOOKAT=Vector(0,0,0),OFFSET=Vector(0,0,0),HOOKS = {},INDEX=0}
NEW_WEAPONS = {}

function CreateItem(index,tab)
	if not (tab.NAME or tab.DESC or tab.SLOT or tab.MODEL or tab.WC) then return end
	NEW_WEAPONS[tab.INDEX] = table.Merge(table.Copy(baseWeapon),tab)
	print("Inserted item "..index.." at position "..table.maxn(NEW_WEAPONS))
end

local Pmeta = FindMetaTable("Player")
function Pmeta:IsEquipped(id,p,opt)
	local class = opt or self:GetNWInt("class")
	for k,v in pairs(self.EItems[convCTable[class]]) do
		if v[1] == id and v[2] == p then return true end
	end
	return false
end

function Pmeta:HasItem(id,p)
	for k,v in pairs(self.Items) do
		if v[1] == id and v[2] == p then return true end
	end
	return false
end

for k,v in pairs(file.Find(GM.Folder:sub(11).."/gamemode/items/*.lua","LUA")) do
	if SERVER then
		AddCSLuaFile("items/"..v)
	end
	include("items/"..v)
end
