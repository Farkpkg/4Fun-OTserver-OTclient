function onUpdateDatabase()
    logger.info("Updating database to version 64 (weekly tasks system)")

    db.query([[
    	CREATE TABLE IF NOT EXISTS `player_weekly_tasks` (
    		`player_id` INT(11) NOT NULL,
    		`week_key` VARCHAR(16) NOT NULL,
    		`state` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    		`difficulty` VARCHAR(16) NOT NULL DEFAULT '',
    		`completed_kill_tasks` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    		`completed_delivery_tasks` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    		`earned_task_points` INT UNSIGNED NOT NULL DEFAULT 0,
    		`earned_soul_seals` INT UNSIGNED NOT NULL DEFAULT 0,
    		`reward_multiplier` FLOAT NOT NULL DEFAULT 1,
    		`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    		PRIMARY KEY (`player_id`),
    		CONSTRAINT `fk_player_weekly_tasks_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]])

    db.query([[
    	CREATE TABLE IF NOT EXISTS `player_weekly_task_entries` (
    		`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    		`player_id` INT(11) NOT NULL,
    		`week_key` VARCHAR(16) NOT NULL,
    		`task_type` VARCHAR(16) NOT NULL,
    		`target_name` VARCHAR(64) NOT NULL DEFAULT '',
    		`item_id` INT UNSIGNED NOT NULL DEFAULT 0,
    		`required_amount` INT UNSIGNED NOT NULL DEFAULT 0,
    		`current_amount` INT UNSIGNED NOT NULL DEFAULT 0,
    		`difficulty_tier` VARCHAR(16) NOT NULL DEFAULT '',
    		`is_completed` TINYINT(1) NOT NULL DEFAULT 0,
    		PRIMARY KEY (`id`),
    		KEY `idx_player_week` (`player_id`, `week_key`),
    		CONSTRAINT `fk_player_weekly_task_entries_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]])

    db.query([[
    	CREATE TABLE IF NOT EXISTS `player_weekly_unlocks` (
    		`player_id` INT(11) NOT NULL,
    		`expansion_unlocked` TINYINT(1) NOT NULL DEFAULT 0,
    		PRIMARY KEY (`player_id`),
    		CONSTRAINT `fk_player_weekly_unlocks_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]])
end
