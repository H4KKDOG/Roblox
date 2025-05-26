local HttpService = cloneref(game:GetService("HttpService"))

local UpdateChecker = {}
local CacheFileName = "Cooked/update/CheckerCache.json"

local function ReadCache()
    if isfile and isfile(CacheFileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CacheFileName))
        end)
        
        if success and type(data) == "table" then
            return data
        end
    end
    
    return {}
end

local function WriteCache(data)
    if writefile then
        pcall(function() writefile(CacheFileName, HttpService:JSONEncode(data)) end)
    end
end

local function MakeKey(Repo, Path)
    return Repo .. ":" .. Path
end

function UpdateChecker.Check(Repo, Path, UpdateLabel)
    local Cache = ReadCache()
    local Key = MakeKey(Repo, Path)
    local Entry = Cache[Key]

    local UseCache = false
    
    if Entry and Entry.CommitDate and Entry.Timestamp then
        local CacheAge = os.time() - Entry.Timestamp
        
        if CacheAge < 3600 then
            UseCache = true
        end
    end

    local IsoDate

    if UseCache then
        IsoDate = Entry.CommitDate
    else
        local Url = ("https://api.github.com/repos/%s/commits?path=%s&page=1&per_page=1"):format(Repo, Path)
        
        local Success, Response = pcall(function()
            return game:HttpGet(Url)
        end)
        
        if not Success or not Response then
            UpdateLabel:SetText("GitHub Request Failed.")
            return
        end
        
        local ParseSuccess, Data = pcall(function()
            return HttpService:JSONDecode(Response)
        end)
        
        if not ParseSuccess or type(Data) ~= "table" or #Data == 0 then
            UpdateLabel:SetText("Failed to Read Commit Info.")
            return
        end
        
        IsoDate = Data[1].commit.committer.date
        
        Cache[Key] = {
            CommitDate = IsoDate,
            Timestamp = os.time()
        }
        
        WriteCache(Cache)
    end

    local Year, Month, Day, Hour, Min, Sec = IsoDate:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
    
    if not (Year and Month and Day and Hour and Min and Sec) then
        UpdateLabel:SetText("Invalid Commit Date Format.")
        return
    end

    local CommitUtc = os.time({
        year = tonumber(Year),
        month = tonumber(Month),
        day = tonumber(Day),
        hour = tonumber(Hour),
        min = tonumber(Min),
        sec = tonumber(Sec)
    })

    local UtcNow = os.time(os.date("!*t"))
    local LocalNow = os.time()
    local Offset = os.difftime(LocalNow, UtcNow)
    local LocalTime = CommitUtc + Offset

    local T = os.date("*t", LocalTime)
    local AmPm = T.hour >= 12 and " PM" or " AM"
    local Hour12 = T.hour % 12
    
    if Hour12 == 0 then
        Hour12 = 12
    end

    local TimeDate = string.format("%d:%02d%s / %s %d, %d",
        Hour12, T.min, AmPm, os.date("%B", LocalTime), T.day, T.year
    )

    UpdateLabel:SetText(TimeDate)
end

return UpdateChecker
