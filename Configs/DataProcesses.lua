local PREPROCESS = {
	"Audio",
}

local DataProcessors = {}

do
    for _, name in pairs(PREPROCESS) do
        local path = string.format("Configs.Preprocesses.%sProcessor", name)
        DataProcessors[name] = require(path)
    end
end

return DataProcessors