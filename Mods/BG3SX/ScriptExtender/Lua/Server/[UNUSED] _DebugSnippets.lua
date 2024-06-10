
----------------------------------------------------------------------------------------------------
-- Loop through a table of sound resources (TestSounds), playing a new sound each time, with console output.
----------------------------------------------------------------------------------------------------

local TestSounds = {
    "Player_Races_Voice_Combat_Attack"
}
local TestSoundIndex = 1

function PlayTestSound(actor)
    -- _P("[_DebugSnippets.lua] TEST SOUND " .. TestSoundIndex .. "/" .. #TestSounds .. ": " .. TestSounds[TestSoundIndex])
    Osi.PlaySound(actor, TestSounds[TestSoundIndex])
    TestSoundIndex = TestSoundIndex + 1
    if TestSoundIndex > #TestSounds then
        TestSoundIndex = 1
    end
end
