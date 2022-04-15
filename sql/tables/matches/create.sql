CREATE TABLE IF NOT EXISTS matches(
id INT PRIMARY KEY NOT NULL,
home_id INT NOT NULL,
away_id INT NOT NULL,
status VARCHAR(255),
home_goals VARCHAR(255),
away_goals VARCHAR(255),
home_goal_count INT,
away_goal_count INT,
date_unix INT,
no_home_away BOOLEAN,
team_a_xg FLOAT,
team_b_xg FLOAT,
total_xg FLOAT,
goal_timings_recorded BOOLEAN,
competition_id INT NOT NULL,
home_adj FLOAT,
away_adj FLOAT,
home_avg FLOAT,
away_avg FLOAT,
modified_on TIMESTAMP NOT NULL
) 