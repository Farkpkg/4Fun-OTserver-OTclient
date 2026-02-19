function onUpdateDatabase()
    logger.info("Updating database to version 69 (add weekly bounty completions)")
    db.query([[
        ALTER TABLE `players`
        ADD COLUMN IF NOT EXISTS `weekly_bounty_completions` INT NOT NULL DEFAULT 0
    ]])
end
