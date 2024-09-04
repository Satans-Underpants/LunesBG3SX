-- Premade list of all tags that belong to races
-- Edited to either allow or disallow certain tags
-- Custom race modder can add their own race tag like this:
-- if Mods.BG3SX then
--   local bg3sxWhitelist = Mods.BG3SX.Data.AllowedTagsAndRaces
--   bg3sxWhitelist["YourRaceTagName"] = {TAG = "YourRaceTagUUID", Allowed = nil} -- set Allowed to true or false
-- end
-- If your race has an out of the ordinary bodyshape please check our comments in Heightmatching.lua above our BodyShapeOverrides table (Ctrl+F is your friend)
Data.AllowedTagsAndRaces = {
    ------------------------------------TAGS------------------------------------
    --#region Tags
    ["KID"] = {TAG = "ee978587-6c68-4186-9bfc-3b3cc719a835", Allowed = false
    },
    ["GOBLIN_KID"] = {TAG = "88730ec2-439e-4172-95f4-b7f1875169fa", Allowed = false
    },
    ["AASIMAR"] = {TAG = "41c6cdc9-aff5-46ae-afc4-aa0ccd9cd201", Allowed = true,
        racesUsingTag = {
        {Name = "Trips_Aasimar", RACE = "ff2b6894-b03e-4bc6-a3b4-ce16ce405e7e", Allowed = true},
        {Name = "Trips_Protector", RACE = "dd21fb84-2d6a-4d7d-a418-ca96991d3920", Allowed = true},
        {Name = "Trips_Scourge", RACE = "4738a422-5abd-41a7-a3f8-a35250a73209", Allowed = true},
        {Name = "Trips_Fallen", RACE = "f40da0bb-58e0-4b53-8ec5-805bc1533c8c", Allowed = true},
        {Name = "Trips_Harbinger", RACE = "449f93dd-817f-4870-be6d-fbdb8f0dfb1d", Allowed = true},
        {Name = "Trips_Aasimar_Hireling", RACE = "e7351b45-e18e-4b63-b246-49af554b265a", Allowed = true},
        {Name = "Trips_Protector_Hireling", RACE = "eef353ed-870d-4ac1-8610-4bb0682c6c60", Allowed = true},
        {Name = "Trips_Scourge_Hireling", RACE = "309b9cc5-0156-4f64-b857-8cf83fa2160b", Allowed = true},
        {Name = "Trips_Fallen_Hireling", RACE = "519820ce-d715-42ee-885c-f35feb3f7183", Allowed = true},
        {Name = "Trips_Harbinger_Hireling", RACE = "f3104835-8e41-485c-95f8-9035aca64eb1", Allowed = true},
        },
    },
    ["ABERRATION"] = {TAG = "f6fd70e6-73d3-4a12-a77e-f24f30b3b424", Allowed = false,
        racesUsingTag = {
        {Name = "Aberration", RACE = "4bd6dcba-b21c-4d83-90fe-21bf84ecd50b", Allowed = nil},
        {Name = "Phasm", RACE = "d842d9a5-5f0d-42ab-ab57-89314a1f18ff", Allowed = nil},
        {Name = "Cloaker", RACE = "4742d30d-97b0-4537-a78a-0a803518be54", Allowed = nil},
        },
    },
    ["AGGRESSIVEBEAST"] = {TAG = "1ed04fb5-e654-4dbf-893c-a795952e77e1", Allowed = false,
        racesUsingTag = {
        {Name = "Beast", RACE = "27a5799e-1f5c-4c2c-9adf-fe1c0276a64e", Allowed = nil},
        {Name = "GiantEagle", RACE = "28e90860-5c47-48eb-997a-593ec2b4a16d", Allowed = nil},
        {Name = "Alioramus", RACE = "33923433-64bd-446d-b028-af6d5afe3ee0", Allowed = nil},
        {Name = "|Raven|", RACE = "40a08350-5795-44d9-a19f-b7c9ce4a70cb", Allowed = nil},
        {Name = "Bat", RACE = "7c3f65e7-e463-425a-b7a8-9cb65323e469", Allowed = nil},
        },
    },
    ["ASMODEUSTIEFLING"] = {TAG = "c3fd1fc3-2edf-4d17-935d-44ab92406df1", Allowed = true,
        racesUsingTag = {
        {Name = "AsmodeusTiefling", RACE = "3f30547c-248c-4781-b0e3-6ef2ab99426b", Allowed = nil},
        },
    },
    ["AUTOMATON"] = {TAG = "0f9099e9-a4d8-4b17-b2e5-e6f74eeb79b4", Allowed = false, -- No Animation Support
        racesUsingTag = {
        {Name = "Automaton", RACE = "318e4b03-b7b6-4851-a36d-56fb08f146aa", Allowed = true}, -- Set to true if we ever do add it - Androids anyone?
        },
    },
    ["BEAST"] = {TAG = "890b5a2a-e773-48df-b191-c887d87bec16", Allowed = false,
        racesUsingTag = {
        {Name = "Beast", RACE = "27a5799e-1f5c-4c2c-9adf-fe1c0276a64e", Allowed = nil},
        {Name = "Critter", RACE = "7f8790f2-12be-49db-a6e3-ffac5d4b220e", Allowed = nil},
        {Name = "Badger", RACE = "b4edc21c-93cd-471e-8cdb-33fa95e6257d", Allowed = nil},
        {Name = "Wolf", RACE = "63d47507-0398-4ef2-a217-66098b633e72", Allowed = nil},
        {Name = "Raven", RACE = "4973e85f-f3c7-442f-9673-f876b2db54bb", Allowed = nil},
        {Name = "Bear", RACE = "cc00854c-e17b-4b54-866e-62e23f27e8e5", Allowed = nil},
        {Name = "Boar", RACE = "d7ef9866-7b0c-4a7c-b60a-d7b7273f3f21", Allowed = nil},
        {Name = "Hyena", RACE = "3c7d3cf6-1a23-49ad-9fd0-cd00b1df5276", Allowed = nil},
        {Name = "GiantEagle", RACE = "28e90860-5c47-48eb-997a-593ec2b4a16d", Allowed = nil},
        {Name = "Alioramus", RACE = "33923433-64bd-446d-b028-af6d5afe3ee0", Allowed = nil},
        {Name = "|Raven|", RACE = "40a08350-5795-44d9-a19f-b7c9ce4a70cb", Allowed = nil},
        {Name = "Bat", RACE = "7c3f65e7-e463-425a-b7a8-9cb65323e469", Allowed = nil},
        },
    },
    ["BEHOLDER"] = {TAG = "b4ecfb1d-d8e6-4f2d-a003-0ed1f62b495b", Allowed = false,
        racesUsingTag = {
        {Name = "Beholder", RACE = "5c0db546-e63b-4f80-be9e-ac00097f360d", Allowed = nil},
        },
    },
    ["BIRD"] = {TAG = "bb9ccc7a-405c-4ba5-bcb4-32445b2dfd33", Allowed = false,
        racesUsingTag = {
        {Name = "Bird", RACE = "c55c2eb7-81bb-46e1-89d7-9edf7b3788b7", Allowed = nil},
        },
    },
    ["BUGBEAR"] = {TAG = "dc18a33a-bdd1-41be-8ad5-e6fca917b54e", Allowed = false, -- No Animation Support
        racesUsingTag = {
        {Name = "Bugbear", RACE = "241b8b4d-763f-48e6-b1f8-a261ec0ef36b", Allowed = true}, -- Set to true if we ever do add it
        },
    },
    ["CELESTIAL"] = {TAG = "7cba0bd7-b955-4ac9-95ba-79e75978d9ac", Allowed = true,
        racesUsingTag = {
        {Name = "Celestial", RACE = "a71d0a73-074d-4859-8b9e-f81c0d90060c", Allowed = true},
        {Name = "Hollyphant", RACE = "433ecc79-eae2-467f-81f8-82eb9cd72c5f", Allowed = false},
        },
    },
    ["CONSTRUCT"] = {TAG = "22e5209c-eaeb-40dc-b6ef-a371794110c2", Allowed = false,
        racesUsingTag = {
        {Name = "Construct", RACE = "959e884c-d96c-4f09-91ea-e94a5835bf71", Allowed = nil},
        {Name = "AdamantineGolem", RACE = "84ddccc7-653e-4236-84c4-ca2f5aac719a", Allowed = nil},
        {Name = "AnimatedArmor", RACE = "5577163c-d258-4e12-ab0e-f2e32f0437ae", Allowed = nil},
        {Name = "FleshGolem", RACE = "a20b3cf6-b71f-45f5-af9d-2f9d845d1658", Allowed = nil},
        {Name = "OliverFriend", RACE = "651f6a67-e017-4e31-bf32-d7aed0527623", Allowed = nil},
        },
    },
    ["CRAB"] = {TAG = "757ee779-e15e-4663-8a56-ab8929f56c02", Allowed = false,
        racesUsingTag = {
        {Name = "Crab", RACE = "593235de-6e72-4f86-842e-6fd33109ce1e", Allowed = nil},
        },
    },
    ["CoinHalberd"] = {TAG = "7026d794-eea8-4cf1-b838-03c6e5a9812a", Allowed = false,
    },
    ["DEEPGNOME"] = {TAG = "2bbc3217-3d8c-46e6-b599-a0f1c9063f9a", Allowed = true,
        racesUsingTag = {
        {Name = "DeepGnome", RACE = "3560f4a2-c0b8-4f8b-baf8-6b6eaef0c160", Allowed = true},
        },
    },
    ["DEMON"] = {TAG = "9a187721-0588-4f3c-ba9c-bff4989001b9", Allowed = false,
        racesUsingTag = {
        {Name = "Demon", RACE = "41b32332-c437-4a45-8e5d-6894fba06791", Allowed = nil},
        },
    },
    ["DEVIL"] = {TAG = "6abb4b64-51a7-4d63-9359-66f0047a6fe2", Allowed = false, -- Check if Raphael falls under this
        racesUsingTag = {
        {Name = "Devil", RACE = "490ed21e-07b7-4692-9765-fc526f89c2d6", Allowed = true}, -- Set to true if we ever do add it
        },
    },
    ["DISPLACER_BEAST"] = {TAG = "ba107054-6d0a-45de-93bc-06d72d4feeb3", Allowed = false,
        racesUsingTag = {
        {Name = "Displacer Beast", RACE = "14df0fc9-fe0d-4f53-a506-a3094a222717", Allowed = nil},
        },
    },
    ["DRAGON"] = {TAG = "95748ad1-cda2-4c0c-a9b2-875899327693", Allowed = false, -- :C
        racesUsingTag = {
        {Name = "Dragon", RACE = "eed2c9e5-d1b4-4010-99c4-0e96939867a0", Allowed = nil},
        },
    },
    ["DRAGONBORN"] = {TAG = "02e5e9ed-b6b2-4524-99cd-cb2bc84c754a", Allowed = true,
        racesUsingTag = {
        {Name = "Dragonborn", RACE = "9c61a74a-20df-4119-89c5-d996956b6c66", Allowed = true},
        {Name = "BlackDragonborn", RACE = "fdae09c5-7bfc-47bc-8996-01f797e0c170", Allowed = true},
        {Name = "BlueDragonborn", RACE = "2103e15a-1eae-4dc0-a9b7-3b96c3a08869", Allowed = true},
        {Name = "BrassDragonborn", RACE = "32f676f0-41ca-4469-baa6-341d5c95a708", Allowed = true},
        {Name = "BronzeDragonborn", RACE = "48318453-8aa8-4924-827d-173c957ac1de", Allowed = true},
        {Name = "CopperDragonborn", RACE = "3f7e4753-277e-4259-9b29-423b9149cfb4", Allowed = true},
        {Name = "GoldDragonborn", RACE = "fe648fc4-3bc9-412c-b692-15fecddc3c69", Allowed = true},
        {Name = "GreenDragonborn", RACE = "d6eadf47-54f7-4b05-84b3-0a83eb88d016", Allowed = true},
        {Name = "RedDragonborn", RACE = "61a2c59d-fe8d-4644-8d04-6fae2b239eaf", Allowed = true},
        {Name = "SilverDragonborn", RACE = "dff74c31-2ddc-4270-9615-01a1438ee61c", Allowed = true},
        {Name = "WhiteDragonborn", RACE = "cbe10ab9-11a6-450e-844a-175bcca25de7", Allowed = true},
        {Name = "Aasimar", RACE = "249e2e66-aece-43d5-b902-9921f7f67c79", Allowed = true},
        },
    },
    ["DROWELF"] = {TAG = "a672ac1d-d088-451a-9537-3da4bf74466c", Allowed = true,
        racesUsingTag = {
        {Name = "Drow", RACE = "4f5d1434-5175-4fa9-b7dc-ab24fba37929", Allowed = true},
        },
    },
    ["DROWHALFELF"] = {TAG = "4fa13243-199d-4c9a-b455-d844276a98f5", Allowed = true,
        racesUsingTag = {
        {Name = "HalfDrow", RACE = "e966f47f-998a-41df-ad86-d83b44299efb", Allowed = true},
        },
    },
    ["DUERGARDWARF"] = {TAG = "78adf3cd-4741-47a8-94f6-f3d322432591", Allowed = false,
        racesUsingTag = {
        {Name = "Duergar", RACE = "fe584d14-71ea-4bee-8ba0-99f780d4c957", Allowed = nil},
        },
    },
    ["DWARF"] = {TAG = "486a2562-31ae-437b-bf63-30393e18cbdd", Allowed = false,
        racesUsingTag = {
        {Name = "Dwarf", RACE = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52", Allowed = nil},
        },
    },
    ["ELEMENTAL"] = {TAG = "196351e2-ff25-4e2b-8560-222ac6b94a54", Allowed = false, -- I wouldn't be surprised if at some point someone creates sexy elementals
        racesUsingTag = {
        {Name = "Elemental", RACE = "24dfab7b-7d7e-4df9-aa23-7212b4ef8980", Allowed = true}, -- Set to true if we ever do add it
        {Name = "Elemental_Mud", RACE = "3b637556-32cd-4831-ac89-acf726df55c5", Allowed = nil},
        {Name = "Elemental_Lava", RACE = "7184530f-5384-4da4-9097-9e98403f8249", Allowed = nil},
        {Name = "Mephit", RACE = "7cfa46e7-b17e-4d08-b8d1-f10e89c06bda", Allowed = nil},
        {Name = "Azer", RACE = "582707ec-f902-4888-8601-06bb5a01c557", Allowed = nil},
        },
    },
    ["ELF"] = {TAG = "351f4e42-1217-4c06-b47a-443dcf69b111", Allowed = true,
        racesUsingTag = {
        {Name = "Elf", RACE = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a", Allowed = true},
        },
    },
    ["EMPTY"] = {TAG = "0fcfa622-a3c9-4a03-aab4-2a74904b62eb", Allowed = false,
    },
    ["FEY"] = {TAG = "8cac055c-82dd-435c-9496-cf4c4b4581ab", Allowed = false,
        racesUsingTag = {
        {Name = "Fey", RACE = "632746dc-dcab-4b16-9e7e-029a04aafb59", Allowed = nil},
        {Name = "Hag", RACE = "e2798930-512f-4205-b87a-05b39b569752", Allowed = nil},
        {Name = "Meenlock", RACE = "c9479054-6a06-438b-9ab3-0467f70709de", Allowed = nil},
        },
    },
    ["FIEND"] = {TAG = "44be2f5b-f27e-4665-86f1-49c5bfac54ab", Allowed = true,
        racesUsingTag = {
        {Name = "Fiend", RACE = "99c33978-f236-4f5b-a8d8-59aeeaf6140f", Allowed = true},
        {Name = "Hellsboar", RACE = "94343b04-974d-44bd-bdd5-34de45d1d058", Allowed = false},
        {Name = "Imp", RACE = "7efb6df1-4f74-4d83-aeba-031b52d003a1", Allowed = false},
        {Name = "Cambion", RACE = "b278457e-a3ee-45b1-8ff4-620b868c9193", Allowed = true},
        {Name = "Merregon", RACE = "0fff84f9-f614-49a1-81d6-2c9e82eb241e", Allowed = false},
        {Name = "Butler", RACE = "4d50d868-4c03-4c4b-86f3-009a652c8a7f", Allowed = false},
        {Name = "Incubus", RACE = "9d44d79f-6db0-49da-90b0-0a1573d91098", Allowed = true},
        {Name = "Succubus", RACE = "7631ede0-25d5-4d96-9425-3d0ebd536ea5", Allowed = true},
        {Name = "Vengeful Imp", RACE = "bd6cb035-8e37-475c-bea6-cca889ffb9d3", Allowed = false},
        {Name = "Vengeful Boar", RACE = "a8745b42-88cc-4eaf-ba0f-8a4b0ba5fa8e", Allowed = false},
        {Name = "Vengeful Cambion", RACE = "f8767477-8708-4493-8902-c5ac84a2e40b", Allowed = true},
        {Name = "Raphaelian Merregon", RACE = "309b0bf4-47ec-4c65-925a-5f944d6353c8", Allowed = false},
        },
    },
    ["FORESTGNOME"] = {TAG = "09518377-4ea1-4ce2-b8e8-61477c26ebdd", Allowed = true,
        racesUsingTag = {
        {Name = "ForestGnome", RACE = "0c6f801e-74fc-492a-ab25-3ca9604156b4", Allowed = true},
        },
    },
    ["FROG"] = {TAG = "0976fc05-da0e-43ea-8978-5accef445e0f", Allowed = false,
        racesUsingTag = {
        {Name = "Frog", RACE = "bdd8f564-cbfd-4ca0-a92f-1dbc5545549d", Allowed = nil},
        },
    },
    ["GIANT"] = {TAG = "375bd683-249f-488e-8ada-4ea49df5540d", Allowed = false, -- May need to set to true if its added during a potion effect
        racesUsingTag = {
        {Name = "Giant", RACE = "177b5c65-3f54-48a0-9e3b-edd74c0685a7", Allowed = true}, -- Set to true if we ever do add it
        },
    },
    ["GITH"] = {TAG = "677ffa76-2562-4217-873e-2253d4720ba4", Allowed = true,
        racesUsingTag = {
        {Name = "Githyanki", RACE = "bdf9b779-002c-4077-b377-8ea7c1faa795", Allowed = true},
        {Name = "Githzerai", RACE = "ca1c9216-a0cf-44e7-811a-2f9081c536ed", Allowed = true},
        },
    },
    ["GITHYANKI"] = {TAG = "019170e7-9a50-448f-ae1b-701dc75afd3e", Allowed = true,
        racesUsingTag = {
        {Name = "Githyanki", RACE = "bdf9b779-002c-4077-b377-8ea7c1faa795", Allowed = true},
        },
    },
    ["GITHZERAI"] = {TAG = "7fa93b80-8ba5-4c1d-9b00-5dd20ced7f67", Allowed = true,
        racesUsingTag = {
        {Name = "Githzerai", RACE = "ca1c9216-a0cf-44e7-811a-2f9081c536ed", Allowed = true},
        },
    },
    ["GNOLL"] = {TAG = "1350164f-85e1-42f9-89c9-eb0c6703e890", Allowed = false,
        racesUsingTag = {
        {Name = "Gnoll", RACE = "2a873c76-fb44-404a-982e-5b9c57256b4f", Allowed = nil},
        {Name = "Gnoll Flind", RACE = "4f2fd01e-fa57-4c3f-81e2-408d6fd4fdd0", Allowed = nil},
        },
    },
    ["GNOME"] = {TAG = "1f0551f3-d769-47a9-b02b-5d3a8c51978c", Allowed = true,
        racesUsingTag = {
        {Name = "Gnome", RACE = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d", Allowed = true},
        },
    },
    ["GOBLIN"] = {TAG = "608597d9-bf00-4ede-aabe-767457280925", Allowed = false,
        racesUsingTag = {
        {Name = "Goblin", RACE = "54fb4eb9-2cb9-4925-a94f-c16d15e20999", Allowed = nil},
        },
    },
    ["HALFELF"] = {TAG = "34317158-8e6e-45a2-bd1e-6604d82fdda2", Allowed = true,
        racesUsingTag = {
        {Name = "HalfElf", RACE = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0", Allowed = true},
        },
    },
    ["HALFLING"] = {TAG = "b99b6a5d-8445-44e4-ac58-81b2ee88aab1", Allowed = true,
        racesUsingTag = {
        {Name = "Halfling", RACE = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04", Allowed = true},
        },
    },
    ["HALFORC"] = {TAG = "3311a9a9-cdbc-4b05-9bf6-e02ba1fc72a3", Allowed = true,
        racesUsingTag = {
        {Name = "HalfOrc", RACE = "5c39a726-71c8-4748-ba8d-f768b3c11a91", Allowed = true},
        },
    },
    ["HARPY"] = {TAG = "4ce54d09-192f-4090-a5fd-72b84c9400de", Allowed = false, -- No Animation Support
        racesUsingTag = {
        {Name = "Harpy", RACE = "34afb07e-44d1-4d00-b2eb-aff508a87718", Allowed = true}, -- Set to true if we ever do add it
        },
    },
    ["HIGHELF"] = {TAG = "492c3200-1226-4114-bad1-f6b1ba737f3d", Allowed = true,
        racesUsingTag = {
        {Name = "HighElf", RACE = "4fda6bce-0b91-4427-901f-690c2d091c47", Allowed = true},
        },
    },
    ["HIGHHALFELF"] = {TAG = "52b71dea-9d4e-402d-9700-fb9c360a44c9", Allowed = true,
        racesUsingTag = {
        {Name = "HighHalfElf", RACE = "30fafb0b-7c8b-4917-bd2a-536233b35d3c", Allowed = true},
        },
    },
    ["HILLDWARF"] = {TAG = "534098fa-601d-4f6e-8c4e-b3a8d4b1f141", Allowed = false,
        racesUsingTag = {
        {Name = "HillDwarf", RACE = "78f5e3e8-a9f8-4249-8007-84dc922640b2", Allowed = true},
        },
    },
    ["HOBGOBLIN"] = {TAG = "193938c4-ed1c-4648-af3f-f4b59152ec92", Allowed = false, -- No Animation Support
        racesUsingTag = {
        {Name = "Hobgoblin", RACE = "a234ff21-6324-4ce2-977a-ae921475c046", Allowed = true}, -- Set to true if we ever do add it
        },
    },
    ["HOOKHORROR"] = {TAG = "5e1d89d2-c7f6-49d2-8ed8-64b4ae7c4aba", Allowed = false,
        racesUsingTag = {
        {Name = "Hook Horror", RACE = "e154d373-8317-47af-b88f-0fb444677fc9", Allowed = nil},
        },
    },
    ["HUMAN"] = {TAG = "69fd1443-7686-4ca9-9516-72ec0b9d94d7", Allowed = true,
        racesUsingTag = {
        {Name = "Human", RACE = "0eb594cb-8820-4be6-a58d-8be7a1a98fba", Allowed = true},
        },
    },
    ["HUMANOID"] = {TAG = "7fbed0d4-cabc-4a9d-804e-12ca6088a0a8", Allowed = true,
        racesUsingTag = {
        {Name = "Humanoid", RACE = "899d275e-9893-490a-9cd5-be856794929f", Allowed = true},
        {Name = "Werewolf", RACE = "faaaf3f6-4f9e-4042-92bf-a0645dcac232", Allowed = false},
        {Name = "BlackDragonborn", RACE = "fdae09c5-7bfc-47bc-8996-01f797e0c170", Allowed = true},
        {Name = "BlueDragonborn", RACE = "2103e15a-1eae-4dc0-a9b7-3b96c3a08869", Allowed = true},
        {Name = "BrassDragonborn", RACE = "32f676f0-41ca-4469-baa6-341d5c95a708", Allowed = true},
        {Name = "BronzeDragonborn", RACE = "48318453-8aa8-4924-827d-173c957ac1de", Allowed = true},
        {Name = "CopperDragonborn", RACE = "3f7e4753-277e-4259-9b29-423b9149cfb4", Allowed = true},
        {Name = "GoldDragonborn", RACE = "fe648fc4-3bc9-412c-b692-15fecddc3c69", Allowed = true},
        {Name = "GreenDragonborn", RACE = "d6eadf47-54f7-4b05-84b3-0a83eb88d016", Allowed = true},
        {Name = "RedDragonborn", RACE = "61a2c59d-fe8d-4644-8d04-6fae2b239eaf", Allowed = true},
        {Name = "SilverDragonborn", RACE = "dff74c31-2ddc-4270-9615-01a1438ee61c", Allowed = true},
        {Name = "WhiteDragonborn", RACE = "cbe10ab9-11a6-450e-844a-175bcca25de7", Allowed = true},
        {Name = "Meazel", RACE = "00c7ee76-58d0-429c-ae4d-ecc3d653da06", Allowed = false},
        {Name = "ShadarKai", RACE = "1881d9c3-5654-491b-868d-14b6af8b79af", Allowed = true}, -- Should just be "He Who Was" with a regular elf rig
        {Name = "Aasimar", RACE = "249e2e66-aece-43d5-b902-9921f7f67c79", Allowed = true},
        {Name = "Trips_Protector", RACE = "dd21fb84-2d6a-4d7d-a418-ca96991d3920", Allowed = false},
        {Name = "Trips_Scourge", RACE = "4738a422-5abd-41a7-a3f8-a35250a73209", Allowed = false},
        {Name = "Trips_Fallen", RACE = "f40da0bb-58e0-4b53-8ec5-805bc1533c8c", Allowed = false},
        {Name = "Trips_Harbinger", RACE = "449f93dd-817f-4870-be6d-fbdb8f0dfb1d", Allowed = false},
        {Name = "Trips_Protector_Hireling", RACE = "eef353ed-870d-4ac1-8610-4bb0682c6c60", Allowed = false},
        {Name = "Trips_Scourge_Hireling", RACE = "309b9cc5-0156-4f64-b857-8cf83fa2160b", Allowed = false},
        {Name = "Trips_Fallen_Hireling", RACE = "519820ce-d715-42ee-885c-f35feb3f7183", Allowed = false},
        {Name = "Trips_Harbinger_Hireling", RACE = "f3104835-8e41-485c-95f8-9035aca64eb1", Allowed = false},
        },
    },
    ["KOBOLD"] = {TAG = "f68151f2-58ee-42e6-98ad-7d858c4a0f13", Allowed = false,
        racesUsingTag = {
        {Name = "Kobold", RACE = "90e5a7c5-365b-48a6-8b71-15c61955a4d1", Allowed = nil},
        },
    },
    ["KUOTOA"] = {TAG = "e3763301-199e-4022-8813-da1bb4eb9542", Allowed = false,
        racesUsingTag = {
        {Name = "Kuotoa", RACE = "ef9802b4-e872-4dec-bdb2-1cc0038b6856", Allowed = nil},
        },
    },
    ["LIGHTFOOTHALFLING"] = {TAG = "57a00605-9e74-477c-bd9d-53c721e25e56", Allowed = true,
        racesUsingTag = {
        {Name = "LightfootHalfling", RACE = "a8828cb9-589d-489e-8373-6495eb31ffc1", Allowed = true},
        },
    },
    ["LOLTHDROWELF"] = {TAG = "ef9c5b74-56a8-48cc-b0b9-169ee16bf026", Allowed = true,
        racesUsingTag = {
        {Name = "LolthDrow", RACE = "c5f8ebdd-f4a5-4d2d-9eab-4a8d1b1dd724", Allowed = true},
        },
    },
    ["MEPHISTOPHELESTIEFLING"] = {TAG = "ec5bea6b-26f1-4917-919c-375f67ac13d1", Allowed = true,
        racesUsingTag = {
        {Name = "MephistophelesTiefling", RACE = "b03bdf0f-876d-4567-a0a3-28627319c919", Allowed = true},
        },
    },
    ["MINDFLAYER"] = {TAG = "8ee4d870-3f6b-466c-968f-ab0ba2be6229", Allowed = false, -- No Animation Support
        racesUsingTag = {
        {Name = "Mindflayer", RACE = "d4361929-70b8-4610-8073-2c827bf6d2fc", Allowed = true}, -- Set to true if we ever do add it
        },
    },
    ["MONK"] = {TAG = "e1e460bb-d0ae-4452-8529-c9e176558731", Allowed = true, -- Some Githzerai Tag - Made by Kaz
        racesUsingTag = {
        {Name = "Githzerai", RACE = "ca1c9216-a0cf-44e7-811a-2f9081c536ed", Allowed = true},
        },
    },
    ["MONSTROSITY"] = {TAG = "081a2ef4-dc1b-4d5b-bae3-8db81bef1d06", Allowed = true,
        racesUsingTag = {
        {Name = "Monstrosity", RACE = "31e1a2fe-0322-4540-95c3-9a28ad7fb202", Allowed = false},
        {Name = "Ettercap", RACE = "3acbe536-b157-471a-9919-611576da8ff6", Allowed = false},
        {Name = "Bulette", RACE = "95bd2d11-37c8-4cbc-b066-1dec40264b95", Allowed = false},
        {Name = "Gremishka", RACE = "dc532c8f-cbfd-4513-acc6-922b88d09271", Allowed = false},
        {Name = "ShadowMastiff", RACE = "d3c0ee1f-3cc3-463a-8869-edf646c5bbca", Allowed = false},
        {Name = "Tressym", RACE = "d5876240-2072-4a51-894b-c53e0866f8d4", Allowed = false},
        {Name = "Blink Dog", RACE = "e19f2e68-e259-457b-9c56-c29a2d48ed7a", Allowed = false},
        {Name = "Doppelganger", RACE = "07431f26-c33f-47f6-a418-c5613a37bd95", Allowed = true},
        {Name = "Drider", RACE = "14360cf2-e8cb-42dc-a02a-1e70b7713ab9", Allowed = false}, -- No Drider Sex
        },
    },
    ["MOUNTAINDWARF"] = {TAG = "1dc20a7a-00e7-4126-80ad-aa1152a2136c", Allowed = true,
        racesUsingTag = {
        {Name = "MountainDwarf", RACE = "6e455d3b-293a-420b-baae-74260ed9aebf", Allowed = true},
        },
    },
    ["MYCONID"] = {TAG = "480f5568-7c49-45e4-9543-7c06e43bdf52", Allowed = false,
        racesUsingTag = {
        {Name = "Myconid", RACE = "509af6eb-26a7-4c85-bd5f-410e6af8d6fb", Allowed = nil},
        },
    },
    ["MagicalSpecter"] = {TAG = "8317a985-dcd7-4758-b11d-a6b39b170b03", Allowed = false,
    },
    ["OGRE"] = {TAG = "cb53ec1e-af17-4dc2-bb28-2ac56d7eba96", Allowed = false,
        racesUsingTag = {
        {Name = "Ogre", RACE = "40af3916-df35-4e6e-aa8b-276cfc2c4f6f", Allowed = nil},
        },
    },
    ["OOZE"] = {TAG = "92f9e66f-630d-4249-b936-c3dc1ae2b337", Allowed = false,
        racesUsingTag = {
        {Name = "Ooze", RACE = "889ca85e-9263-4086-aeab-352dd1eed3a0", Allowed = nil},
        },
    },
    ["PLANAR"] = {TAG = "bad00ba2-8a49-450c-8387-af47681717f1", Allowed = true,
        racesUsingTag = {
        {Name = "Trips_Aasimar", RACE = "ff2b6894-b03e-4bc6-a3b4-ce16ce405e7e", Allowed = true},
        {Name = "Trips_Protector", RACE = "dd21fb84-2d6a-4d7d-a418-ca96991d3920", Allowed = true},
        {Name = "Trips_Scourge", RACE = "4738a422-5abd-41a7-a3f8-a35250a73209", Allowed = true},
        {Name = "Trips_Fallen", RACE = "f40da0bb-58e0-4b53-8ec5-805bc1533c8c", Allowed = true},
        {Name = "Trips_Harbinger", RACE = "449f93dd-817f-4870-be6d-fbdb8f0dfb1d", Allowed = true},
        {Name = "Trips_Aasimar_Hireling", RACE = "e7351b45-e18e-4b63-b246-49af554b265a", Allowed = true},
        {Name = "Trips_Protector_Hireling", RACE = "eef353ed-870d-4ac1-8610-4bb0682c6c60", Allowed = true},
        {Name = "Trips_Scourge_Hireling", RACE = "309b9cc5-0156-4f64-b857-8cf83fa2160b", Allowed = true},
        {Name = "Trips_Fallen_Hireling", RACE = "519820ce-d715-42ee-885c-f35feb3f7183", Allowed = true},
        {Name = "Trips_Harbinger_Hireling", RACE = "f3104835-8e41-485c-95f8-9035aca64eb1", Allowed = true},
        },
    },
    ["PLANT"] = {TAG = "125b3d94-3997-4fc4-8211-1768b67dbe4a", Allowed = false,
        racesUsingTag = {
        {Name = "Plant", RACE = "eb48ad96-0676-439d-ab44-83a2495550f8", Allowed = nil},
        {Name = "Blight", RACE = "3a012942-fdc0-4554-825a-bf030cc9620e", Allowed = nil},
        {Name = "Shambling Mound", RACE = "2aea2906-f9bd-427f-aad8-300fb9107c0d", Allowed = nil},
        },
    },
    ["RAT"] = {TAG = "9568e56b-27a2-45fc-92c5-fa33eeb6f54c", Allowed = false,
        racesUsingTag = {
        {Name = "Rat", RACE = "80d7f493-0adb-43e7-a4ad-59095b5d80df", Allowed = nil},
        },
    },
    ["REALLY_AASIMAR"] = {TAG = "2fddf7dd-f79b-4998-882c-d7257badbfe6", Allowed = true,
        racesUsingTag = {
        {Name = "Trips_Aasimar", RACE = "ff2b6894-b03e-4bc6-a3b4-ce16ce405e7e", Allowed = true},
        {Name = "Trips_Protector", RACE = "dd21fb84-2d6a-4d7d-a418-ca96991d3920", Allowed = true},
        {Name = "Trips_Scourge", RACE = "4738a422-5abd-41a7-a3f8-a35250a73209", Allowed = true},
        {Name = "Trips_Fallen", RACE = "f40da0bb-58e0-4b53-8ec5-805bc1533c8c", Allowed = true},
        {Name = "Trips_Harbinger", RACE = "449f93dd-817f-4870-be6d-fbdb8f0dfb1d", Allowed = true},
        {Name = "Trips_Aasimar_Hireling", RACE = "e7351b45-e18e-4b63-b246-49af554b265a", Allowed = true},
        {Name = "Trips_Protector_Hireling", RACE = "eef353ed-870d-4ac1-8610-4bb0682c6c60", Allowed = true},
        {Name = "Trips_Scourge_Hireling", RACE = "309b9cc5-0156-4f64-b857-8cf83fa2160b", Allowed = true},
        {Name = "Trips_Fallen_Hireling", RACE = "519820ce-d715-42ee-885c-f35feb3f7183", Allowed = true},
        {Name = "Trips_Harbinger_Hireling", RACE = "f3104835-8e41-485c-95f8-9035aca64eb1", Allowed = true},
        },
    },
    ["REALLY_GITH"] = {TAG = "e49c027c-6ec6-4158-9afb-8b59236d10fd", Allowed = true,
        racesUsingTag = {
        {Name = "Githyanki", RACE = "bdf9b779-002c-4077-b377-8ea7c1faa795", Allowed = true},
        {Name = "Githzerai", RACE = "ca1c9216-a0cf-44e7-811a-2f9081c536ed", Allowed = true},
        },
    },
    ["REALLY_GITHYANKI"] = {TAG = "1180781a-76f5-419c-80ee-9e4c973f1113", Allowed = true,
        racesUsingTag = {
        {Name = "Githyanki", RACE = "bdf9b779-002c-4077-b377-8ea7c1faa795", Allowed = true},
        },
    },
    ["REALLY_GITHZERAI"] = {TAG = "697b9262-7d3a-4bcd-b5c5-e36cf02b369d", Allowed = true,
        racesUsingTag = {
        {Name = "Githzerai", RACE = "ca1c9216-a0cf-44e7-811a-2f9081c536ed", Allowed = true},
        },
    },
    ["REALLY_PLANAR"] = {TAG = "4cb02915-7ad7-4141-907e-93253c6a8644", Allowed = true,
        racesUsingTag = {
        {Name = "Trips_Aasimar", RACE = "ff2b6894-b03e-4bc6-a3b4-ce16ce405e7e", Allowed = true},
        {Name = "Trips_Protector", RACE = "dd21fb84-2d6a-4d7d-a418-ca96991d3920", Allowed = true},
        {Name = "Trips_Scourge", RACE = "4738a422-5abd-41a7-a3f8-a35250a73209", Allowed = true},
        {Name = "Trips_Fallen", RACE = "f40da0bb-58e0-4b53-8ec5-805bc1533c8c", Allowed = true},
        {Name = "Trips_Harbinger", RACE = "449f93dd-817f-4870-be6d-fbdb8f0dfb1d", Allowed = true},
        {Name = "Trips_Aasimar_Hireling", RACE = "e7351b45-e18e-4b63-b246-49af554b265a", Allowed = true},
        {Name = "Trips_Protector_Hireling", RACE = "eef353ed-870d-4ac1-8610-4bb0682c6c60", Allowed = true},
        {Name = "Trips_Scourge_Hireling", RACE = "309b9cc5-0156-4f64-b857-8cf83fa2160b", Allowed = true},
        {Name = "Trips_Fallen_Hireling", RACE = "519820ce-d715-42ee-885c-f35feb3f7183", Allowed = true},
        {Name = "Trips_Harbinger_Hireling", RACE = "f3104835-8e41-485c-95f8-9035aca64eb1", Allowed = true},
        },
    },
    ["REDCAP"] = {TAG = "ec2ee51e-80de-42a2-9d34-a5c9aa75cf75", Allowed = false,
        racesUsingTag = {
        {Name = "Redcap", RACE = "b0957b33-4a99-48d9-9f2e-36b029c91a30", Allowed = nil},
        {Name = "Redcap Pirate", RACE = "da80f25a-fc31-4c47-bef3-276ba3baf10f", Allowed = nil},
        },
    },
    ["ROCKGNOME"] = {TAG = "664cc044-a0ea-43a1-b21f-d8cad7721102", Allowed = true,
        racesUsingTag = {
        {Name = "RockGnome", RACE = "2cf6c770-24ab-4608-9617-d1e46c11ab55", Allowed = true},
        },
    },
    ["SCRYING_EYE"] = {TAG = "0bdf874a-3703-49be-b1cf-4d291d4e495b", Allowed = false,
        racesUsingTag = {
        {Name = "ScryingEye", RACE = "9a2fa9f4-f39f-42f4-b747-82a56a5bd815", Allowed = nil},
        },
    },
    ["SELDARINEDROWELF"] = {TAG = "6e913b6e-58b1-41bf-8751-89250dd17bff", Allowed = true,
        racesUsingTag = {
        {Name = "SeldarineDrow", RACE = "4d30b4f9-7bb2-4fc2-a7bc-080f116e325a", Allowed = true},
        },
    },
    ["SHORT"] = {TAG = "50e7beca-4e90-43cd-b7c5-c235e236077f", Allowed = false,
        racesUsingTag = {
        {Name = "Dwarf", RACE = "0ab2874d-cfdc-405e-8a97-d37bfbb23c52", Allowed = nil},
        {Name = "Gnome", RACE = "f1b3f884-4029-4f0f-b158-1f9fe0ae5a0d", Allowed = nil},
        {Name = "Halfling", RACE = "78cd3bcc-1c43-4a2a-aa80-c34322c16a04", Allowed = nil},
        {Name = "Goblin", RACE = "54fb4eb9-2cb9-4925-a94f-c16d15e20999", Allowed = nil},
        },
    },
    ["SKELETON"] = {TAG = "146a89e7-802f-4926-bc21-4a41c2478502", Allowed = false,
        racesUsingTag = {
        {Name = "Skeleton", RACE = "ad533889-a032-41f2-b90c-592575b4e21c", Allowed = nil},
        },
    },
    ["SPIDER"] = {TAG = "8c8932c5-45f7-4d45-8f62-182db82ddcb0", Allowed = false,
        racesUsingTag = {
        {Name = "Spider", RACE = "b5e411bd-a0ed-45ca-a679-b4b3ba571f3e", Allowed = nil},
        },
    },
    ["SPIDER_PHASE"] = {TAG = "c3b3e9cd-ad18-475a-8df1-4562b2a6af19", Allowed = false,
        racesUsingTag = {
        {Name = "PhaseSpider", RACE = "b7a80e95-eb5a-4602-b235-8ae612ffe09d", Allowed = nil},
        },
    },
    ["STOUTHALFLING"] = {TAG = "8d545fa1-8416-493f-8325-7d112bceced8", Allowed = true,
        racesUsingTag = {
        {Name = "StoutHalfling", RACE = "24e075cc-b21e-4639-ac60-fc513083b0e7", Allowed = true},
        },
    },
    ["TIEFLING"] = {TAG = "aaef5d43-c6f3-434d-b11e-c763290dbe0c", Allowed = true,
        racesUsingTag = {
        {Name = "Tiefling", RACE = "b6dccbed-30f3-424b-a181-c4540cf38197", Allowed = true},
        },
    },
    ["UNDEAD"] = {TAG = "33c625aa-6982-4c27-904f-e47029a9b140", Allowed = true, -- Undead set to true, only because of Vampires
        racesUsingTag = {
        {Name = "Undead", RACE = "02e5c59e-80e7-4176-a289-1d08699583f5", Allowed = true},
        {Name = "UndeadHighElfHidden", RACE = "f4792c5f-8740-4f22-b77d-5df1e5753c46", Allowed = false},
        {Name = "UndeadHighElfRevealed", RACE = "6cd07c7c-cf18-4c82-87ee-113d40601edd", Allowed = false},
        {Name = "Zombie", RACE = "56b3ae88-2b72-4838-9f3b-00929aeae6e1", Allowed = false},
        {Name = "DarkJusticiar", RACE = "28e831e5-bd76-473d-b002-4b5927548bf0", Allowed = false},
        {Name = "Brewer", RACE = "c4eedb2a-0a2f-4ef2-9e6b-b5f7734ab38b", Allowed = false},
        {Name = "Ghost", RACE = "c5eb388a-1b23-413e-b8c2-debb885e829e", Allowed = false},
        {Name = "CrawlingClaw", RACE = "76b61437-097b-42b9-af0a-66e9d47b20bb", Allowed = false},
        {Name = "TollCollector", RACE = "f182870e-4274-4903-baa3-3978df3ebbed", Allowed = false},
        {Name = "ApostleOfMyrkul", RACE = "4583934f-752d-4be7-a304-988fd70c929a", Allowed = false},
        {Name = "Shadow", RACE = "9d4c97ce-5b07-4bf6-97fa-2e744032e170", Allowed = false},
        {Name = "Wraith", RACE = "99fcf1c3-b189-48e0-b21a-08438e03c929", Allowed = false},
        {Name = "FlyingGhoul", RACE = "20c2a23c-07dc-4108-9db7-05d002dd6efc", Allowed = false},
        {Name = "Ghoul", RACE = "cc44199c-b455-44d9-9ac8-55411b8e80c5", Allowed = false},
        {Name = "UndeadFace", RACE = "276f2e3b-ce11-4f0f-bfeb-1fb3709c3617", Allowed = false},
        {Name = "Surgeon", RACE = "e9fd8f24-ce45-4180-a395-bf4c758ccd91", Allowed = false},
        {Name = "Mummy", RACE = "3c066deb-eaaf-4bbf-b021-61ad0acc51a2", Allowed = false},
        {Name = "Mummy Lord", RACE = "420f8e51-0d5a-46b4-aa94-562fdd510d77", Allowed = false},
        {Name = "SkeletalDragon", RACE = "530e38f9-2e43-4a98-bd24-49f1e0cf6b94", Allowed = false},
        {Name = "DeathKnight", RACE = "7722d7b5-c734-429e-b0f2-fd768caa5ae6", Allowed = false},
        {Name = "Ghast", RACE = "788a78a7-4b6e-46b7-9d3c-2f8d50c9eef4", Allowed = false},
        {Name = "Vampire", RACE = "b615c4e0-2157-4878-ab4c-cdacc679a87b", Allowed = true},
        {Name = "VampireSpawn", RACE = "dbb041de-231c-4dc9-9a25-91c81b45976e", Allowed = true},
        {Name = "Wraith", RACE = "90fb2456-c6c9-40b8-9753-e4d9bc7d7165", Allowed = false},
        },
    },
    ["UNDERDARK"] = {TAG = "60f6b464-752f-4970-a855-f729565b5e07", Allowed = true,
        racesUsingTag = {
        {Name = "Drow", RACE = "4f5d1434-5175-4fa9-b7dc-ab24fba37929", Allowed = true},
        {Name = "Duergar", RACE = "fe584d14-71ea-4bee-8ba0-99f780d4c957", Allowed = false},
        {Name = "DeepGnome", RACE = "3560f4a2-c0b8-4f8b-baf8-6b6eaef0c160", Allowed = false},
        },
    },
    ["VO_POSTPROCESS"] = {TAG = "eae44d86-3321-4a0a-811d-4fd8e48b5723",  Allowed = true, -- Technically it has some racesUsingTag but we just allow it to be skipped
    },
    ["WOODELF"] = {TAG = "889e0db5-d03e-4b63-86d7-13418f69729f", Allowed = true,
        racesUsingTag = {
        {Name = "WoodElf", RACE = "a459ba68-a9ec-4c8e-b127-602615f5b4c0", Allowed = true},
        },
    },
    ["WOODHALFELF"] = {TAG = "5ffb703c-3ef4-493b-966d-749bc038f6bd", Allowed = true,
        racesUsingTag = {
        {Name = "WoodHalfElf", RACE = "76057327-da03-4398-aaf0-c59345ef3a8b", Allowed = true},
        },
    },
    ["ZARIELTIEFLING"] = {TAG = "ab677895-e08a-479f-a043-eac2d8447188", Allowed = true,
        racesUsingTag = {
        {Name = "ZarielTiefling", RACE = "88d0d219-9dcb-462b-aab6-ccf31eeee2e3", Allowed = true},
        },
    },
    ["ZERTH"] = {TAG = "3836988a-2342-498d-916e-96adf91ab8bc", Allowed = true,
        racesUsingTag = {
        {Name = "Githzerai", RACE = "ca1c9216-a0cf-44e7-811a-2f9081c536ed", Allowed = true},
        },
    },
    --#endregion
    ----------------------------Races without their own tags--------------------------
    --#region Races
    ["Aasimar"] = {UUID = "249e2e66-aece-43d5-b902-9921f7f67c79", Allowed = true},
    ["AdamantineGolem"] = {UUID = "84ddccc7-653e-4236-84c4-ca2f5aac719a", Allowed = false},
    ["Alioramus"] = {UUID = "33923433-64bd-446d-b028-af6d5afe3ee0", Allowed = false},
    ["AnimatedArmor"] = {UUID = "5577163c-d258-4e12-ab0e-f2e32f0437ae", Allowed = false},
    ["Azer"] = {UUID = "582707ec-f902-4888-8601-06bb5a01c557", Allowed = false},
    ["Badger"] = {UUID = "b4edc21c-93cd-471e-8cdb-33fa95e6257d", Allowed = false},
    ["Bat"] = {UUID = "7c3f65e7-e463-425a-b7a8-9cb65323e469", Allowed = false},
    ["Bear"] = {UUID = "cc00854c-e17b-4b54-866e-62e23f27e8e5", Allowed = false},
    ["BlackDragonborn"] = {UUID = "fdae09c5-7bfc-47bc-8996-01f797e0c170", Allowed = true},
    ["Blight"] = {UUID = "3a012942-fdc0-4554-825a-bf030cc9620e", Allowed = false},
    ["Blink Dog"] = {UUID = "e19f2e68-e259-457b-9c56-c29a2d48ed7a", Allowed = false},
    ["BlueDragonborn"] = {UUID = "2103e15a-1eae-4dc0-a9b7-3b96c3a08869", Allowed = true},
    ["Boar"] = {UUID = "d7ef9866-7b0c-4a7c-b60a-d7b7273f3f21", Allowed = false},
    ["BrassDragonborn"] = {UUID = "32f676f0-41ca-4469-baa6-341d5c95a708", Allowed = true},
    ["BronzeDragonborn"] = {UUID = "48318453-8aa8-4924-827d-173c957ac1de", Allowed = true},
    ["Butler"] = {UUID = "4d50d868-4c03-4c4b-86f3-009a652c8a7f", Allowed = false},
    ["Cambion"] = {UUID = "b278457e-a3ee-45b1-8ff4-620b868c9193", Allowed = false}, -- No Animation Support
    ["Cloaker"] = {UUID = "4742d30d-97b0-4537-a78a-0a803518be54", Allowed = false},
    ["CopperDragonborn"] = {UUID = "3f7e4753-277e-4259-9b29-423b9149cfb4", Allowed = true},
    ["DeathKnight"] = {UUID = "7722d7b5-c734-429e-b0f2-fd768caa5ae6", Allowed = false},
    ["Doppelganger"] = {UUID = "07431f26-c33f-47f6-a418-c5613a37bd95", Allowed = true},
    ["Elemental_Lava"] = {UUID = "7184530f-5384-4da4-9097-9e98403f8249", Allowed = false},
    ["Elemental_Mud"] = {UUID = "3b637556-32cd-4831-ac89-acf726df55c5", Allowed = false},
    ["Ettercap"] = {UUID = "3acbe536-b157-471a-9919-611576da8ff6", Allowed = false},
    ["FleshGolem"] = {UUID = "a20b3cf6-b71f-45f5-af9d-2f9d845d1658", Allowed = false},
    ["FlyingGhoul"] = {UUID = "20c2a23c-07dc-4108-9db7-05d002dd6efc", Allowed = false},
    ["Ghast"] = {UUID = "788a78a7-4b6e-46b7-9d3c-2f8d50c9eef4", Allowed = false},
    ["Ghost"] = {UUID = "c5eb388a-1b23-413e-b8c2-debb885e829e", Allowed = false},
    ["Ghoul"] = {UUID = "cc44199c-b455-44d9-9ac8-55411b8e80c5", Allowed = false},
    ["GiantEagle"] = {UUID = "28e90860-5c47-48eb-997a-593ec2b4a16d", Allowed = false},
    ["GoldDragonborn"] = {UUID = "fe648fc4-3bc9-412c-b692-15fecddc3c69", Allowed = true},
    ["GreenDragonborn"] = {UUID = "d6eadf47-54f7-4b05-84b3-0a83eb88d016", Allowed = true},
    ["Gremishka"] = {UUID = "dc532c8f-cbfd-4513-acc6-922b88d09271", Allowed = false},
    ["Hag"] = {UUID = "e2798930-512f-4205-b87a-05b39b569752", Allowed = false},
    ["Hellsboar"] = {UUID = "94343b04-974d-44bd-bdd5-34de45d1d058", Allowed = false},
    ["Hollyphant"] = {UUID = "433ecc79-eae2-467f-81f8-82eb9cd72c5f", Allowed = false},
    ["Hyena"] = {UUID = "3c7d3cf6-1a23-49ad-9fd0-cd00b1df5276", Allowed = false},
    ["Imp"] = {UUID = "7efb6df1-4f74-4d83-aeba-031b52d003a1", Allowed = false},
    ["Incubus"] = {UUID = "9d44d79f-6db0-49da-90b0-0a1573d91098", Allowed = false},
    ["Meazel"] = {UUID = "00c7ee76-58d0-429c-ae4d-ecc3d653da06", Allowed = false},
    ["Mephit"] = {UUID = "7cfa46e7-b17e-4d08-b8d1-f10e89c06bda", Allowed = false},
    ["Merregon"] = {UUID = "0fff84f9-f614-49a1-81d6-2c9e82eb241e", Allowed = false},
    ["Mummy"] = {UUID = "3c066deb-eaaf-4bbf-b021-61ad0acc51a2", Allowed = false},
    ["Mummy Lord"] = {UUID = "420f8e51-0d5a-46b4-aa94-562fdd510d77", Allowed = false},
    ["OliverFriend"] = {UUID = "651f6a67-e017-4e31-bf32-d7aed0527623", Allowed = false},
    ["Phasm"] = {UUID = "d842d9a5-5f0d-42ab-ab57-89314a1f18ff", Allowed = false},
    ["Raphaelian Merregon"] = {UUID = "309b0bf4-47ec-4c65-925a-5f944d6353c8", Allowed = false},
    ["Raven"] = {UUID = "4973e85f-f3c7-442f-9673-f876b2db54bb", Allowed = false},
    ["RedDragonborn"] = {UUID = "61a2c59d-fe8d-4644-8d04-6fae2b239eaf", Allowed = true},
    ["ShadarKai"] = {UUID = "1881d9c3-5654-491b-868d-14b6af8b79af", Allowed = true},
    ["Shadow"] = {UUID = "9d4c97ce-5b07-4bf6-97fa-2e744032e170", Allowed = false},
    ["ShadowMastiff"] = {UUID = "d3c0ee1f-3cc3-463a-8869-edf646c5bbca", Allowed = false},
    ["Shambling Mound"] = {UUID = "2aea2906-f9bd-427f-aad8-300fb9107c0d", Allowed = false},
    ["SilverDragonborn"] = {UUID = "dff74c31-2ddc-4270-9615-01a1438ee61c", Allowed = true},
    ["Succubus"] = {UUID = "7631ede0-25d5-4d96-9425-3d0ebd536ea5", Allowed = true},
    ["Tressym"] = {UUID = "d5876240-2072-4a51-894b-c53e0866f8d4", Allowed = false},
    ["Trips_Fallen"] = {UUID = "f40da0bb-58e0-4b53-8ec5-805bc1533c8c", Allowed = true},
    ["Trips_Fallen_Hireling"] = {UUID = "519820ce-d715-42ee-885c-f35feb3f7183", Allowed = true},
    ["Trips_Harbinger"] = {UUID = "449f93dd-817f-4870-be6d-fbdb8f0dfb1d", Allowed = true},
    ["Trips_Harbinger_Hireling"] = {UUID = "f3104835-8e41-485c-95f8-9035aca64eb1", Allowed = true},
    ["Trips_Protector"] = {UUID = "dd21fb84-2d6a-4d7d-a418-ca96991d3920", Allowed = true},
    ["Trips_Protector_Hireling"] = {UUID = "eef353ed-870d-4ac1-8610-4bb0682c6c60", Allowed = true},
    ["Trips_Scourge"] = {UUID = "4738a422-5abd-41a7-a3f8-a35250a73209", Allowed = true},
    ["Trips_Scourge_Hireling"] = {UUID = "309b9cc5-0156-4f64-b857-8cf83fa2160b", Allowed = true},
    ["UndeadFace"] = {UUID = "276f2e3b-ce11-4f0f-bfeb-1fb3709c3617", Allowed = false},
    ["Vampire"] = {UUID = "b615c4e0-2157-4878-ab4c-cdacc679a87b", Allowed = true},
    ["VampireSpawn"] = {UUID = "dbb041de-231c-4dc9-9a25-91c81b45976e", Allowed = true},
    ["Vengeful Boar"] = {UUID = "a8745b42-88cc-4eaf-ba0f-8a4b0ba5fa8e", Allowed = false},
    ["Vengeful Cambion"] = {UUID = "f8767477-8708-4493-8902-c5ac84a2e40b", Allowed = true},
    ["Vengeful Imp"] = {UUID = "bd6cb035-8e37-475c-bea6-cca889ffb9d3", Allowed = false},
    ["Werewolf"] = {UUID = "faaaf3f6-4f9e-4042-92bf-a0645dcac232", Allowed = false},
    ["WhiteDragonborn"] = {UUID = "cbe10ab9-11a6-450e-844a-175bcca25de7", Allowed = true},
    ["Wolf"] = {UUID = "63d47507-0398-4ef2-a217-66098b633e72", Allowed = false},
    ["Wraith"] = {UUID = "90fb2456-c6c9-40b8-9753-e4d9bc7d7165", Allowed = false},
    ["Zombie"] = {UUID = "56b3ae88-2b72-4838-9f3b-00929aeae6e1", Allowed = false},
    ["|Raven|"] = {UUID = "40a08350-5795-44d9-a19f-b7c9ce4a70cb", Allowed = false},
    --#endregion
}

Data.UnimportantTags = {
    "00000000-0000-0000-0000-000000000000", -- EMPTY
    "eae44d86-3321-4a0a-811d-4fd8e48b5723", -- VO_POSTPROCESS
    "d2f86ec3-c41f-47e1-8acd-984872a4d7d5", -- RARE
    "d631a9b5-a1f1-4cc8-2583-567e828f69d0", -- Int Modifier
    "f7e010d8-17ec-4539-229d-fff17036654e", -- Cha Modifier
    "3b8a887d-7a26-426a-e697-97ec7e3f4d74", -- Wis Modifier
}

Data.ModdedTags = {}

Data.WhitelistedEntities = {
    -- Origins
    "3ed74f06-3c60-42dc-83f6-f034cb47c679", -- ShadowHeart
    "c7c13742-bacd-460a-8f65-f864fe41f255", -- Astarion
    "ad9af97d-75da-406a-ae13-7071c563f604", -- Gale
    "58a69333-40bf-8358-1d17-fff240d7fb12", -- Laezel
    "c774d764-4a17-48dc-b470-32ace9ce447d", -- Wyll
    "2c76687d-93a2-477b-8b18-8a14b549304c", -- Karlach
    "7628bc0e-52b8-42a7-856a-13a6fd413323", -- Halsin
    "25721313-0c15-4935-8176-9f134385451b", -- Minthara
    "91b6b200-7d00-4d62-8dc9-99e8339dfa1a", -- Jaheira
    "0de603c5-42e2-4811-9dad-f652de080eba", -- Minsc
    -- NPC's
    "bc4b5efc-cbd3-4f8f-a31e-d37f801a038c", -- Ketheric
    "bf24e0ec-a3a6-4905-bd2d-45dc8edf8101", -- Orin
    "491a7686-3081-405b-983c-289ec8781e0a", -- Mizora
    "6c55edb0-901b-4ba4-b9e8-3475a8392d9b", -- Dame Aylin
    "2f1880e6-1297-4ca3-a79c-9fabc7f179d3", -- Cazador
    "f65becd6-5cd7-4c88-b85e-6dd06b60f7b8", -- Raphael
    "25498064-744e-479c-809f-f36ecd5eb264", -- Haarlep
    "14ac9a0f-02ab-422f-b848-069c717d4203", -- Haarlep (F)
}

-- Table to add specific entity UUID's to, to disallow interactions
-- Anyone can add specific entities to it via:
-- table.insert(Mods.BG3SX.Data.BlacklistedEntities, "An Entity UUID")
Data.BlacklistedEntities = {
    "58a69333-40bf-8358-1d17-fff240d7fb11", -- "Placeholder" - Doesn't exist
    "3ed74f06-3c60-42dc-83f6-f034cb47c671", -- "Placeholder" - Doesn't exist
}


-- WHITE-/BLACKLIST CHECK
-- Use !whitelist or !blacklist to check against HostCharacter
--------------------------------------------------------------

--- Checks if an entity's UUID is whitelisted.
--- Returns true if whitelisted, and false if the UUID isn't listed.
--- @param uuid any - The UUID of the entity to check.
--- @return boolean|string - Returns true for whitelisted entities, false if it is not listed.
function Entity:IsWhitelistedEntity(uuid)
    for _, whitelistedUUID in ipairs(Data.WhitelistedEntities) do
        if whitelistedUUID == uuid then
            return true -- The UUID is whitelisted
        end
    end
    return false -- The UUID is not whitelisted
end

--- Checks if an entity's UUID is blacklisted.
--- Returns false if the UUID is explicitly allowed, true if blacklisted, and false if the UUID isn't listed.
--- @param uuid any - The UUID of the entity to check.
--- @return boolean|string - Returns true for blacklisted entities, false if it is not listed.
function Entity:IsBlacklistedEntity(uuid)
    for _, blacklistedUUID in ipairs(Data.BlacklistedEntities) do
        if blacklistedUUID == uuid then
            return true -- The UUID is blacklisted
        end
    end
    return false -- The UUID is not blackliste
end

--- Gathers and returns the appropriate tag information for a given tag from modded tags.
--- Prioritizes disallowed tags, and if found, returns false immediately.
--- @param tagData table - The tag data table containing Name and UUID fields.
--- @return table|string|boolean, string|nil, string|nil - Returns the tag info, "No Match, use Vanilla", or false and the mod name if disallowed.
local function getModdedTagsInfo(tagData)
    local matchedTagInfo = nil
    if Data.ModdedTags and next(Data.ModdedTags) then
        for modUUID, modTags in pairs(Data.ModdedTags) do
            local modName = Ext.Mod.GetMod(modUUID).Info.Name
            local moddedTagInfo = modTags[tagData.Name]
            if moddedTagInfo and moddedTagInfo.TAG == tagData.ResourceUUID then
                if moddedTagInfo.Allowed == false then
                    return false, modName, moddedTagInfo.Reason -- Disallowed tag found, return false and which mod it checked
                elseif moddedTagInfo.Allowed == true then
                    matchedTagInfo = moddedTagInfo -- Store tagInfo
                end
            end
        end
    end
    if matchedTagInfo then
        return matchedTagInfo -- If it found any matches, returns the tagInfo
    else
        return "No Match, use Vanilla" -- Return that we shall use vanilla tags instead
    end
end

-- Checks if an entity is part of our whitelisted tags/races table
---@param uuid string - UUID of an entity
function Entity:IsWhitelistedTagOrRace(uuid)
    local tags = Entity:TryGetEntityValue(uuid, nil, {"ServerRaceTag", "Tags"})
    local hasAllowedTag = false

    local function checkParentTags(raceUUID) -- Helper function to recursively check race parent tags
        local raceData = Ext.StaticData.Get(raceUUID, "Race")
        if raceData and raceData.ParentGuid then
            for _, parentUUID in ipairs(raceData.ParentGuid) do
                local parentData = Ext.StaticData.Get(parentUUID, "Race")
                if parentData then
                    for _, parentTag in ipairs(parentData.Tags) do
                        local tagInfo = Data.AllowedTagsAndRaces[parentTag]
                        if tagInfo and tagInfo.Allowed == false then
                            local msg = "BG3SX][Whitelist.lua]\nCheck failed on:\n" .. uuid .. "\nFound disallowed tag in parent:\n" .. parentTag .. "\nwith UUID:\n" .. parentUUID
                            _P(msg)
                            Osi.OpenMessageBox(uuid, msg)
                            return false
                        elseif tagInfo and tagInfo.Allowed == true then
                            hasAllowedTag = true
                        end
                    end
                    local parentAllowed = checkParentTags(parentUUID)
                    if not parentAllowed then
                        return false
                    end
                end
            end
        end
        return true
    end

    for i,tag in ipairs(tags) do
        local skip = false
        for _,unimportantTag in pairs(Data.UnimportantTags) do
            if tag == unimportantTag then
                skip = true
            end
        end 
        if skip == false then
            local tagData = Ext.StaticData.Get(tag, "Tag")
            if tagData then
                local tagInfo = Data.AllowedTagsAndRaces[tagData.Name]

                -- Use the getModdedTagsInfo function to check for overrides
                local returnValue, mod, reason = getModdedTagsInfo(tagData)
                if returnValue == false then
                    if mod then
                        local msg = "[BG3SX][Whitelist.lua]\nCheck failed on:\n" .. uuid .. "\nDuring Check on Mod: " .. mod .. "\nDisallowed modded tag found: " .. tagData.Name .. " with UUID:\n" .. tag .. "\nContact the race author or BG3SX author."
                        if reason then
                            msg = msg .. "\nReason: " .. reason
                        else
                            msg = msg .. "\nReason: Deliberate by race author or no animation support."
                        end
                        _P(msg)
                        Osi.OpenMessageBox(uuid, msg)
                        return false
                    end
                elseif returnValue == "No Match, use Vanilla" then
                    -- Do nothing, use the regular vanilla tagInfo
                elseif returnValue ~= nil then
                    tagInfo = returnValue
                end

                if tagInfo then
                    if tagInfo.Allowed == false then
                        local msg = "[BG3SX][Whitelist.lua]\nCheck failed on:\n" .. uuid .. "\nDisallowed tag found: " .. tagData.Name .. " with UUID:\n" .. tag
                        _P(msg)
                        Osi.OpenMessageBox(uuid, msg)
                        return false
                    elseif tagInfo.Allowed == true then
                        hasAllowedTag = true
                        if tagInfo.racesUsingTag then
                            for _, race in pairs(tagInfo.racesUsingTag) do
                                local raceAllowed = checkParentTags(race.RACE)
                                if not raceAllowed then
                                    local msg = "[BG3SX][Whitelist.lua]\nCheck failed on:\n" .. uuid .. "\nDisallowed race found: " .. race.Name
                                    _P(msg)
                                    Osi.OpenMessageBox(uuid, msg)
                                    return false
                                end
                            end
                        end
                    end
                else
                    local msg = "[BG3SX][Whitelist.lua]\nCheck failed on:\n" .. uuid .. "\nUnknown Tag UUID - Name: " .. tagData.Name ..  " with UUID:\n" .. tag
                    _P(msg)
                    Osi.OpenMessageBox(uuid, msg)
                    return false
                end
            else
                local msg = "[BG3SX][Whitelist.lua]\nCheck failed on:\n" .. uuid .. "\nUnknown Tag UUID:\n" .. tag
                _P(msg)
                Osi.OpenMessageBox(uuid, msg)
                return false
            end
        end
    end

    if hasAllowedTag then
        return true
    else
        local msg = "[BG3SX][Whitelist.lua]\n No allowed tags found. Entity is not allowed."
        _P(msg)
        Osi.OpenMessageBox(uuid, msg)
        return false
    end
end


--- Checks if an entity is allowed based on its UUID and current settings of Data.WhitelistedEntities, Data.BlacklistedEntities and Data.AllowedTagsAndRaces.
--- @param uuid any - The UUID of the entity to check.
--- @return boolean - Returns true if the entity is allowed, false otherwise.
function Entity:IsWhitelisted(uuid)
    if Entity:IsPlayable(uuid) or Entity.IsNPC(uuid) then
        if Entity:IsWhitelistedEntity(uuid) then -- If true it is allowed - return true
            return true
        end
        if Entity:IsBlacklistedEntity(uuid) then -- If true it is NOT allowed - return false
            return false -- Entity not allowed
        else -- Entity not found in the entity-specific white/blacklist, check Race/Tags whitelist now
            if Entity:IsWhitelistedTagOrRace(uuid) then
                return true -- Entity allowed by race/tags
            else
                return false -- Entity not allowed by race/tags
            end
        end
    end
end

--------------------------------------------------------------
-- HELPER FUNCTIONS TO GET ALL CURRENTLY LOADED TAGS/Races
-- Use !tagsandraces as concole command
--------------------------------------------------------------

-- Table to store tags with their UUIDs and associated races
local allowedTags = {}
-- Table to store all races and their UUIDs if they don't have a tag on their own
local racesWithoutOwnTags = {}
-- Recursive function to collect tags from parent races
local function collectParentTags(raceData, collectedTags)
    if not raceData.ParentGuid or raceData.ParentGuid == "" then
        return collectedTags
    end
    local parentRaceData = Ext.StaticData.Get(raceData.ParentGuid, "Race")
    if not parentRaceData then
        _P("No parent data found for GUID: " .. raceData.ParentGuid)
        return collectedTags
    end
    _P("Checking parent: " .. parentRaceData.Name .. " (UUID: " .. parentRaceData.ResourceUUID .. ")")
    for _, tag in pairs(parentRaceData.Tags) do
        local tagData = Ext.StaticData.Get(tag, "Tag")
        if tagData then
            -- _P("Found tag: " .. tagData.Name .. " (UUID: " .. tagData.ResourceUUID .. ") in parent race: " .. parentRaceData.Name)
            table.insert(collectedTags, tag)
        else
            _P("Tag not found for UUID: " .. tag)
        end
    end
    return collectParentTags(parentRaceData, collectedTags)
end
local function getAllTagsAndRaces()
    -- Iterate through all races
    local allRacesData = Ext.StaticData.GetAll("Race")
    for _, race in pairs(allRacesData) do
        _P("------------------------------------------------------------------------------")
        local raceData = Ext.StaticData.Get(race, "Race")
        _P("Race Name: " .. raceData.Name)
        _P("Race UUID: " .. raceData.ResourceUUID)
        local collectedTags = {}

        -- Collect tags from this race
        if #raceData.Tags > 0 then
            _P("--------------------------")
            _P("Race has tags:")
            for _, tag in pairs(raceData.Tags) do
                local tagEntry = Ext.StaticData.Get(tag, "Tag")
                if tagEntry then
                    _P("    Tag: " .. tagEntry.Name .. " (UUID: " .. tagEntry.ResourceUUID .. ")")
                    -- Initialize tag entry if not already present
                    if not allowedTags[tagEntry.Name] then
                        allowedTags[tagEntry.Name] = {uuid = tagEntry.ResourceUUID, allowed = nil, races = {}}
                    end
                    -- Add the race to the tag's races list
                    table.insert(allowedTags[tagEntry.Name].races, {Name = raceData.Name, UUID = raceData.ResourceUUID, Allowed = nil})
                else
                    _P("Tag not found for UUID: " .. tag)
                end
            end
        else
            -- Collect tags from parent races if no tags in this race
            _P("Race has no direct tags. Collecting tags from parent races...")
            collectedTags = collectParentTags(raceData, {})
            if #collectedTags > 0 then
                _P("--------------------------")
                _P("Tags inherited from parent races:")
                for _, tag in pairs(collectedTags) do
                    local tagEntry = Ext.StaticData.Get(tag, "Tag")
                    if tagEntry then
                        _P("    Inherited tag: " .. tagEntry.Name .. " (UUID: " .. tagEntry.ResourceUUID .. ")")
                        -- Initialize tag entry if not already present
                        if not allowedTags[tagEntry.Name] then
                            allowedTags[tagEntry.Name] = {uuid = tagEntry.ResourceUUID, allowed = nil, races = {}}
                        end
                        -- Add the race to the tag's races list
                        table.insert(allowedTags[tagEntry.Name].races, {Name = raceData.Name, UUID = raceData.ResourceUUID, Allowed = nil})
                    else
                        _P("Tag not found for UUID: " .. tag)
                    end
                end
                -- Track races that don't have their own tags but have parent tags
                racesWithoutOwnTags[raceData.Name] = raceData.ResourceUUID
            else
                _P("No tags found in parent hierarchy for race: " .. raceData.Name)
                -- Add the race if no tags and no parent tags
                if not allowedTags[raceData.Name] then
                    allowedTags[raceData.Name] = {uuid = raceData.ResourceUUID, allowed = nil, races = {}}
                end
            end
        end
    end

    -- Convert allowedTags to a list and sort it
    local sortedTags = {}
    for tagName, tagInfo in pairs(allowedTags) do
        table.insert(sortedTags, {Name = tagName, Data = tagInfo})
    end
    table.sort(sortedTags, function(a, b) return a.Name < b.Name end)

    -- Convert racesWithoutOwnTags to a list and sort it
    local sortedRacesWithoutOwnTags = {}
    for raceName, raceUUID in pairs(racesWithoutOwnTags) do
        table.insert(sortedRacesWithoutOwnTags, {Name = raceName, UUID = raceUUID})
    end
    table.sort(sortedRacesWithoutOwnTags, function(a, b) return a.Name < b.Name end)

    -- Print the allowed tags in the required format
    _P("Data.AllowedTags = {")
    _P("    ------------------------------------TAGS------------------------------------")
    for _, tag in ipairs(sortedTags) do
        -- Skip the "VO_POSTPROCESS" tag
        if tag.Name ~= "VO_POSTPROCESS" then
            _P(string.format('    ["%s"] = {TAG = "%s", Allowed = %s,\n        racesUsingTag = {', tag.Name, tag.Data.uuid, tostring(tag.Data.allowed)))
            for _, race in ipairs(tag.Data.races) do
                _P(string.format('        {Name = "%s", RACE = "%s", Allowed = nil},', race.Name, race.UUID))
            end
            _P("        },")
            _P("    },")
        end
    end
    -- Print the races that do not have a tag of their own but have parent tags
    _P("    ----------------------------Races without their own tags--------------------------")
    for _, race in ipairs(sortedRacesWithoutOwnTags) do
        _P(string.format('    ["%s"] = {UUID = "%s", Allowed = nil},', race.Name, race.UUID))
    end
    _P("}")
end


-- Custom Console Commands For Debugging
--------------------------------------------------------------
local function tagsandraces()
    getAllTagsAndRaces()
end
Ext.RegisterConsoleCommand("tagsandraces", tagsandraces);
local function racewhitelist()
    Entity:IsWhitelistedTagOrRace(Osi.GetHostCharacter())
end
Ext.RegisterConsoleCommand("racewhitelist", racewhitelist);
local function blacklist()
    Entity:IsBlacklistedEntity(Osi.GetHostCharacter())
end
Ext.RegisterConsoleCommand("blacklist", blacklist);
local function whitelist()
    Entity:IsWhitelisted(Osi.GetHostCharacter())
end
Ext.RegisterConsoleCommand("whitelist", whitelist);