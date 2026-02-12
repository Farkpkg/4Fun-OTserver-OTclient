TaskBoardConstants = TaskBoardConstants or {}

TaskBoardConstants.OP_CODE_TASKBOARD = 242
TaskBoardConstants.SCHEMA_VERSION = 1

TaskBoardConstants.ACTION = {
    OPEN = "open",
    SELECT_DIFFICULTY = "selectDifficulty",
    REROLL = "reroll",
    DELIVER = "deliver",
    BUY = "buy",
    CLAIM_BOUNTY = "claimBounty",
}

TaskBoardConstants.DELTA_EVENT = {
    TASK_UPDATED = "taskUpdated",
    PROGRESS_UPDATED = "progressUpdated",
    MULTIPLIER_UPDATED = "multiplierUpdated",
    SHOP_UPDATED = "shopUpdated",
    WEEK_ROTATED = "weekRotated",
}

return TaskBoardConstants
