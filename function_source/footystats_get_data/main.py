import base64
import functions_framework
import json
import os
import requests
from google.cloud import storage

bucket_names = {
    "matches": os.getenv("MATCHES_BUCKET_NAME"),
    "season": os.getenv("SEASON_BUCKET_NAME"),
    "teams": os.getenv("TEAMS_BUCKET_NAME"),
}
API_KEY = os.getenv("FOOTYSTATS_API_KEY")


@functions_framework.cloud_event
def main(cloud_event):
    data = base64.b64decode(cloud_event.data["message"]["data"]).decode("utf-8")
    message = json.loads(data)
    endpoint, season_id = message["endpoint"], message["season_id"]
    fetched_data = fetch_data(endpoint, season_id, API_KEY)
    formatted_data = format_data(fetched_data)
    destination = f"{season_id}.json"
    upload_to_gcs(bucket_names[endpoint], formatted_data, destination)


def fetch_data(endpoint: str, season_id: str, key: str) -> dict:
    response = requests.get(
        f"https://api.football-data-api.com/league-{endpoint}",
        params={"key": key, "season_id": season_id},
    )
    response.raise_for_status()
    return response.json()["data"]


def format_data(data):
    if isinstance(data, list):
        return "\n".join([json.dumps(d) for d in data])
    return json.dumps(data)


def upload_to_gcs(bucket_name: str, content: str, destination: str):
    storage.Client().bucket(bucket_name).blob(destination).upload_from_string(content)
