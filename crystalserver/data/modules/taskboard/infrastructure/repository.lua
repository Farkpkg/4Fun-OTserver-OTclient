TaskBoardRepository = TaskBoardRepository or {}

function TaskBoardRepository.loadPlayerState(playerId)
    -- TODO(FASE 2+): Load player taskboard state from persistent storage.
    -- Suggested return shape: { weekKey = "", boardState = "", difficulty = "", ... }
    return nil
end

function TaskBoardRepository.savePlayerState(playerId, state)
    -- TODO(FASE 2+): Persist player taskboard state.
    -- This function intentionally has no SQL implementation in FASE 1.
    return true
end

function TaskBoardRepository.loadTasks(playerId, weekKey)
    -- TODO(FASE 2+): Load all tasks for the given player/week.
    -- Expected return: array of task records.
    return {}
end

function TaskBoardRepository.saveTask(playerId, task)
    -- TODO(FASE 2+): Persist one task record (upsert semantics).
    return true
end

function TaskBoardRepository.clearWeek(playerId, oldWeekKey)
    -- TODO(FASE 2+): Clear/rotate old weekly data for player.
    return true
end

return TaskBoardRepository
