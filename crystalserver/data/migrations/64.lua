function onUpdateDatabase()
	logger.info("Updating database to version 64 (add last bounty week column)")
	db.query([[ALTER TABLE `player_bounty_offers` ADD COLUMN IF NOT EXISTS `last_bounty_week` INT NOT NULL DEFAULT 0]])
end
