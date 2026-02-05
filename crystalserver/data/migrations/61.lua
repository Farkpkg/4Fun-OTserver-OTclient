function onUpdateDatabase()
	logger.info("Updating database to version 61 (create player_tasks table)")
	db.query([[CREATE TABLE IF NOT EXISTS `player_tasks` (
		`player_id` INT UNSIGNED NOT NULL,
		`task_id` SMALLINT UNSIGNED NOT NULL,
		`progress` INT UNSIGNED NOT NULL DEFAULT 0,
		`status` TINYINT UNSIGNED NOT NULL DEFAULT 0,
		PRIMARY KEY (`player_id`, `task_id`),
		INDEX `idx_player_tasks_status` (`player_id`, `status`),
		CONSTRAINT `fk_player_tasks_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end
