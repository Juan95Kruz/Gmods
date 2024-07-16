
CLASSES = {}

local class = {}

function class.Add(classtable)
	table.ForceInsert(CLASSES, classtable)
end

function class.Get(classname)
	for k,v in pairs(CLASSES) do
		if v["class"] == classname then
			return v
		end
	end
end

/*
class.Add({
	name = "Example",
	class = "class_example",
	customcheck = function(ply)
		return ply:IsUserGroup( "vip" ) // this class is only for vips
	end,
	customcheckfailmsg = "You must be VIP to use this class",
	classesneeded = {
		{
			class = "class_sniper", // To use this class, you need to have 10 level on sniper
			level = 10
		},
		{
			class = "class_commando", // And you need to have 5 level on commando
			level = 5
		}
	}
})
*/

class.Add({
	name = "Default", -- visible name
	class = "class_default", -- code name
	classesneeded = {}, -- don't touch this unless you want it to be locked behind something, I leave it out for fun reasons
	premium = false -- DO NOT TOUCH THIS
})

class.Add({
	name = "Sprinter",
	class = "class_sprinter",
	classesneeded = {},
	premium = false
})

class.Add({
	name = "Mercenary",
	class = "class_mercenary",
	classesneeded = {},
	premium = false
})

class.Add({
	name = "Scout",
	class = "class_scout",
	classesneeded = {},
	premium = false
})

class.Add({
	name = "Commander",
	class = "class_commander",
	classesneeded = {},
	premium = false
})

class.Add({
	name = "Medic",
	class = "class_medic",
	classesneeded = {},
	premium = false

})
	class.Add({
	name = "Spy",
	class = "class_spy",
	classesneeded = {},
	premium = false
})
	class.Add({
	name = "Trapper",
	class = "class_trapper",
	classesneeded = {},
	premium = false
})
		class.Add({
	name = "Mortarman",
	class = "class_mortarman",
	classesneeded = {},
	premium = false
})
		class.Add({
	name = "Security",
	class = "class_security",
	classesneeded = {},
	premium = false
})