local taskBoardWeeklyReset = GlobalEvent("TaskBoardWeeklyReset")

function taskBoardWeeklyReset.onTime(interval)
	if os.date("!%w") ~= "1" then
		return true
	end
	if type(TaskBoard) == "table" and TaskBoard.resetWeeklyForAll then
		TaskBoard.resetWeeklyForAll()
	end
	return true
end

taskBoardWeeklyReset:time("00:00:00")
taskBoardWeeklyReset:register()
