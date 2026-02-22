function onUpdateDatabase()
	logger.info("Updating database to version 72 (task board schema sync)")

	local function hasColumn(tableName, columnName)
		local query = db.storeQuery("SHOW COLUMNS FROM `" .. tableName .. "` LIKE " .. db.escapeString(columnName))
		if not query then
			return false
		end

		result.free(query)
		return true
	end

	local function addColumnIfMissing(tableName, columnName, definition)
		if hasColumn(tableName, columnName) then
			return
		end

		db.query("ALTER TABLE `" .. tableName .. "` ADD COLUMN `" .. columnName .. "` " .. definition)
	end

	db.query([[
		CREATE TABLE IF NOT EXISTS `player_bounty_tasks` (
			`player_id` INT NOT NULL,
			`slot` TINYINT NOT NULL DEFAULT 1,
			`creature_id` INT UNSIGNED NOT NULL DEFAULT 0,
			`creature_name` VARCHAR(64) NOT NULL DEFAULT '',
			`kills` INT UNSIGNED NOT NULL DEFAULT 0,
			`max_kills` INT UNSIGNED NOT NULL DEFAULT 0,
			`xp_reward` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			`bp_reward` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
			`rt_reward` TINYINT UNSIGNED NOT NULL DEFAULT 0,
			`tier` TINYINT UNSIGNED NOT NULL DEFAULT 0,
			`difficulty` TINYINT UNSIGNED NOT NULL DEFAULT 0,
			`completed` TINYINT UNSIGNED NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`, `slot`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `player_weekly_tasks` (
			`player_id` INT NOT NULL,
			`task_type` TINYINT NOT NULL DEFAULT 0,
			`slot` TINYINT NOT NULL DEFAULT 1,
			`target_name` VARCHAR(64) NOT NULL DEFAULT '',
			`target_id` INT UNSIGNED NOT NULL DEFAULT 0,
			`current_count` INT UNSIGNED NOT NULL DEFAULT 0,
			`max_count` INT UNSIGNED NOT NULL DEFAULT 0,
			`completed` TINYINT UNSIGNED NOT NULL DEFAULT 0,
			`week_number` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`, `task_type`, `slot`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	addColumnIfMissing("player_weekly_tasks", "task_type", "TINYINT NOT NULL DEFAULT 0 AFTER `player_id`")
	addColumnIfMissing("player_weekly_tasks", "slot", "TINYINT NOT NULL DEFAULT 1 AFTER `task_type`")
	addColumnIfMissing("player_weekly_tasks", "target_name", "VARCHAR(64) NOT NULL DEFAULT '' AFTER `slot`")
	addColumnIfMissing("player_weekly_tasks", "target_id", "INT UNSIGNED NOT NULL DEFAULT 0 AFTER `target_name`")
	addColumnIfMissing("player_weekly_tasks", "current_count", "INT UNSIGNED NOT NULL DEFAULT 0 AFTER `target_id`")
	addColumnIfMissing("player_weekly_tasks", "max_count", "INT UNSIGNED NOT NULL DEFAULT 0 AFTER `current_count`")
	addColumnIfMissing("player_weekly_tasks", "completed", "TINYINT UNSIGNED NOT NULL DEFAULT 0 AFTER `max_count`")
	addColumnIfMissing("player_weekly_tasks", "week_number", "SMALLINT UNSIGNED NOT NULL DEFAULT 0 AFTER `completed`")

	db.query([[
		CREATE TABLE IF NOT EXISTS `player_talisman` (
			`player_id` INT NOT NULL,
			`slot` TINYINT NOT NULL DEFAULT 1,
			`level` TINYINT UNSIGNED NOT NULL DEFAULT 1,
			`current_pct` FLOAT NOT NULL DEFAULT 2.50,
			PRIMARY KEY (`player_id`, `slot`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `player_task_preferred` (
			`player_id` INT NOT NULL,
			`list_type` TINYINT NOT NULL DEFAULT 0,
			`slot` TINYINT NOT NULL DEFAULT 1,
			`creature_id` INT UNSIGNED NOT NULL DEFAULT 0,
			`creature_name` VARCHAR(64) NOT NULL DEFAULT '',
			PRIMARY KEY (`player_id`, `list_type`, `slot`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `player_task_extra_slots` (
			`player_id` INT NOT NULL,
			`extra_slots` TINYINT UNSIGNED NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])

	db.query([[
		CREATE TABLE IF NOT EXISTS `player_task_currencies` (
			`player_id` INT NOT NULL,
			`reroll_tokens` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
			`bounty_points` INT UNSIGNED NOT NULL DEFAULT 0,
			`hunting_points` INT UNSIGNED NOT NULL DEFAULT 0,
			`soulseals` INT UNSIGNED NOT NULL DEFAULT 0,
			`last_daily` DATE DEFAULT NULL,
			`weekly_seed` INT UNSIGNED NOT NULL DEFAULT 0,
			`bounty_seed` INT UNSIGNED NOT NULL DEFAULT 0,
			PRIMARY KEY (`player_id`),
			FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	]])
end
