CREATE TABLE user (
	user_id INTEGER NOT NULL PRIMARY KEY,
	user_name TEXT NOT NULL,
	password TEXT NOT NULL
);

CREATE UNIQUE INDEX UN1_username ON user (user_name);

CREATE TABLE device (
	device_id INTEGER NOT NULL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES user (user_id) ON DELETE CASCADE,
	device_name TEXT NOT NULL,
	data TEXT
);

CREATE UNIQUE INDEX UN1_device_name ON device (device_name, user_id);

CREATE TABLE subscription (
	subscription_id INTEGER NOT NULL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES user (user_id) ON DELETE CASCADE,
	url TEXT NOT NULL,
	deleted INTEGER NOT NULL DEFAULT 0,
	changed INTEGER NOT NULL,
	data TEXT
);

CREATE UNIQUE INDEX UN1_subscription_url ON subscription (url, user_id);

CREATE TABLE episodes_action (
	episodes_action_id INTEGER NOT NULL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES user (user_id) ON DELETE CASCADE,
	device_id INTEGER NOT NULL REFERENCES device (device_id) ON DELETE CASCADE,
	subscription_id INTEGER NOT NULL REFERENCES subscription (subscription_id) ON DELETE CASCADE,
	url TEXT NOT NULL,
	changed INTEGER NOT NULL,
	action TEXT NOT NULL,
	data TEXT
);

CREATE INDEX IX1_episodes_idx ON episodes_action (user_id, action, changed);
