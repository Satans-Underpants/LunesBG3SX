-- AnimationSets.lua needs to be loaded before AnimationData.lua to create and allow reusing of animations by name
Ext.Require("Shared/Data/AnimationSets.lua")
local anim = Data.AnimLinks
-- Heightmatching.lua needs to be loaded before AnimationData.lua to allow the functions to already exist.
Ext.Require("Shared/Data/Heightmatching.lua")
local hm = Data.Heightmatching

-- Seperated from Data.Animations because these 2 are the start spells which are handled differently and will create a scene
Data.StartSexSpells = {
    ["BG3SX_StartMasturbating"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = true, -- Fade and Sound currently don't do anything and could technically be left out when creating new entries
        SoundTop = Data.Sounds.Moaning,
        Heightmatching = hm:new("BG3SX_StartMasturbating", anim["MasturbateWank"], anim["MasturbateStanding_F"]),
    },
    ["BG3SX_AskForSex"] = {
        AnimLength = 3600, Loop = true, Fade = true, Sound = false,
        SoundTop = Data.Sounds.Silence, SoundBottom = Data.Sounds.Silence,
        Heightmatching = hm:new("BG3SX_AskForSex", anim["EmbraceTop"], anim["EmbraceBtm"]),
    },
}

-- Additional entries need to be done seperately, we only create the instance per animation - We can't do this in the table belonging to the animation itself
local hmi = hm:getInstanceByAnimName("BG3SX_StartMasturbating")
if hmi then -- Solo animation only needs to specify one bodytype/gender and one animation UUID
    hmi:setAnimation("M",  nil, anim["MasturbateWank"])
    hmi:setAnimation("F",  nil, anim["MasturbateStanding_F"])
    hmi:setAnimation("TallF",  nil, anim["MasturbateStanding_TallF"]) -- TallF specific animation - Tall is what we call the "Strong" bodytype identifier
end
local hmi = hm:getInstanceByAnimName("BG3SX_AskForSex")
if hmi then -- Instead of a specific bodytype/gender combo, just the bodytype matchup also works
    hmi:setAnimation("Tall", "Med", anim["CarryingTop_Tall"], anim["CarryingBtm_Med"])
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

Data.Animations = {}
function Data.Animations.new(name, animTop, animBtm, props)
    animBtm = animBtm or nil
    props = props or nil
    Data.Animations[name] = { -- Generic animation setup
        AnimLength = 3600, Loop = true, Fade = true, Sound = true,
        SoundTop = Data.Sounds.Moaning, SoundBottom = Data.Sounds.Moaning}
    if animBtm then
        Data.Animations[name].Heightmatching = hm:new(name, animTop, animBtm)
    else
        Data.Animations[name].Heightmatching = hm:new(name, animTop)
    end
    if props then
        Data.Animations[name].Props = props
    end
    return Data.Animations[name]
end

-- Animation Entries:
----------------------------------------------------
local grinding = Data.Animations.new("BG3SX_Grinding", anim["ScissorTop"], anim["ScissorBtm"])
local eatpussy = Data.Animations.new("BG3SX_EatPussy", anim["EatOutTop"], anim["EatOutBtm"])
eatpussy.SoundTop = Data.Sounds.Kissing
local fingerfuck = Data.Animations.new("BG3SX_FingerFuck", anim["FingeringTop"], anim["FingeringBtm"])
fingerfuck.SoundTop = Data.Sounds.Kissing
local blowjob = Data.Animations.new("BG3SX_Blowjob", anim["BlowjobTop"], anim["BlowjobBtm"])
blowjob.SoundTop = Data.Sounds.Kissing
local laying = Data.Animations.new("BG3SX_Laying", anim["LayingTop"], anim["LayingBtm"])
local doggy = Data.Animations.new("BG3SX_Doggy", anim["DoggyTop"], anim["DoggyBtm"])
local cowgirl = Data.Animations.new("BG3SX_Cowgirl", anim["CowgirlTop"], anim["CowgirlBtm"])
cowgirl.SoundBottom = Data.Sounds.Kissing
local milking = Data.Animations.new("BG3SX_Milking", anim["MilkingTop"], anim["MilkingBtm"])
milking.SoundBottom = Data.Sounds.Kissing
local masturbate = Data.Animations.new("BG3SX_MasturbateStanding", anim["MasturbateStanding_F"])
local wanking = Data.Animations.new("BG3SX_Wanking", anim["MasturbateWank"])
wanking.SoundBottom = Data.Sounds.Kissing
local bottlesit = Data.Animations.new("BG3SX_BottleSit", anim["BottleSit"], nil, "0f2ccca6-3ce8-4271-aec0-820f6581c551") -- Prop: Bottle

-- Heightmatching:
----------------------------------------------------
local hmi = hm:getInstanceByAnimName("BG3SX_MasturbateStanding")
if hmi then
    hmi:setAnimation("TallF",  nil, anim["MasturbateStanding_TallF"])
end


-- How to use:
-----------------------------------------------------------------------------------------------------
-- local BG3SXAnims = Mods.BG3SX.Data.Animations
-- local BG3SXSounds = Mods.BG3SX.Sounds
-- local BG3SXHM = Mods.BG3SX.Data.Heightmatching

-- BG3SXAnims["MyMod_Pegging"] = {
--     AnimLength = 3600, Loop = true, Fade = true, Sound = true, -- AnimLength currently only gets used to loop the sound, just keep it as 3600
--     SoundTop = BG3SXSounds.Kissing, SoundBottom = BG3SXSounds.Kissing,
--     Heightmatching = BG3SXHM:new("MyMod_Pegging", "YourFallbackAnimationUUID", "YourFallbackAnimationUUID"),
-- }

-- local hmi = BG3SXHM:getInstanceByAnimName("MyMod_Pegging")
-- if hmi then
--     hmi:setAnimation("TallF", "MedM", "ASpecificOtherAnimationUUID")
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

-- Or sort all animation table entries first like we do, then the heightmatching instances, its a preference thing

-- You still need to create spells with the same name as the animations you add
-- You can even use:
-- local scene = Mods.BG3SX.Scene:FindSceneByEntity(someEntity)
-- local sceneType = Mods.BG3SX.Sex:DetermineSceneType(scene)
-- To only add your spells when a specific type of scene is running (Types can be found in Shared/Data/SceneTypes.lua)
-- table.insert(Mods.BG3SX.Data.Spells.SexSceneSpells, yourSpellContainer) - Add this somewhere to have it be removed automatically when a scene ends

-- As long as a scene exist, they should work - Please report back if they don't
-- Props get spawned automatically on scene root position per prop UUID listed
-- Props currently have no way of having their own animation so if you do use some it would need to work around that, they are stuck to the ground