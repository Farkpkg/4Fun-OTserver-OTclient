TaskBoardCache = TaskBoardCache or {
    players = {}
}

function TaskBoardCache.get(playerId)
    return TaskBoardCache.players[playerId]
end

function TaskBoardCache.set(playerId, data)
    TaskBoardCache.players[playerId] = data
end

function TaskBoardCache.clear(playerId)
    TaskBoardCache.players[playerId] = nil
end

return TaskBoardCache
