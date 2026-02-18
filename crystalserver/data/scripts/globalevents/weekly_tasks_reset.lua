local weeklyTasksReset = GlobalEvent("WeeklyTasksReset")

function weeklyTasksReset.onTime(interval)
    WeeklyTasks.resetAllForWeek(false)
    return true
end

weeklyTasksReset:time("00:00:00")
weeklyTasksReset:register()
