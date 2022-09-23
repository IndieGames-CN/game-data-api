# Lua 数据表格访问 API

快捷访问游戏内定义的数据 API 工具。


## 1. 常用接口说明

### 1.1 配置表访问

默认所有数据表格导出后都放置在 Configs/Sheets 里面。

#### 1.1.1 辅助函数

使用配置表数据前，请先引⼊ Configs.DataApi 模块。 辅助函数目前提供了以下 4 种，能满足⼤部分获取数据的情况，如有其他需求，可以自⼰加上。

#### 1.1.2 DataApi.All()

获取某个表格所有数据，例如获取 Level 表格中所有数据：

``` lua
local data = DataApi.Level.All()
```

#### 2.1.3 DataApi.Find(id)

获取表格某个 ID 数据，例如获取 Level 表格中 ID 为 2 的数据：

``` lua
local data = DataApi.Level.Find(2)
```

#### DataApi.FindBy(name, value)

获取属性名为 `name` ，属性值为 `value` 的数据，例如 `Level` 表格中属性所有属性名 `Exp` 为 3 

``` lua
local data = DataApi.Level.FindBy("Exp", 3)
```

#### DataApi.FindByCond(cond)

根据条件获取⼀组数据，`cond` 为 function，如下面获取 `Level` 表格中 `Exp` 为 `200` 或 `Hp` 为 `10` 的值：

``` lua
local data = DataApi.Level.FindByCond(function(item) 
    return item.Exp == 200 or item.Hp == 10 
end)
```


## 2. 全局常量配置访问

全局配置为游戏内可能需要的一些通用配置，其表格格式通常定义如下：

``` lua
return {
	COIN_LIMIT = 300000, -- 金币限制
    MAX_LEVEL = 50, -- 最大等级
}
```

这类表格，为 `模块名 + Consts` 作为常量表格名称，比如 `Configs/Sheets/GlobalConsts.lua` 为一常量配置表，可以通过以下方式直接访问：

``` lua
local coinLimit = DataApi.GlobalConsts.COIN_LIMIT
```


## 3. 预处理器

有时候需要对表格进行二次处理，比如做一些 value 与 key 的映射，可以在 `Config/Preprocesses` 文件夹添加指定表格的预处理器：

- 文件各种为 `表格命` + `Processor`
- 定义 `OnPostprocess` 模块函数进行处理数据
- 定义 API 给外部调用

其中 `Configs/Preprocesses/AudioProcessor.lua` 为处理音效资源表的预处理器示例，可以直接使用 `DataApi.Processor` 获取到预处理器，进行数据访问：

``` lua
local config = DataApi.Audio.Processor.FindByClip("A_Music_Candyland")
```