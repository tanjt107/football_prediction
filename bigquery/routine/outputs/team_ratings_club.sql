SELECT
  RANK() OVER(ORDER BY rating DESC) AS rank,
  teams.transfermarkt_id AS team_transfermarkt_id,
  teams.name AS team_name,
  leagues.transfermarkt_id As league_transfermarkt_id,
  leagues.name AS league_name,
  ROUND(offence, 1) AS offence,
  ROUND(defence, 1) AS defence,
  ROUND(rating, 1) AS rating
FROM `solver.team_ratings` ratings
JOIN `master.teams` teams ON ratings.id = teams.solver_id
  AND _TYPE = teams.type
JOIN `master.leagues` leagues ON teams.league_name = leagues.name
WHERE latest_season_id IS NOT NULL AND _TYPE = 'Club'
ORDER BY rank;