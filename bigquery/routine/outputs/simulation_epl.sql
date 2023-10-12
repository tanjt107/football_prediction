WITH result AS (
  SELECT
    teams.transfermarkt_id,
    teams.name,
    rating,
    offence,
    defence,
    table.scored - table.conceded AS goal_diff,
    table.wins * 3 + table.draws AS points,
    COALESCE(positions.1, 0) AS champ,
    COALESCE(positions.1, 0) + COALESCE(positions.2, 0) + COALESCE(positions.3, 0) + COALESCE(positions.4, 0) AS ucl,
    COALESCE(positions.5, 0) AS uel,
    COALESCE(positions.18, 0) + COALESCE(positions.19, 0) + COALESCE(positions.20, 0) AS relegation
  FROM `simulation.leagues_latest` leagues
  JOIN `master.teams` teams ON CAST(leagues.team AS INT64) = teams.footystats_id
  JOIN `solver.team_ratings` ratings ON teams.solver_id = ratings.id
  WHERE _LEAGUE = 'England Premier League'
  AND ratings._TYPE = 'Club'
)

SELECT
  transfermarkt_id,
  name,
  ROUND(rating, 1) AS rating,
  ROUND(offence, 2) AS offence,
  ROUND(defence, 2) AS defence,
  ROUND(goal_diff, 1) AS goal_diff,
  ROUND(points, 1) AS points,
  ROUND(champ, 3) AS champ,
  ROUND(ucl, 3) AS ucl,
  ROUND(uel, 3) AS uel,
  ROUND(relegation, 3) AS relegation
FROM result
ORDER BY points DESC