function onUpdateDatabase()
    logger.info("Updating database to version 67 (add last bounty claim week)")
    db.query([[
        ALTER TABLE `players`
        ADD COLUMN IF NOT EXISTS `last_bounty_claim_week` INT NOT NULL DEFAULT 0
    ]])
end
