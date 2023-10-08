import math
import os
from collections import defaultdict
from dataclasses import asdict

import functions_framework
from cloudevents.http.event import CloudEvent

from gcp import storage
from gcp.util import decode_message
from simulation import queries
from simulation.models import Rules, Team, TieBreaker
from simulation.league import Season
from simulation.cup import Round, Knockout

BUCKET_NAME = os.getenv("BUCKET_NAME")


@functions_framework.cloud_event
def main(cloud_event: CloudEvent):
    data = decode_message(cloud_event)
    league, country = data["league"], data["country"]

    last_run = queries.get_last_run(league, country) or -1
    latest_match_date = queries.get_latest_match_date(league, country) or 0
    if last_run >= latest_match_date:
        print(f"Already updated. Simulation aborted: {country=} {league=}")
        return

    factors = queries.get_avg_goal_home_adv(league, country)
    avg_goal, home_adv = factors["avg_goal"], factors["home_adv"]
    teams = queries.get_teams(league, country)
    rule = Rules(**data["rule"])
    completed = queries.get_completed_matches(league, country)

    groups = {
        group: Season(
            [teams[team] for team in _teams], avg_goal, home_adv, rule, completed
        )
        for group, _teams in data["groups"].items()
    }
    if data.get("ko_matchups"):
        matchups = {
            Round(_round): [
                (teams[home_team], teams[away_team])
                for (home_team, away_team) in matchups
            ]
            for _round, matchups in data["ko_matchups"].items()
        }
    else:
        matchups = None

    print(f"Simulating: {country=} {league=}")
    data = simulate_cup(groups, data["team_no_ko"], matchups, completed_ko=completed)
    print(f"Simulated: {country=} {league=}")

    storage.upload_json_to_bucket(
        data, blob_name=f"{league}.json", bucket_name=BUCKET_NAME
    )

    queries.insert_run_log(league, country, latest_match_date)


def simulate_cup(
    groups: dict[str, Season],
    team_no_ko: int,
    matchups: dict[Round, list[tuple[Team, Team]]] | None = None,
    completed_ko: dict[tuple[str], tuple[int]] | None = None,
    no_of_simulations: int = 10000,
):
    direct, wildcard = divmod(team_no_ko, len(groups))

    for _ in range(no_of_simulations):
        positions = defaultdict(list)
        for group in groups.values():
            group.simulate()
            for position, team in enumerate(group.positions, 1):
                team.update_sim_table()
                team.update_sim_positions(position)
                positions[position].append(team)

        advanced = []
        for position, teams in positions.items():
            if position <= direct:
                advanced.extend(teams)
            if position == direct + 1:
                advanced.extend(
                    sorted(
                        positions[direct + 1],
                        key=TieBreaker.goal_diff,
                        reverse=True,
                    )[:wildcard]
                )

        if not math.log2(len(advanced)).is_integer():
            continue

        group = list(groups.values())[0]
        knockout = Knockout(
            teams=advanced,
            avg_goal=group.avg_goal,
            home_adv=group.home_adv,
            rule=group.rule,
            matchups=matchups,
            completed=completed_ko,
        )
        knockout.simulate()
        for round, teams in knockout.results.items():
            for team in teams:
                team.update_sim_rounds(round)

    for season in groups.values():
        for team in season.teams:
            team.sim_table /= no_of_simulations
            team.sim_rounds /= no_of_simulations
            team.sim_positions /= no_of_simulations

    return [
        {
            "team": team.name,
            "group": group,
            "positions": dict(team.sim_positions),
            "rounds": dict(team.sim_rounds),
            "table": asdict(team.sim_table),
        }
        for group, season in groups.items()
        for team in season.teams
    ]
