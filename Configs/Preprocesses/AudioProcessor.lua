local AudioProcessor = {}

local ClipToItem = {}

function AudioProcessor.OnPostprocess(sheet)
    for _, item in pairs(sheet.data) do
		ClipToItem[item.Clip] = item
    end
end

function AudioProcessor.FindByClip(name)
	return ClipToItem[name]
end

return AudioProcessor