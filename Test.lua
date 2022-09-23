local DataApi = require "Configs.DataApi"

local audioConfig = DataApi.Audio.Find(101)
assert(audioConfig ~= nil)

local audioConfig2 = DataApi.Audio.FindBy("Clip", "A_Music_Candyland")
assert(audioConfig == audioConfig2[1])

local audioConfig3 = DataApi.Audio.FindByCond(function(item)
    return item.Clip == "A_Music_Candyland"
end)
assert(audioConfig == audioConfig3[1])

local audioConfig4 = DataApi.Audio.Processor.FindByClip("A_Music_Candyland")
assert(audioConfig == audioConfig4)

local allAudioIds = DataApi.Audio.Ids()
assert(#allAudioIds == 2)

local coinLimit = DataApi.GlobalConsts.COIN_LIMIT
assert(coinLimit == 30)