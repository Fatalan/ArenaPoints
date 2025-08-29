local localization = {
	ruRU = {
		REASON_NOT_QUALIFIED = "потому, что вы не отыграли 10 игр в этом брекете на этой неделе.",
		REASON_NOT_ENOUGH_PERCENT = "потому, что вы сыграли менее 30% игр в этой команде на этой неделе",
		WILL_EARN = "Вы получите %i очков арены.",
		WONT_EARN = "Вы не получите очков арены ",
		AP_INFO = "Помните, вы получите награду только за один из брекетов, конкретно за тот, за который вы получите больше всего очков арены"
	},
	enUS = {
		REASON_NOT_QUALIFIED = "'cause you haven't participated in 10 arena matches in this bracket this week.",
		REASON_NOT_ENOUGH_PERCENT = "'cause you have participated in less then 30% of this team matches this week",
		WILL_EARN = "You'll earn %i arena points.",
		WONT_EARN = "You won't earn any arena points ",
		AP_INFO = "Remember, you'll only get reward for one of the brackets, specifically for the bracket you'll earn most arena points from"
	}
}
local pvpTeamFrames = {PVPTeam1, PVPTeam2, PVPTeam3}
local function CalculateArenaPoints(teamID)
	local teamName, teamSize, teamRating, weekPlayed, weekWins, seasonPlayed, seasonWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating = GetArenaTeam(teamID)
	if(playerPlayed < 10) then
		return 0, "REASON_NOT_QUALIFIED"
	end
	local requiredGames = ceil(weekPlayed * 0.3)
	if(playerPlayed < requiredGames) then
		return 0, "REASON_NOT_ENOUGH_PERCENT"
	end
	local points = 0
	local rating = 0
	if(playerRating + 150 < teamRating) then
		rating = playerRating
	else
		rating = teamRating
	end
	if(rating <= 1500) then
		points = 344
	else
		points = 1511.26 / (1.0 + 1639.28 * exp(-0.00412 * rating));
	end
	if(teamSize == 2) then
		points = points * 0.76
	elseif(teamSize == 3) then
		points = points * 0.88
	end
	return floor(points)
end
local function SetupPVPTeamFrame(frame)
    frame:HookScript("OnShow", function(self)
		if not self.AwaitedAP then
			self.AwaitedAP = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			self.AwaitedAP:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
			self.AwaitedAP:SetPoint("CENTER", self, "CENTER", -10, -5)
			self.AwaitedAP:SetTextColor(1, 1, 1, 1)
			self.AwaitedAP:SetSize(self:GetWidth() - 50, 0)
		end
		local points, reason = CalculateArenaPoints(self:GetID())
		local text = ""
		local locale = GetLocale()
		if(localization[locale] == nil) then
			locale = "enUS"
		end
		if(reason == nil) then
			text = string.format(localization[locale]["WILL_EARN"], points)
		else
			text = localization[locale]["WONT_EARN"] .. localization[locale][reason]
		end
        self.AwaitedAP:SetText(text)
    end)
end

PVPFrame:HookScript("OnShow", function(self)
		if not self.APInfo then
			self.APInfo = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			self.APInfo:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
			self.APInfo:SetPoint("CENTER", self, "TOP", 0, -162)
			self.APInfo:SetTextColor(1, 1, 1, 1)
			self.APInfo:SetSize(self:GetWidth() - 50, 0)
			local locale = GetLocale()
			if(localization[locale] == nil) then
				locale = "enUS"
			end
			self.APInfo:SetText(localization[locale]["AP_INFO"])
		end
	end)

for i, frame in ipairs(pvpTeamFrames) do
    SetupPVPTeamFrame(frame)
end