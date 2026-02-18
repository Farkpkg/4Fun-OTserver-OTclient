if not RouletteProgress then
	RouletteProgress = {}
	RouletteProgress.__index = RouletteProgress

	RouletteProgress.window = nil
	RouletteProgress.rewards = {}
	RouletteProgress.wastedCount = 0
end

function init()
	RouletteProgress.window = g_ui.displayUI('roulette_progress')
	RouletteProgress.window:hide()

	connect(g_game, {
		onRouletteRewardData = RouletteProgress.onRecvData,
		onOpenRouletteRewardData = show
	})
end

function terminate()
	if RouletteProgress.window then
		RouletteProgress.window:destroy()
		RouletteProgress.window = nil
	end

	disconnect(g_game, {
		onRouletteRewardData = RouletteProgress.onRecvData,
		onOpenRouletteRewardData = show
	})
end

function online()
	hide() 
end

function offline()
	hide()
end

function show()
	RouletteProgress.window:show(true)
	RouletteProgress.window:raise()
	RouletteProgress.window:focus()
	g_client.setInputLockWidget(RouletteProgress.window)
end

function hide()
	RouletteProgress.window:hide()
	g_client.setInputLockWidget(nil)
end

function RouletteProgress.onRecvData(rouletteWasted, rewards)
	RouletteProgress.rewards = rewards
	RouletteProgress.wastedCount = rouletteWasted
	RouletteProgress:configureWindow()
end

function RouletteProgress:configureWindow()
	if not self.window:isVisible() then
		return
	end

	local progressBar = self.window:recursiveGetChildById("rouletteProgress")
	local totalWasted = self.wastedCount % 100
	if totalWasted == 0 and self.wastedCount > 0 then
		totalWasted = 100
	end

	progressBar:setPercent(totalWasted)
	progressBar:setTooltip(string.format("Used roulette coins: %d", totalWasted))

	for k, v in pairs(self.rewards) do
		local widget = self.window:recursiveGetChildById("rewardItem" .. k - 1)
		if not widget then
			break
		end
		widget:setItemId(v[2]) -- itemid
		widget:setTooltip(string.format("x%d %s", v[4], string.capitalize(v[3]))) -- item name

		local coverWidget = widget:getChildById("coverItem" .. k - 1)
		local completed = totalWasted >= v[1]
		coverWidget:setImageSource(string.format("/images/ui/%s", (completed and "ditherpattern-check" or "ditherpattern")))
	end
end