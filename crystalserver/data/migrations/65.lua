function onUpdateDatabase()
    logger.info("Updating database to version 65 (add hunting task points)")
    db.query([[
        ALTER TABLE `players`
        ADD COLUMN IF NOT EXISTS `hunting_task_points`
        INT NOT NULL DEFAULT 0
    ]])
end
