function onUpdateDatabase()
    logger.info("Updating database to version 71 (add task board tables)")

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

    return true
end
