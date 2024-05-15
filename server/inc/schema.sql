CREATE TABLE feed (
	feed_id INTEGER NOT NULL PRIMARY KEY,
	feed_url TEXT NOT NULL,
	image_url TEXT NULL,
	url TEXT NULL,
	language TEXT NULL CHECK (language IS NULL OR LENGTH(language) = 2),
	title TEXT NULL,
	description TEXT NULL,
	pubdate TEXT NULL DEFAULT CURRENT_TIMESTAMP CHECK (pubdate IS NULL OR datetime(pubdate) = pubdate),
	last_fetch INTEGER NOT NULL
);

CREATE UNIQUE INDEX UN1_feed_url ON feed (feed_url);

CREATE TABLE episode (
	episode_id INTEGER NOT NULL PRIMARY KEY,
	feed_id INTEGER NOT NULL REFERENCES feed (feed_id) ON DELETE CASCADE,
	media_url TEXT NOT NULL,
	url TEXT NULL,
	image_url TEXT NULL,
	duration INTEGER NULL,
	title TEXT NULL,
	description TEXT NULL,
	pubdate TEXT NULL DEFAULT CURRENT_TIMESTAMP CHECK (pubdate IS NULL OR datetime(pubdate) = pubdate)
);

CREATE UNIQUE INDEX UN1_episode ON episode (feed_id, media_url);

CREATE TABLE user (
	user_id INTEGER NOT NULL PRIMARY KEY,
	name TEXT NOT NULL,
	password TEXT NOT NULL
);

CREATE UNIQUE INDEX UN1_user_name ON user (name);

CREATE TABLE device (
	device_id INTEGER NOT NULL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES user (user_id) ON DELETE CASCADE,
	deviceid TEXT NOT NULL,
	name TEXT NULL,
	data TEXT
);

CREATE UNIQUE INDEX UN1_deviceid ON device (deviceid, user_id);

CREATE TABLE subscription (
	subscription_id INTEGER NOT NULL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES user (user_id) ON DELETE CASCADE,
	feed_id INTEGER NULL REFERENCES feed (feed_id) ON DELETE SET NULL,
	url TEXT NOT NULL,
	deleted INTEGER NOT NULL DEFAULT 0,
	changed INTEGER NOT NULL,
	data TEXT
);

CREATE UNIQUE INDEX UN1_subscription_url ON subscription (url, user_id);
CREATE INDEX IN1_subscription_feed ON subscription (feed_id);

CREATE TABLE episode_action (
	episode_action_id INTEGER NOT NULL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES user (user_id) ON DELETE CASCADE,
	subscription_id INTEGER NOT NULL REFERENCES subscription (subscription_id) ON DELETE CASCADE,
	episode_id INTEGER NULL REFERENCES episode (episode_id) ON DELETE SET NULL,
	device_id INTEGER NULL REFERENCES device (device_id) ON DELETE SET NULL,
	url TEXT NOT NULL,
	changed INTEGER NOT NULL,
	action TEXT NOT NULL,
	data TEXT
);

CREATE INDEX IN1_episodes_idx ON episode_action (user_id, action, changed);
CREATE INDEX IN1_episode_action_link ON episode_action (episode_id);

CREATE VIEW listActions_V AS
	SELECT a.*,
		   d.name AS device_name,
		   e.title,
		   e.url AS episode_url
		   FROM episode_action a
		   LEFT JOIN device d ON d.device_id = a.device_id AND a.user_id = d.user_id
		   LEFT JOIN episode e ON e.episode_id = a.episode_id
		   ORDER BY changed DESC;

CREATE VIEW listActiveSubscriptions_V AS
	SELECT s.*,
		   COUNT(a.rowid) AS count,
		   f.title,
		   COALESCE(MAX(a.changed), s.changed) AS last_change
	FROM subscription s
	LEFT JOIN episode_action a ON a.subscription_id = s.subscription_id
	LEFT JOIN feed f ON f.feed_id = s.feed_id
	WHERE 1=1
	  AND s.deleted = 0
	GROUP BY s.subscription_id
	ORDER BY last_change DESC;

PRAGMA user_version = 20240428;
