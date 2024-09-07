-- Allow the crowbar to remove cybernetics from dead bodies
-- by patching character.IsDead to temporarily return false during the resolution of the 'apply crowbar' in the Health UI
local allowedNecromancyItems = {
	crowbar = 1,
	screwdriver = 1,
	weldingtool = 1,
	steel = 1,
	fpgacircuit = 1,
	-- tools needed for cyberorgan removal
	advscalpel = 1,
	advhemostat = 1,
	advretractors = 1,
	organscalpel_kidneys = 1,
	organscalpel_liver = 1,
	organscalpel_lungs = 1,
	organscalpel_heart = 1,
	organscalpel_brain = 1,
	multiscalpel = 1,
}
local temporarilyUndeadCharacter = nil
local function patchIsDead()
	-- this patch is performance intensive, so we only apply it while the specific necromancy is needed
	Hook.Patch("NTC.IsDead_Patch", "Barotrauma.Character", "get_IsDead", function (instance, ptable)
		if temporarilyUndeadCharacter ~= nil and temporarilyUndeadCharacter == instance then
			ptable.PreventExecution = true
			return false
		end
	end, Hook.HookMethodType.Before)
end

Hook.Patch("Barotrauma.CharacterHealth", "OnItemDropped", function (instance, ptable)
	if instance.Character.IsDead and allowedNecromancyItems[ptable["item"].Prefab.Identifier.Value] ~= nil then
		temporarilyUndeadCharacter = instance.Character
		patchIsDead()
	end
end, Hook.HookMethodType.Before)
Hook.Patch("Barotrauma.CharacterHealth", "OnItemDropped", function (instance, ptable)
	if temporarilyUndeadCharacter ~= nil then
		temporarilyUndeadCharacter = nil
		Hook.RemovePatch("NTC.IsDead_Patch", "Barotrauma.Character", "get_IsDead", Hook.HookMethodType.Before)
	end
end, Hook.HookMethodType.After)
