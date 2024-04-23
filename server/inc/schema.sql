CREATE TABLE user (
	user_id INTEGER NOT NULL PRIMARY KEY,
	name TEXT NOT NULL,
	password TEXT NOT NULL
);

CREATE UNIQUE INDEX UN1_users_name ON users (name);

CREATE TABLE device (
	device_id INTEGER NOT NULL PRIMARY KEY,
	user INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
	devicename TEXT NOT NULL,
	data TEXT
);

CREATE UNIQUE INDEX UN1_devicename ON device (devicename, user);

CREATE TABLE subscription (
	subscription_id INTEGER NOT NULL PRIMARY KEY,
	user INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
	url TEXT NOT NULL,
	deleted INTEGER NOT NULL DEFAULT 0,
	changed INTEGER NOT NULL,
	data TEXT
);

CREATE UNIQUE INDEX UN1_subscription_url ON subscription (url, user);

CREATE TABLE episodes_action (
	episodes_action_id INTEGER NOT NULL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES user (user_id) ON DELETE CASCADE,
	device_id INTEGER NOT NULL REFERENCES device (devices_id) ON DELETE CASCADE,
	subscription_id INTEGER NOT NULL REFERENCES subscription (subscription_id) ON DELETE CASCADE,
	url TEXT NOT NULL,
	changed INTEGER NOT NULL,
	action TEXT NOT NULL,
	data TEXT
);

CREATE INDEX IX1_episodes_idx ON episodes_action (user, action, changed);
