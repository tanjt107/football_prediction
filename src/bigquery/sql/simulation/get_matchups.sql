SELECT
  specific_tables.round,
  homeID,
  awayID
FROM ${project_id}.footystats.matches
JOIN ${project_id}.footystats.tables USING (_SEASON_ID)
JOIN tables.specific_tables ON matches.roundID = specific_tables.round_id
JOIN ${project_id}.master.leagues ON matches._SEASON_ID = leagues.latest_season_id
WHERE matches._NAME = league
  AND home_name NOT LIKE '%Group%'
  AND away_name NOT LIKE '%Group%'