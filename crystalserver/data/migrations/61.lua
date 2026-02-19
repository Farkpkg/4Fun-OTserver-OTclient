function onUpdateDatabase()
	logger.info("Updating database to version 61 (add player bounty task table)")
	db.query([[
		CREATE TABLE IF NOT EXISTS `player_bounty_task` (
			`player_id` INT PRIMARY KEY,
			`creature_name` VARCHAR(64) NOT NULL,
			`required_kills` INT NOT NULL,
			`current_kills` INT NOT NULL,
			`completed` TINYINT(1) NOT NULL DEFAULT 0,
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		)
	]])
end
