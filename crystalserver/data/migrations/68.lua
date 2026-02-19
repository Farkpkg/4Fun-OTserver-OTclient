function onUpdateDatabase()
    logger.info("Updating database to version 68 (add bounty history)")
    db.query([[
        ALTER TABLE `players`
        ADD COLUMN IF NOT EXISTS `last_bounty_history` TEXT
    ]])
end
