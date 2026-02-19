function onUpdateDatabase()
	logger.info("Updating database to version 63 (add bounty difficulty columns)")
	db.query([[ALTER TABLE `player_bounty_task` ADD COLUMN IF NOT EXISTS `difficulty` TINYINT NOT NULL DEFAULT 0]])
	db.query([[ALTER TABLE `player_bounty_offers` ADD COLUMN IF NOT EXISTS `difficulty` TINYINT NOT NULL DEFAULT 0]])
end
