REPLACE INTO footystats.matches
(id,
home_id,
away_id,
status,
home_goals,
away_goals,
home_goal_count,
away_goal_count,
date_unix,
no_home_away,
team_a_xg,
team_b_xg,
total_xg,
goal_timings_recorded,
competition_id,
home_adj,
away_adj,
home_avg,
away_avg,
modified_on)
VALUES
(%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s,
%s) 