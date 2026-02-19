function onUpdateDatabase()
    logger.info("Updating database to version 70 (add last bounty week to players)")
    db.query([[
        ALTER TABLE `players`
        ADD COLUMN IF NOT EXISTS `last_bounty_week` INT NOT NULL DEFAULT 0
    ]])
end
