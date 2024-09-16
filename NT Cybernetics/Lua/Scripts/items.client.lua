-- Allow the crowbar to remove cybernetics from dead bodies (and other repair related tools)
-- by patching character.IsDead to temporarily return false during the resolution of the 'apply tool' in the Health UI
NTCyb.AllowedNecromancyItems = {
	weldingtool = 1,
	steel = 1,
	fpgacircuit = 1,
	repairpack = 1,
	halligantool = 1,
	-- tools needed for cyberorgan removal
	advscalpel = 1,
	advhemostat = 1,
	advretractors = 1,
	multiscalpel = 1,
}
NTCyb.AllowedNecromancyItemsStartsWith = {
	crowbar = 1,
	screwdriver = 1,
	organscalpel = 1,
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
	if instance.Character.IsDead then
		local identifier = ptable["item"].Prefab.Identifier.Value
		if NTCyb.AllowedNecromancyItems[identifier] ~= nil then
			temporarilyUndeadCharacter = instance.Character
			patchIsDead()
		else
			for key,_ in pairs(NTCyb.AllowedNecromancyItemsStartsWith) do
				if HF.StartsWith(identifier,key) then
					temporarilyUndeadCharacter = instance.Character
					patchIsDead()
					break
				end
			end
		end
	end
end, Hook.HookMethodType.Before)
Hook.Patch("Barotrauma.CharacterHealth", "OnItemDropped", function (instance, ptable)
	if temporarilyUndeadCharacter ~= nil then
		temporarilyUndeadCharacter = nil
		Hook.RemovePatch("NTC.IsDead_Patch", "Barotrauma.Character", "get_IsDead", Hook.HookMethodType.Before)
	end
end, Hook.HookMethodType.After)
