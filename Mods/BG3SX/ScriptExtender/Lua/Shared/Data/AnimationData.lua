-- TODO: Clean these up - Maybe have the tables first in general, then afterwards create a section with the additional heightmatching entries

-- Heightmatching.lua needs to be loaded before AnimationData.lua to allow the functions to already exist.
Ext.Require("Shared/Data/Heightmatching.lua")
local hm = Data.Heightmatching

-- Seperated from Data.Animations because these 2 are the start spells which are handled differently and will create a scene
Data.StartSexSpells = {
    ["BG3SX_StartMasturbating"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true, -- Fade and Sound currently don't do anything and could technically be left out when creating new entries
        SoundTop = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_StartMasturbating", "49497bdc-d901-4f60-9e4e-3d31a06f9002", "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b"),
    },
    ["BG3SX_AskForSex"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = false,
        SoundTop = Data.Sounds.Silence, SoundBottom = Data.Sounds.Silence,
        Heightmatching = hm:new("BG3SX_AskForSex", "49d78660-5175-4ed2-9853-840bb58cf34a", "10fee5b7-d674-436c-994c-616e01efcb90"),
    },
}

-- Additional entries need to be done seperately, we only create the instance per animation - We can't do this in the table belonging to the animation itself
local hmi = hm:getInstanceByAnimName("BG3SX_StartMasturbating")
if hmi then -- Solo animation only needs to specify one bodytype/gender and one animation UUID
    hmi:setAnimation("M",  nil, "49497bdc-d901-4f60-9e4e-3d31a06f9002")
    hmi:setAnimation("F",  nil, "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b")
    hmi:setAnimation("TallF",  nil, "2c60a233-b669-4b94-81dc-280e98238fd0") -- TallF specific animation - Tall is what we call the "Strong" bodytype identifier
end
local hmi = hm:getInstanceByAnimName("BG3SX_AskForSex")
if hmi then -- Instead of a specific bodytype/gender combo, just the bodytype matchup also works
    hmi:setAnimation("Tall", "Med", "04922882-0a2d-4945-8790-cef50276373d", "392073ca-c6e0-4f7d-848b-ffb0b510500b")
    -- hmi:setAnimation("Med", "Tall", "392073ca-c6e0-4f7d-848b-ffb0b510500b", "04922882-0a2d-4945-8790-cef50276373d")
    -- If we'd reverse the entry with the commented out line, the same animation would play even if we use SwitchPlaces
    -- Like this, if we initiate with Tall + Med, the carrying animation plays, if we use SwitchPlaces, the regular fallback plays
end

-- Additional Explanation
----------------------------------
-- The way animations get chosen is based on this priority
-- BodyShape+BodyType > BodyType > BodyShape
-- TallM > M > Tall
-- Meaning if it finds a match based on a combination of Shape and Type it uses this, otherwise it checks for Type matchups, then Shape matchups

-- While creating matches, only use one of these matchups with the same type
-- Only use Tall + Tall or Tall + Med matchups but never Tall + M or M + TallF
-- If you want to match TallM against any F do it like this:
-- TallM + TallF
-- TallM + MedF
-- etc.

Data.Animations = {
    ["BG3SX_Grinding"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_Grinding", "0114c60d-0f82-4827-ae11-9e3c46f7d7b5", "8b9b1bb2-842b-422c-90ff-efbbe84835aa"),
    },
    ["BG3SX_EatPussy"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Kissing, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_EatPussy", "5fa5cbe4-1baf-4529-b448-2c53e163626c", "f801ec0d-9fee-4584-bae3-96d7c3e285ff"),
    },
    ["BG3SX_FingerFuck"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Kissing, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_FingerFuck", "adf1b790-da1d-4aaf-9ac4-83157c52d5c2", "a79232a2-a498-4689-a5bd-8923e80284d2"),
    },
    ["BG3SX_Blowjob"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Kissing, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_Blowjob", "536f0403-c401-4223-bbca-6b807494a527", "b3984708-7664-49ae-b96d-0512497ea036"),
    },
    ["BG3SX_Missionary"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_Missionary", "905be226-3edc-4783-9d4e-45d2b57a3d0a", "48a255e9-02ec-4541-b1b7-32275da29206"),
    },
    ["BG3SX_Doggy"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_Doggy", "b8f04918-c5b6-4c4a-aee5-390bfaff33bc", "ffdd67e7-7363-46a4-92e2-38260ef0a2e0"),
    },
    ["BG3SX_Cowgirl"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_Cowgirl", "ff7a5a30-b661-4192-bd8f-118373e3f4b8", "1b220386-55fa-4d2b-8da4-0e7bf453d928"),
    },
    ["BG3SX_MasturbateStanding"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Kissing,
        Heightmatching = hm:new("BG3SX_MasturbateStanding", "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b"),
    },
    ["BG3SX_Milking"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Kissing,
        Heightmatching = hm:new("BG3SX_Milking", "a71ace41-41ce-4876-8f14-4f419b677533", "d2a17851-b51b-4e4f-be1d-30dc86b6466a"),
    },
    ["BG3SX_Wanking"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Kissing, SoundBottom = Data.Sounds.Kissing,
        Heightmatching = hm:new("BG3SX_Wanking", "49497bdc-d901-4f60-9e4e-3d31a06f9002"),
    },
    ["BG3SX_BottleSit"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_BottleSit", "d0f6cf4a-a418-4640-bf36-87531d55154b"),
        Props = {
        "0f2ccca6-3ce8-4271-aec0-820f6581c551", -- Bottle
        }
    },
}

local hmi = hm:getInstanceByAnimName("BG3SX_MasturbateStanding")
if hmi then
    hmi:setAnimation("TallF",  nil, "2c60a233-b669-4b94-81dc-280e98238fd0")
end


-- How to use:
-----------------------------------------------------------------------------------------------------
-- local BG3SXAnims = Mods.BG3SX.Data.Animations
-- local BG3SXSounds = Mods.BG3SX.Sounds
-- local BG3SXHM = Mods.BG3SX.Data.Heightmatching

-- BG3SXAnims["MyMod_Pegging"] = {
--     AnimLength = 3600, Loop = true, Fade = true, Sound = true, -- AnimLength currently only gets used to loop the sound, just keep it as 3600
--     SoundTop = BG3SXSounds.Kissing, SoundBottom = BG3SXSounds.Kissing,
--     Heightmatching = BG3SXHM:new("MyMod_Pegging", "YourFallbackAnimationUUID"),
-- }

-- local hmi = BG3SXHM:getInstanceByAnimName("MyMod_Pegging")
-- if hmi then
--     hmi:setAnimation("TallF",  MedM, "ASpecificOtherAnimationUUID")
-- end

-- BG3SXAnims["MyMod_FuckDonut"] = {
--     AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--     SoundTop = BG3SXSounds.Kissing, SoundBottom = BG3SXSounds.Kissing,
--     Heightmatching = BG3SXHM:new("MyMod_FuckDonut", "YourFallbackAnimationUUID"),
--     Props = {
--     "UUID Of A Donut", -- A Donut
--     }
-- }

-- local hmi = BG3SXHM:getInstanceByAnimName("MyMod_FuckDonut")
-- if hmi then
--     hmi:setAnimation("TallF",  nil, "ASpecificOtherAnimationUUID")
-- end

-- Or sort all animations like we do first, then the heightmatching instances 
-- You still need to create spells with the same name as the animations you add
-- As long as scene exist, they should work - Please report back if they don't
-- Props get spawned automatically on scene root position