-- Heightmatching.lua needs to be loaded before AnimationData.lua to allow the functions to already exist.
Ext.Require("Shared/Data/Heightmatching.lua")
local hm = Data.Heightmatching
-- TODO: Clean these up - Maybe have the tables first in general, then afterwards create a section with the additional heightmatching entries

-- Additional data thats included when using a spell equal to the entry name
-- Seperated from the other table because these 2 are the start spells which are handled differently and will create a scene
Data.StartSexSpells = {
    ["BG3SX_StartMasturbating"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
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
local instance = hm:getInstanceByAnimName("BG3SX_StartMasturbating")
if instance then -- Solo animation only needs specify one bodytype/gender and one fallback animation
    instance:setAnimation("M",  nil, "49497bdc-d901-4f60-9e4e-3d31a06f9002")
    instance:setAnimation("F",  nil, "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b")
    instance:setAnimation("TallF",  nil, "2c60a233-b669-4b94-81dc-280e98238fd0") -- TallF specific animation - Tall is the "Strong" identifier for bodytype because its more about height than beefyness
end
local instance = hm:getInstanceByAnimName("BG3SX_AskForSex")
if instance then -- Instead of a specific bodytype/gender combo, just the bodytype matchup also works
    instance:setAnimation("Tall", "Med", "04922882-0a2d-4945-8790-cef50276373d", "392073ca-c6e0-4f7d-848b-ffb0b510500b")
    instance:setAnimation("Med", "Tall", "392073ca-c6e0-4f7d-848b-ffb0b510500b", "04922882-0a2d-4945-8790-cef50276373d")
    -- The reverse entry makes it play the same animation; It would also be possible to add reverse specific animations like this
end


-- Additional data thats included when using a spell per entry key
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

-- Old Layout

-- Data.StartSexSpells = {
--     {   AnimName = "BG3SX_StartMasturbating_Old",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "49497bdc-d901-4f60-9e4e-3d31a06f9002",
--         FallbackBottomAnimationID = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
--         Med_Female = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
--         Med_Male = "49497bdc-d901-4f60-9e4e-3d31a06f9002",
--         Tall_Female = "2c60a233-b669-4b94-81dc-280e98238fd0",
--     },
--     {   AnimName = "BG3SX_AskForSex",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = false,
--         SoundTop = Data.Sounds.Silence, SoundBottom = Data.Sounds.Silence,
--         FallbackTopAnimationID = "49d78660-5175-4ed2-9853-840bb58cf34a",
--         FallbackBottomAnimationID = "10fee5b7-d674-436c-994c-616e01efcb90",
--         MedTop_MedBtm = {
--             Btm = "10fee5b7-d674-436c-994c-616e01efcb90",
--             Top = "49d78660-5175-4ed2-9853-840bb58cf34a",
--         },
--         TallTop_MedBtm = {
--             Btm = "392073ca-c6e0-4f7d-848b-ffb0b510500b",
--             Top = "04922882-0a2d-4945-8790-cef50276373d",
--         },
--     },
-- }

-- Additional data thats included when using a spell equal to AnimName
-- Data.Animations = {
--     {   AnimName = "BG3SX_Grinding",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "0114c60d-0f82-4827-ae11-9e3c46f7d7b5",
--         FallbackBottomAnimationID = "8b9b1bb2-842b-422c-90ff-efbbe84835aa"
--     },
--     {   AnimName = "BG3SX_EatPussy",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = DaDta.Sounds.Kissing, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "5fa5cbe4-1baf-4529-b448-2c53e163626c",
--         FallbackBottomAnimationID = "f801ec0d-9fee-4584-bae3-96d7c3e285ff"
--     },
--     {   AnimName = "BG3SX_FingerFuck",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Kissing, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "adf1b790-da1d-4aaf-9ac4-83157c52d5c2",
--         FallbackBottomAnimationID = "a79232a2-a498-4689-a5bd-8923e80284d2"
--     },
--     {   AnimName = "BG3SX_Blowjob",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Kissing, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "536f0403-c401-4223-bbca-6b807494a527",
--         FallbackBottomAnimationID = "b3984708-7664-49ae-b96d-0512497ea036"
--     },
--     {   AnimName = "BG3SX_Missionary",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "905be226-3edc-4783-9d4e-45d2b57a3d0a",
--         FallbackBottomAnimationID = "48a255e9-02ec-4541-b1b7-32275da29206"
--     },
--     {   AnimName = "BG3SX_Doggy",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "b8f04918-c5b6-4c4a-aee5-390bfaff33bc",
--         FallbackBottomAnimationID = "ffdd67e7-7363-46a4-92e2-38260ef0a2e0"
--     },
--     {   AnimName = "BG3SX_Cowgirl",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "ff7a5a30-b661-4192-bd8f-118373e3f4b8",
--         FallbackBottomAnimationID = "1b220386-55fa-4d2b-8da4-0e7bf453d928"
--     },
--     {   AnimName = "BG3SX_MasturbateStanding",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning, SoundBottom = ata.Sounds.Kissing,
--         FallbackTopAnimationID = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
--         FallbackBottomAnimationID = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
--         Tall_Female = "2c60a233-b669-4b94-81dc-280e98238fd0",
--     },
--     {   AnimName = "BG3SX_Milking",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Kissing,
--         FallbackTopAnimationID = "a71ace41-41ce-4876-8f14-4f419b677533",
--         FallbackBottomAnimationID = "d2a17851-b51b-4e4f-be1d-30dc86b6466a"
--     },
--     {   AnimName = "BG3SX_Wanking",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Kissing, SoundBottom = Data.Sounds.Kissing,
--         FallbackTopAnimationID = "49497bdc-d901-4f60-9e4e-3d31a06f9002",
--         FallbackBottomAnimationID = "49497bdc-d901-4f60-9e4e-3d31a06f9002"
--     },
--     {   AnimName = "BG3SX_BottleSit",
--         AnimLength = 3600, Loop = true, Fade = true, Sound = true,
--         SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning,
--         FallbackTopAnimationID = "d0f6cf4a-a418-4640-bf36-87531d55154b",
--         FallbackBottomAnimationID = "d0f6cf4a-a418-4640-bf36-87531d55154b",
--         Props = {
--         "0f2ccca6-3ce8-4271-aec0-820f6581c551", -- Bottle
--         }    
--     },
-- }