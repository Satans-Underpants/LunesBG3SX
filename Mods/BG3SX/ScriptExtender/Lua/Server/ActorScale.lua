Companions = {
    Astarion = "5614c25e-0213-479f-864c-e95895adb30f",
    Shadowheart = "2ac51f22-e357-4639-b81d-022d462c8c6a",
    Gale = "7d427a86-81f0-418d-a32a-3b5676c86bfa",
    Karlach = "3ab0a797-0904-47cb-955d-cdc3ec32409c",
    Wyll = "159cdf9e-6665-4450-9375-8494e233b0e4",
    Laezel = "3a0351bd-0b2f-4fbf-84a6-30ad80bb3100",
    Jaheira =  "7c7e6552-3fc0-4495-bb11-4b9f9a8e71fc",
    Minthara = "",
    Halsin = "1a3d9848-f86e-4f4c-bba5-125ab605c69e"
}

BodyTypes = {
    HumanFemale = "71180b76-5752-4a97-b71f-911a69197f58",
    HumanMale = "7d73f501-f65e-46af-a13b-2cacf3985d05",
    HumanStrongFemale = "47c0315c-7dc6-4862-b39b-8bf3a10f8b54",
    HumanStrongMale = "e39505f7-f576-4e70-a99e-8e29cd381a11",
    TieflingFemale = "cf421f4e-107b-4ae6-86aa-090419c624a5",
    TieflingMale = "6503c830-9200-409a-bd26-895738587a4a",
    TieflingStrongMale = "f625476d-29ec-4a6d-9086-42209af0cf6f",
    TieflingStrongFemale = "a5789cd3-ecd6-411b-a53a-368b659bc04a",
    TieflingKarlach = "6326d417-315c-4605-964e-d0fad73d719b",
    GithyankiFemale = "06aaae02-bb9e-4fa3-ac00-b08e13a5b0fa",
    GithyankiMale = "f07faafa-0c6f-4f79-a049-70e96b23d51b",
    ElfMale = "7dd0aa66-5177-4f65-b7d7-187c02531b0b",
    ElfFemale = "ad21d837-2db5-4e46-8393-7d875dd71287",
    HalfElfFemale = "541473b3-0bf3-4e68-b1ab-d85894d96d3e",
    HalfElfMale = "a0737289-ca84-4fde-bd52-25bae4fe8dea",
    DwarfFemale = "b4a34ce7-41be-44d9-8486-938fe1472149",
    DwarfMale = "abf674d2-2ea4-4a74-ade0-125429f69f83",
    HalflingFemale = "8f00cf38-4588-433a-8175-8acdbbf33f33",
    HalflingMale = "a933e2a8-aee1-4ecb-80d2-8f47b706f024",
    GnomeFemale = "c491d027-4332-4fda-948f-4a3df6772baa",
    GnomeMale = "5640e766-aa53-428d-815b-6a0b4ef95aca",
    DragonbornFemale = "6d38f246-15cb-48b5-9b85-378016a7a78e",
    DragonbornMale = "9a8bbeba-850c-402f-bac5-ff15696e6497",
    HalforcFemale = "eb81b1de-985e-4e3a-8573-5717dc1fa15c",
    HalforcMale = "6dd3db4f-e2db-4097-b82e-12f379f94c2e",
}

ActorHeights = {
    HumanStrongFemale = "Tall",
    HumanStrongMale = "Tall",
    TieflingStrongMale = "Tall",
    TieflingStrongFemale = "Tall",
    TieflingKarlach = "Tall",
    DragonbornFemale = "Tall",
    DragonbornMale = "Tall",
    HalforcFemale = "Tall",
    HalforcMale = "Tall",
    HumanFemale = "Med",
    HumanMale = "Med",
    TieflingFemale = "Med",
    TieflingMale = "Med",
    GithyankiFemale = "Med",
    GithyankiMale = "Med",
    ElfMale = "Med",
    ElfFemale = "Med",
    HalfElfFemale = "Med",
    HalfElfMale = "Med",
    DwarfFemale = "Short",
    DwarfMale = "Short",
    HalflingFemale = "Short",
    HalflingMale = "Short",
    GnomeFemale = "Short",
    GnomeMale = "Short",
}


function ActorScale_GetBodyType(actor)
    local actorEntity = Ext.Entity.Get(actor)
    local equipmentRace = (actorEntity.ServerCharacter.Template.EquipmentRace)
    for bodyType, bodyID in pairs(BodyTypes) do
        if bodyID == equipmentRace then
            return bodyType
        end
    end
    -- _P("[ActorScale.lua] Failed BodyType check on actor: ", actor)
    return BodyTypes['HumanMale']
end

function ActorScale_GetHeightClass(actorBody)
    for body, height in pairs(ActorHeights) do
        if body == actorBody then
            return height
        end
    end
    -- _P("[ActorScale.lua] Failed Height check on actor: ", actorBody)
    return "Med"
end