function onUpdateDatabase()
    logger.info("Updating database to version 63 (linked tasks system)")

    db.query([[
    	CREATE TABLE IF NOT EXISTS `player_tasks` (
    		`player_id` INT(11) NOT NULL,
    		`task_id` SMALLINT UNSIGNED NOT NULL,
    		`status` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    		`progress` INT UNSIGNED NOT NULL DEFAULT 0,
    		`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    		PRIMARY KEY (`player_id`, `task_id`),
    		CONSTRAINT `fk_player_tasks_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]])
end
