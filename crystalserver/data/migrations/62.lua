function onUpdateDatabase()
    logger.info("Updating database to version 62 (hunting tasks system)")

    db.query([[
    	CREATE TABLE IF NOT EXISTS `player_hunting_tasks` (
    		`player_id` INT(11) NOT NULL,
    		`slot` TINYINT UNSIGNED NOT NULL,
    		`state` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    		`race_id` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    		`current_kills` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    		`required_kills` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    		`stars` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    		`reward_points` INT UNSIGNED NOT NULL DEFAULT 0,
    		`bestiary_unlocked` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    		`reroll_time` BIGINT NOT NULL DEFAULT 0,
    		PRIMARY KEY (`player_id`, `slot`),
    		CONSTRAINT `fk_player_hunting_tasks_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
    	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]])

    db.query([[
    	ALTER TABLE `players`
    		ADD COLUMN IF NOT EXISTS `hunting_task_points` BIGINT NOT NULL DEFAULT 0;
    ]])
end
