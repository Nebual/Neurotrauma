-- Allow the crowbar to remove cybernetics from dead bodies
-- by patching character.IsDead to temporarily return false during the resolution of the 'apply crowbar' in the Health UI
local allowedNecromancyItems = {
	crowbar = 1,
	screwdriver = 1,
	weldingtool = 1,
	steel = 1,
	fpgacircuit = 1,
}
local temporarilyUndeadCharacter = nil
Hook.Patch("Barotrauma.CharacterHealth", "OnItemDropped", function (instance, ptable)
	if instance.Character.IsDead and allowedNecromancyItems[ptable["item"].Prefab.Identifier.Value] ~= nil then
		temporarilyUndeadCharacter = instance.Character
	end
end, Hook.HookMethodType.Before)

Hook.Patch("Barotrauma.Character", "get_IsDead", function (instance, ptable)
	if temporarilyUndeadCharacter ~= nil and temporarilyUndeadCharacter == instance then
		ptable.PreventExecution = true
		return false
	end
end, Hook.HookMethodType.Before)

Hook.Patch("Barotrauma.CharacterHealth", "OnItemDropped", function (instance, ptable)
	if temporarilyUndeadCharacter ~= nil then
		temporarilyUndeadCharacter = nil
	end
end, Hook.HookMethodType.After)
