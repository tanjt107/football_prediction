SELECT * EXCEPT(_TIMESTAMP)
FROM `hkjc.odds_had`
WHERE _TIMESTAMP = (
  SELECT MAX(_TIMESTAMP)
  FROM `hkjc.odds_had`
  )