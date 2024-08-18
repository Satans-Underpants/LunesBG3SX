-- TODO: Clean these up, maybe rename some entries to make more sense, remove unused ones

-- Additional data thats included when using a spell equal to AnimName
-- Seperated from the other table because these 2 are the start spells which are handled differently and will create a scene
STARTSEXSPELLS = {
    {
        AnimName = "BG3SX_StartMasturbating",  -- Should always be the same as a spells name
        AnimLength = 3600, -- AnimLength determines
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        Strip = true,
        FallbackTopAnimationID = "49497bdc-d901-4f60-9e4e-3d31a06f9002",
        FallbackBottomAnimationID = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
        Med_Female = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
        Med_Male = "49497bdc-d901-4f60-9e4e-3d31a06f9002",
        Tall_Female = "2c60a233-b669-4b94-81dc-280e98238fd0",
    },
    {
        AnimName = "BG3SX_AskForSex",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = false,
        SoundTop = {"Instrument_Bard_Silence","Instrument_Bard_Silence"},
        SoundBottom = {"Instrument_Bard_Silence","Instrument_Bard_Silence"},
        Strip = true,
        FallbackTopAnimationID = "49d78660-5175-4ed2-9853-840bb58cf34a",
        FallbackBottomAnimationID = "10fee5b7-d674-436c-994c-616e01efcb90",
        MedTop_MedBtm = {
            Btm = "10fee5b7-d674-436c-994c-616e01efcb90",
            Top = "49d78660-5175-4ed2-9853-840bb58cf34a",
        },
        TallTop_MedBtm = {
            Btm = "392073ca-c6e0-4f7d-848b-ffb0b510500b",
            Top = "04922882-0a2d-4945-8790-cef50276373d",
        },
    },
}

-- Additional data thats included when using a spell equal to AnimName
ANIMATIONS = {
    {
        AnimName = "BG3SX_Grinding",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "0114c60d-0f82-4827-ae11-9e3c46f7d7b5",
        FallbackBottomAnimationID = "8b9b1bb2-842b-422c-90ff-efbbe84835aa"
    },
    {
        AnimName = "BG3SX_EatPussy",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Kissing,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "5fa5cbe4-1baf-4529-b448-2c53e163626c",
        FallbackBottomAnimationID = "f801ec0d-9fee-4584-bae3-96d7c3e285ff"
    },
    {
        AnimName = "BG3SX_FingerFuck",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Kissing,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "adf1b790-da1d-4aaf-9ac4-83157c52d5c2",
        FallbackBottomAnimationID = "a79232a2-a498-4689-a5bd-8923e80284d2"
    },
    {
        AnimName = "BG3SX_Blowjob",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Kissing,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "536f0403-c401-4223-bbca-6b807494a527",
        FallbackBottomAnimationID = "b3984708-7664-49ae-b96d-0512497ea036"
    },
    {
        AnimName = "BG3SX_Missionary",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "905be226-3edc-4783-9d4e-45d2b57a3d0a",
        FallbackBottomAnimationID = "48a255e9-02ec-4541-b1b7-32275da29206"
    },
    {
        AnimName = "BG3SX_Doggy",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "b8f04918-c5b6-4c4a-aee5-390bfaff33bc",
        FallbackBottomAnimationID = "ffdd67e7-7363-46a4-92e2-38260ef0a2e0"
    },
    {
        AnimName = "BG3SX_Cowgirl",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "ff7a5a30-b661-4192-bd8f-118373e3f4b8",
        FallbackBottomAnimationID = "1b220386-55fa-4d2b-8da4-0e7bf453d928"
    },
    {
        AnimName = "BG3SX_MasturbateStanding",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        SoundBottom = Data.Sounds.Kissing,
        FallbackTopAnimationID = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
        FallbackBottomAnimationID = "9d8c5992-55ab-4c2f-8d97-28b68eb50a8b",
        Tall_Female = "2c60a233-b669-4b94-81dc-280e98238fd0",
    },
    {
        AnimName = "BG3SX_Milking",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        SoundBottom = Data.Sounds.Kissing,
        FallbackTopAnimationID = "a71ace41-41ce-4876-8f14-4f419b677533",
        FallbackBottomAnimationID = "d2a17851-b51b-4e4f-be1d-30dc86b6466a"
    },
    {
        AnimName = "BG3SX_Wanking",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Kissing,
        SoundBottom = Data.Sounds.Kissing,
        FallbackTopAnimationID = "49497bdc-d901-4f60-9e4e-3d31a06f9002",
        FallbackBottomAnimationID = "49497bdc-d901-4f60-9e4e-3d31a06f9002"
    },
    {
        AnimName = "BG3SX_BottleSit",
        AnimLength = 3600,
        Loop = true,
        Fade = true,
        Sound = true,
        SoundTop = Data.Sounds.Moaning,
        SoundBottom = Data.Sounds.Moaning,
        FallbackTopAnimationID = "d0f6cf4a-a418-4640-bf36-87531d55154b",
        FallbackBottomAnimationID = "d0f6cf4a-a418-4640-bf36-87531d55154b",
        Props = {
        "0f2ccca6-3ce8-4271-aec0-820f6581c551", -- Bottle
        }    
    },

}