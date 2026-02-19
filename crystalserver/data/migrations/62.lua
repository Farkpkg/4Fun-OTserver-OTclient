function onUpdateDatabase()
	logger.info("Updating database to version 62 (add player bounty offers table)")
	db.query([[
		CREATE TABLE IF NOT EXISTS `player_bounty_offers` (
			`player_id` INT NOT NULL,
			`slot` TINYINT NOT NULL,
			`creature_name` VARCHAR(64) NOT NULL,
			`required_kills` INT NOT NULL,
			PRIMARY KEY (`player_id`, `slot`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		)
	]])
end
