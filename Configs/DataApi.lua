local Processors = require "Configs.DataProcesses"

local DATA_URL = "Configs.Sheets"
local DATA_ID_Name = "Id"

local DataApi = {}
local DataSheets = {}

-- 加载普通表格文件
local function LoadCommon(t)
    local fields = {}
    for i, k in ipairs(t[2]) do
        fields[i] = k
    end

    local ids  = {}
    local data = {}

    for i = 3, #t do -- 数据从第三行开始
        local obj = {}
        local item = t[i]
        for j, field in ipairs(fields) do
            obj[field] = item[j]
        end

        data[obj[DATA_ID_Name]] = obj
        table.insert(ids, item[1])
    end

    return {
        ids = ids,
        data = data
    }
end

-- 加载常量表格
local function LoadConsts(t)
    t.isConstant = true
    return t
end

-- 设置为只读表
local function ReadOnly(t)
    local proxy = {}
    local mt = {
        __index = t,
        __newindex = function(t, k, v)
            error("attempt to update a read-only table", 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

local function LoadSheet(name)
    local sheet
    local sheetPath

    -- 加载配置表
    if name:lower():find("consts") then -- 常量配置表，不用处理
        sheetPath = DATA_URL .. "." .. name
        sheet = LoadConsts(require(sheetPath))
    else
        sheetPath = DATA_URL .. "." .. name .. "Config"
        sheet = LoadCommon(require(sheetPath))
    end
    sheet.__path = sheetPath

    -- 加载预处理器
    local processor = Processors[name]
    if processor then
        processor.OnPostprocess(sheet)
        sheet.__processor = processor
    end

    DataSheets[name] = ReadOnly(sheet)
    return sheet
end

local Sheet = {}
setmetatable(DataApi, {
    __index = function(t, k)
        if Sheet.name ~= k then
            local sheet = DataSheets[k]
            if not sheet then
                sheet = LoadSheet(k)
            end

            Sheet.name = k
            Sheet.meta = sheet
            DataApi.Processor = sheet.__processor
        end

        if Sheet.meta.isConstant then
            return Sheet.meta
        else
            return t
        end
    end
})

-- 获取配置表 ID 列表
-- @return int[]
function DataApi.Ids()
    return Sheet.meta.ids
end

-- 获取配置表所有数据
-- @return Configs[]
function DataApi.All()
    return Sheet.meta.data
end

-- 查找数据表一条数据
-- @param id ID
-- @return Config
function DataApi.Find(id)
    local config = Sheet.meta.data[id]
    if not config then
        error(string.format("Config data not found, table: %s, id: %s", Sheet.meta.__path, id))
    else
        return config
    end
end

-- 根据字段名称、值查找配置
-- @param name 字段名称
-- @param value 字段值
-- @return Config[]
function DataApi.FindBy(name, value)
    local result = {}

    for _, item in pairs(Sheet.meta.data) do
        if item[name] == value then
            table.insert(result, item)
        end
    end

    return result
end

-- 根据条件查找配置表
-- @param cond 条件检查函数
-- @return Config[]
function DataApi.FindByCond(cond)
    local result = {}

    for _, item in pairs(Sheet.meta.data) do
        if cond(item) then
            table.insert(result, item)
        end
    end

    return result
end

-- 重载已有的数据表
function DataApi.Reload(name)
    local sheet = DataSheets[name]
    if not sheet then
        return
    end

    package.loaded[sheet.__path] = nil
    LoadSheet(name)

    if Sheet.name == name then
        Sheet.meta = DataSheets[name]
    end
    
    print(string.format("Reload config: %s", name))
end

function DataApi.ReloadAll()
    for name, sheet in pairs(DataSheets) do
        package.loaded[sheet.__path] = nil
        LoadSheet(name)
        print(string.format("Reload config: %s", name))
    end
end

return DataApi
