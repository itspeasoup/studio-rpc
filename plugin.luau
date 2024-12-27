local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local StudioService = game:GetService("StudioService")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")
local displayname
local apiUrl = "http://localhost:52/change"
local startTimestamp = os.time()
local currentPresence = {}
local function updatePresence(newPresence)
	if not currentPresence or newPresence.state ~= currentPresence.state then
		currentPresence = newPresence
		local postDataJson = HttpService:JSONEncode(newPresence)
		pcall(function()
			HttpService:RequestAsync({
				Url = apiUrl,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
				},
				Body = postDataJson,
			})
		end)
	end
end
local function getGameIcon()
	local url = "https://thumbnails.roproxy.com/v1/games/icons?universeIds="..game.GameId.."&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"
	local encoded = game.HttpService:GetAsync(url)
	return HttpService:JSONDecode(encoded).data[1].imageUrl
end
local function CountLines(str)
	local loc = 1
	loc = (select(2, str:gsub("\n", "")) + 1)
	return loc
end
local errorcount = 0
game["Script Context"].Error:Connect(function()
	errorcount += 1
end)
while task.wait(0.12) do
	local id = StudioService:GetUserId()
	pcall(function()
		displayname = UserService:GetUserInfosByUserIdsAsync({id})[1].DisplayName
	end)
	local success, productInfo = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if success then
		gamename = productInfo.Name
	else
		gamename = game.Name
	end
	local _,icon = pcall(getGameIcon)
	local newState = {
		details = gamename,
		state = "doing literally anything else",
		largeImageKey = icon,
		smallImageKey = "https://i.imgur.com/KtpKh0w.png",
		smallImageText = "studio-rpc by peasoup",
		startTimestamp = startTimestamp,
		buttons = {
			{
				label = displayname.." on roblox",
				url = "https://www.roblox.com/users/"..id.."/profile"
			},
			{
				label = "studio-rpc on github",
				url = "https://github.com/itspeasoup/studio-rpc"
			}
		}
	}
	if RunService:IsRunning() then
		newState.state = "playtesting ("..errorcount.." errors)"
		--newState.largeImageKey = "https://i.imgur.com/8wUQIAO.png"
	elseif StudioService.ActiveScript then
		local scrp = StudioService.ActiveScript
		newState.state = tostring("editing \""..scrp.Name.."\" ("..CountLines(scrp.Source)).." lines)"
		newState.largeImageKey = "https://i.imgur.com/jDSTjKj.png"
		pcall(function()
			if scrp:IsA("LocalScript") or scrp.RunContext == Enum.RunContext.Client then
				newState.largeImageKey = "https://i.imgur.com/vF210PL.png"
			elseif scrp:IsA("ModuleScript") then
				newState.largeImageKey = "https://i.imgur.com/1ecIMVc.png"
			end
		end)
	else
		newState.state = "doing literally anything else - "..#workspace:GetDescendants().." instances in workspace"
		--newState.largeImageKey = "https://i.imgur.com/Fv90gxx.png"
		pcall(function()
			if game.Selection:Get() then
				if #game.Selection:Get() > 1 then
					newState.state = "editing multiple ("..#game.Selection:Get()..") instances"
				else
					newState.state = "editing "..game.Selection:Get()[1].ClassName.." "..game.Selection:Get()[1].Name
				end
			end
		end)
	end
	updatePresence(newState)
end
