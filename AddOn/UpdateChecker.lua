local HttpService = cloneref(game:GetService("HttpService"))

local UpdateChecker = {}

function UpdateChecker.Check(Repo, Path, UpdateLabel)
    if typeof(UpdateLabel) ~= "Instance" or not UpdateLabel:IsA("TextLabel") then
        return
    end

    local Url = ("https://api.github.com/repos/%s/commits?path=%s&page=1&per_page=1"):format(Repo, Path)

    local Success, Response = pcall(function()
        return game:HttpGet(Url)
    end)

    if not Success or not Response then
        UpdateLabel.Text = "GitHub Request Failed."
        return
    end

    local ParseSuccess, Data = pcall(function()
        return HttpService:JSONDecode(Response)
    end)

    if not ParseSuccess or type(Data) ~= "table" or #Data == 0 then
        UpdateLabel.Text = "Failed to Read Commit Info."
        return
    end

    local IsoDate = Data[1].commit.committer.date
    local Year, Month, Day, Hour, Min, Sec = IsoDate:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")

    if not (Year and Month and Day and Hour and Min and Sec) then
        UpdateLabel.Text = "Invalid Commit Date Format."
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

    local SecondsAgo = os.difftime(os.time(), LocalTime)

    local AgoText = ""

    if SecondsAgo < 60 then
        AgoText = SecondsAgo .. " Seconds Ago"
    elseif SecondsAgo < 3600 then
        AgoText = math.floor(SecondsAgo / 60) .. " Minutes Ago"
    elseif SecondsAgo < 86400 then
        AgoText = math.floor(SecondsAgo / 3600) .. " Hours Ago"
    else
        AgoText = math.floor(SecondsAgo / 86400) .. " Days Ago"
    end

    local T = os.date("*t", LocalTime)
    local AmPm = T.hour >= 12 and "PM" or "AM"
    local Hour12 = T.hour % 12
  
    if Hour12 == 0 then 
        Hour12 = 12 
    end

    local TimeDate = string.format("%d:%02d%s %s %d, %d",
        Hour12, T.min, AmPm, os.date("%B", LocalTime), T.day, T.year
    )

    UpdateLabel.Text = AgoText .. "\n" .. TimeDate
end

return UpdateChecker
