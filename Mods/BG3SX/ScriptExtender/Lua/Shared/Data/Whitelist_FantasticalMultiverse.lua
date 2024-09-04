if Ext.Mod.GetMod("128025b9-5168-f4a0-fa19-676f0c244d24") then
    _P("[BG3SX][Adding Fantastical Compendium Compatibility...]")
    Data.ModdedTags["128025b9-5168-f4a0-fa19-676f0c244d24"] = {}
    local wList = Data.ModdedTags["128025b9-5168-f4a0-fa19-676f0c244d24"]
    wList["GOLIATH"] = {TAG = "0e916980-8799-4479-40a8-99e1e0b0560e", Allowed = false,                  Reason = "BG3SX - No fitting genitals"} -- Maybe fix with BodyTypeOverride
    wList["HYUR"] = {TAG = "1db2aa5f-f6dc-4b59-288e-5aa6397e8704", Allowed = false,                     Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["YUANTIPUREBLOOD"] = {TAG = "1ff4bf9e-a8dd-4627-8142-f60b3aa7123e", Allowed = true}           -- Checked
    wList["WILDWOOD_ELEZEN"] = {TAG = "4b2ab048-e88d-4543-9cd3-7a388011e850", Allowed = false,          Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["CREPTHARI"] = {TAG = "5da7b4f9-adbc-489d-63a8-2024239bafa0", Allowed = false,                Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["MALFORMED"] = {TAG = "7c6282a6-b733-44d2-24ae-79a220c8fecc", Allowed = false,                Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["REALLY_AARAKOCRA"] = {TAG = "7e97c590-911f-422a-bdb6-068c137eb2c8", Allowed = false,         Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["GITHZERAI"] = {TAG = "7e020814-e100-430e-159b-84ba2d7d8e18", Allowed = true}                 -- Different UUID from Kaz's Githzerai
    wList["WARRIOR_LANESHI"] = {TAG = "8c12db90-0406-4d3d-8afd-7312be605afb", Allowed = false,          Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["VERDAN"] = {TAG = "8d0cc08c-cc00-4552-a6bb-eceb0291c818", Allowed = false,                   Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["LANESHI"] = {TAG = "17f6f14e-800c-4522-01a8-bf67ecc9e157", Allowed = false,                  Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["GWYDDPALA"] = {TAG = "19e5341a-4563-4922-18ba-22fab54f3d08", Allowed = false,                Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["KALASHTAR"] = {TAG = "33b00ccb-12b0-4928-57a5-37767b8af698", Allowed = true}                 -- Checked
    wList["ROEGADYN"] = {TAG = "041c5e66-4ab0-4e70-3bac-26a01f611cf9", Allowed = false,                 Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["GENASI"] = {TAG = "48d7b679-dffd-4f68-a306-adac19de8acf", Allowed = true}                    -- Checked
    wList["MYSTIC_LANESHI"] = {TAG = "61c2e54a-c7af-430d-b8c3-5b733c25a720", Allowed = false,           Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["KRSNIK"] = {TAG = "73c2180e-31cf-418f-1dbc-c8ce840177c3", Allowed = false,                   Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["HEMONARI"] = {TAG = "81f43a0a-d392-4e25-33b9-f8af43fbdc77", Allowed = false,                 Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["GARLEAN"] = {TAG = "84c62202-169e-488f-f284-4751987f448e", Allowed = false,                  Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["BESTIAL"] = {TAG = "92aae5aa-4595-4f1c-96d2-9e2499d35c6f", Allowed = true}                   -- Subtag of disallowed Bugbear
    wList["DHAMPIR"] = {TAG = "318ac120-0132-42c0-099c-6e7240470e82", Allowed = true}                   -- Checked
    wList["LIZARDFOLK"] = {TAG = "615d115d-6d1d-477c-8b2c-d8e91b8cfe7d", Allowed = false,               Reason = "BG3SX - No fitting genitals"} -- Maybe fix with BodyTypeOverride
    wList["SEAELF"] = {TAG = "637f1487-1c24-46a6-eab2-2142dafc3310", Allowed = true}                    -- Checked
    wList["SHADARKAI"] = {TAG = "816f06a8-f420-4da7-d799-f5244162d537", Allowed = true}                 -- Checked
    wList["DOWNCAST"] = {TAG = "927efa65-3483-4882-0c80-c4ef589a1bfe", Allowed = true}                  -- Checked
    wList["REALLY_BESTIAL"] = {TAG = "1029b3e3-3ff0-4d73-b4ed-79b622cad4f9", Allowed = true}            -- Subtag of disallowed Bugbear
    wList["YUANTI"] = {TAG = "2362ea89-0ffc-4dba-c98d-b88c08d485de", Allowed = true}                    -- Checked
    wList["OGRESH"] = {TAG = "7394ed3e-2562-4f0a-a3b6-090ab471bbcb", Allowed = false,                   Reason = "BG3SX - No fitting genitals"} -- Maybe fix with BodyTypeOverride
    wList["EARTHGENASI"] = {TAG = "25663f65-d315-428b-8b8d-95c6b36c580e", Allowed = true}               -- Checked
    wList["KENDER"] = {TAG = "42776f0d-82bf-4998-36b7-9cd35f16a3eb", Allowed = false,                   Reason = "BG3SX - No Small Races"}
    wList["HEXBLOOD"] = {TAG = "58692beb-49b5-4c03-cca2-77bd5289fa42", Allowed = false,                 Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["FIREGENASI"] = {TAG = "69365f00-7df5-45be-c1ad-5307050e55d1", Allowed = true}                -- Checked
    wList["PALLIDELF"] = {TAG = "205867a6-e1a0-401c-8c84-06ed9e969066", Allowed = false,                Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["CHANGELING"] = {TAG = "432657a8-0144-44f4-fdb1-c2dc41a5b9bc", Allowed = true}                -- Check if different to Trips Changeling
    wList["ELEZEN"] = {TAG = "830183fe-db96-4074-cca8-e6ef39a9592e", Allowed = true}                    -- Checked
    wList["LOCATHAH"] = {TAG = "a586359b-616e-44b9-7e9f-a1f38c6b7a4e", Allowed = false,                 Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["MINOTAUR"] = {TAG = "aa374556-6257-4326-829f-7a9667e6fcb4", Allowed = false,                 Reason = "BG3SX - No Animations/Genitals"}
    wList["TABAXI"] = {TAG = "b83aa083-9544-454e-baef-2cb28f9c151b", Allowed = false,                   Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["TYDELVIAN"] = {TAG = "b91bfc9f-4686-4bd8-4199-ea3f31f10021", Allowed = false,                Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["MOROI"] = {TAG = "b844bba0-464e-4037-9f85-61f101de0e45", Allowed = false,                    Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["AIRGENASI"] = {TAG = "b3609bdd-4fb7-4059-a485-ea08dc4b5f12", Allowed = true}                 -- Checked
    wList["KENKU"] = {TAG = "b7215e01-b86a-4ce1-96e0-4f035afaaeae", Allowed = false,                    Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["REALLY_TABAXI"] = {TAG = "bafc25f8-20b0-4693-a0fe-73967befcf05", Allowed = false,            Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["TORTLE"] = {TAG = "be68063a-83d0-4e3b-8d03-8127888af222", Allowed = false,                   Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["REBORN"] = {TAG = "c11d0e20-291d-4958-60a7-0d0d0980189f", Allowed = true}                    -- Checked
    wList["TRITON"] = {TAG = "c622d782-f676-444a-bb31-9657b0f1415b", Allowed = false,                   Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["MUSHUSSU"] = {TAG = "cf1d18cb-8610-4d4e-5ba3-ca879687863e", Allowed = false,                 Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["VEDALKEN"] = {TAG = "d7e5d8c5-ea85-4e77-4498-4225ced898cd", Allowed = true}                  -- Checked
    wList["DUSKWIGHT_ELEZEN"] = {TAG = "dbd207bc-a7c3-455c-90eb-6f765252e498", Allowed = true}          -- Checked
    wList["BUGBEAR"] = {TAG = "dc18a33a-bdd1-41be-8ad5-e6fca917b54e", Allowed = false,                  Reason = "BG3SX - No fitting genitals"} -- Maybe fix with BodyTypeOverride
    wList["ASTRALELF"] = {TAG = "e9e7eeef-52a9-43c6-bfba-fe92992b83e3", Allowed = true}                 -- Checked
    wList["AARAKOCRA"] = {TAG = "e8193d83-f2bc-4e21-8573-b4e158cc9363", Allowed = false,                Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["ORC"] = {TAG = "ea9c6781-a9cd-41f2-e285-08fbfb6c6351", Allowed = false,                      Reason = "BG3SX - No fitting genitals"} -- Maybe fix with BodyTypeOverride
    wList["REALLY_KENKU"] = {TAG = "ec90a39d-ce0e-4ae1-b74d-0906dfd9a1d2", Allowed = false,             Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["ELADRIN"] = {TAG = "ecd26f59-63fe-4641-2983-7b4851df263f", Allowed = false,                  Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["DREAMERS"] = {TAG = "f2afdb72-b1c1-4d31-dd95-18300f9fb2a5", Allowed = false,                 Reason = "BG3SX - Missed subrace or wasn't available for testing"}
    wList["KOBOLD"] = {TAG = "f68151f2-58ee-42e6-98ad-7d858c4a0f13", Allowed = false,                   Reason = "BG3SX - No fitting genitals"}
    wList["WATERGENASI"] = {TAG = "fc1d1c60-796a-4e66-98b2-8d12a2b18462", Allowed = true}               -- Checked
    wList["FIRBOLG"] = {TAG = "45759dc2-4d7a-4853-af73-50cfd412409b", Allowed = false,                  Reason = "BG3SX - No fitting genitals"} -- Maybe fix with BodyTypeOverride
    wList["CELESTIAL"] = {TAG = "7cba0bd7-b955-4ac9-95ba-79e75978d9ac", Allowed = "true"}               -- Checked
    _P("[BG3SX][Fantastical Compendium should now be compatible]")
end