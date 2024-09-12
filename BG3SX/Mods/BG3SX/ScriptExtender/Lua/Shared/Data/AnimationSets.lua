-- local wm = Mods.BG3AF.WaterfallManager
-- AnimationSets = {
--                             -- SetName    -           AnimationSetUuid           -          DynamicAnimationTag         - Type/Slot/Override
--     Body = wm:newAnimSet("BG3SX_Body","c02c2c52-709c-478f-87e3-32d82b4347d7","4d6a6f1d-4f21-49cc-98df-f0d704f46963","Idle", 0,0), -- Check BG3AF on what these do
--     Face = wm:newAnimSet("BG3SX_Face","f1bc6e5c-9a1b-418b-8c23-23b8d98caf36","86f02fc4-3a95-49a0-8505-48d983cd9cc0","Face", 1,1), -- Body is Type 0 for Replace, Face is Type 1 to be an Overlay
-- }
Data.AnimSets = {}
local asm = Mods.BG3AF.ASM
local as = asm.New() -- Created a new AnimationSet

Data.AnimLinks = {
--#region Start Anims
["EmbraceTop"] = as:NewLink("61a83621-65e3-400d-8444-58f3e8db3fb9", "49d78660-5175-4ed2-9853-840bb58cf34a"),
["EmbraceBtm"] = as:NewLink("2ef3a003-54a9-4551-be7f-4f5e16d51dd3", "10fee5b7-d674-436c-994c-616e01efcb90"),
["CarryingTop_Tall"] = as:NewLink("0f6dc57f-a969-4e83-b8dc-212d90a35798", "392073ca-c6e0-4f7d-848b-ffb0b510500b"),
["CarryingBtm_Med"] = as:NewLink("516cb2de-500e-4a33-93e9-4339a4353dde", "04922882-0a2d-4945-8790-cef50276373d"),
--#endregion
--#region Paired Anims
["BlowjobTop"] = as:NewLink("fe82152e-4283-43f5-bdb3-214bc64a7fec", "536f0403-c401-4223-bbca-6b807494a527"),
["BlowJobBtm"] = as:NewLink("587dcf9c-b9de-4bb6-937c-e849f21cdf21", "b3984708-7664-49ae-b96d-0512497ea036"),
["EatOutTop"] = as:NewLink("ade67658-1366-423c-9cd9-33b58c8ca94a", "5fa5cbe4-1baf-4529-b448-2c53e163626c"),
["EatOutBtm"] = as:NewLink("74d770cc-5f39-4a49-92b1-5de873068b93", "f801ec0d-9fee-4584-bae3-96d7c3e285ff"),
["CowGirlTop"] = as:NewLink("025720a9-ee9b-4e3c-9b90-d884b847bd9d", "ff7a5a30-b661-4192-bd8f-118373e3f4b8"),
["CowGirlBtm"] = as:NewLink("7dcefc5b-85b6-4373-94d0-9eb5224a2e2c", "1b220386-55fa-4d2b-8da4-0e7bf453d928"),
["DoggyTop"] = as:NewLink("96c374fa-0559-4f2c-bc15-d76fda8704c9", "b8f04918-c5b6-4c4a-aee5-390bfaff33bc"),
["DoggyBtm"] = as:NewLink("3c6bb4b8-3a74-416f-95d1-2685aba044a9", "ffdd67e7-7363-46a4-92e2-38260ef0a2e0"),
["FingeringTop"] = as:NewLink("ba6b9eda-199c-4f04-bfd7-2b7dc05be633", "adf1b790-da1d-4aaf-9ac4-83157c52d5c2"),
["FingeringTop_M"] = as:NewLink("be7b9cfa-8a63-4eb8-be20-cc6757b180d3", "adf1b790-da1d-4aaf-9ac4-83157c52d5c2"),
["FingeringBtm"] = as:NewLink("8f8014b5-7a2e-44ad-a301-848b310b8a96", "a79232a2-a498-4689-a5bd-8923e80284d2"),
["LayingTop"] = as:NewLink("1de1d865-e3f9-4df2-8078-55af4bde7a77", "905be226-3edc-4783-9d4e-45d2b57a3d0a"),
["LayingBtm"] = as:NewLink("5b99ad69-dd48-4e2d-b77f-0ce61deb93aa", "48a255e9-02ec-4541-b1b7-32275da29206"),
["MilkingTop"] = as:NewLink("97544a13-6602-4189-91ff-7302a69cf855", "a71ace41-41ce-4876-8f14-4f419b677533"),
["MilkingBtm"] = as:NewLink("de2af09d-c73a-4288-ad63-fdf8e2c930b9", "d2a17851-b51b-4e4f-be1d-30dc86b6466a"),
["ScissorTop"] = as:NewLink("eb0e9053-f514-49e4-8b13-bcb942934eb0", "0114c60d-0f82-4827-ae11-9e3c46f7d7b5"),
["ScissorBtm"] = as:NewLink("299ff183-1d48-4ca0-bcce-45f8372322ea", "8b9b1bb2-842b-422c-90ff-efbbe84835aa"),
--#endregion
--#region Masturbation
["BottleSit"] = as:NewLink("580daac5-3e82-4474-924c-6b7731cab169", "d0f6cf4a-a418-4640-bf36-87531d55154b"),
["MasturbateStanding_F"] = as:NewLink("1df05dff-b187-42ec-aacd-6ff99bcec62a", "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b"),
["MasturbateStanding_TallF"] = as:NewLink("2de90307-0134-44f7-9306-a019d2de30df", "2c60a233-b669-4b94-81dc-280e98238fd0"),
["MasturbateWank"] = as:NewLink("f3613d2c-b652-4dd7-b0f2-600e64afbdf4", "49497bdc-d901-4f60-9e4e-3d31a06f9002"),
--#region Experimental
["astarionTop"] = as:NewLink("a856f395-1972-cfa4-9d1a-362f62a67590", "26ea67ff-69ed-42be-88e3-8c63d4602908"),
["astarionBtm"] = as:NewLink("3a38a294-f56c-4d59-90ab-8734b80f3f9f", "44eaa51b-b2e5-405d-80ef-f8e11cc26497"),
["PenisTest"] = as:NewLink("930a998f-65ad-487d-bd2a-3711a5b63190", "2f9140db-696e-4eaf-8a7f-d5c3b4b8a6f1"),
--#endregion
}

function Data.AnimLinks.New(name, animID, MapKey)
    Data.AnimLinks[name] = as:NewLink(animID, MapKey)
    return Data.AnimLinks[name]
end