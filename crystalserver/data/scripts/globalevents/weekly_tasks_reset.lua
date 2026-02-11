local weeklyTasksReset = GlobalEvent("WeeklyTasksReset")

function weeklyTasksReset.onTime(interval)
    local dateTable = os.date("*t")
    if dateTable.wday == 2 then -- monday
        WeeklyTasks.resetAllForWeek()
    end
    return true
end

weeklyTasksReset:time(configManager.getString(configKeys.GLOBAL_SERVER_SAVE_TIME))
weeklyTasksReset:register()
