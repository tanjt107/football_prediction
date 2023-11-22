WITH result AS (
  SELECT
    teams.transfermarkt_id,
    teams.name,
    rating,
    offence,
    defence,
    table.scored - table.conceded AS goal_diff,
    table.wins * 3 + table.draws + COALESCE(table.correction, 0) AS points,
    COALESCE(positions._1, 0) AS champ,
    COALESCE(positions._1, 0) + COALESCE(positions._2 , 0) AS acle,
    COALESCE(positions._3, 0) AS acl2,
    COALESCE(positions._18, 0) AS relegation
  FROM `simulation.leagues_latest` leagues
  JOIN `master.teams` teams ON leagues.team = teams.footystats_id
  JOIN `solver.team_ratings` ratings ON teams.solver_id = ratings.id
  WHERE _LEAGUE = 'Japan J1 League'
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
  ROUND(acle, 3) AS acle,
  ROUND(acl2, 3) AS acl2,
  ROUND(relegation, 3) AS relegation
FROM result
ORDER BY points DESC