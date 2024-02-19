import os
import re
import sys

import backoff
from loguru import logger

import docker
from docker.errors import NotFound
from docker.models.containers import Container

from gpt.personas import HalvarTheSkald
import requests

# Specify the environment variables for the container name and regex pattern
GAME_NAME = os.environ.get("GAME_NAME")
DISCORD_WEBHOOK = os.environ.get("DISCORD_WEBHOOK")
SERVER_READY_MESSAGE = os.environ.get("SERVER_READY_MESSAGE")

if DISCORD_WEBHOOK is None or DISCORD_WEBHOOK == "":
    logger.error("DISCORD_WEBHOOK environment variable required to function")
    sys.exit(-1)

if SERVER_READY_MESSAGE is None or SERVER_READY_MESSAGE == "":
    logger.error("SERVER_READY_MESSAGE environment variable required to function")
    sys.exit(-1)

if GAME_NAME == "valheim":
    CONTAINER_NAME = "valheim-server"
    REGEX_PATTERN = "Game server connected"
elif GAME_NAME is None or GAME_NAME == "":
    logger.error("GAME_NAME environment variable required to function")
    sys.exit(-1)
else:
    logger.error("Unknown game {game}", game=GAME_NAME)
    sys.exit(-1)

# Compile the regex pattern for better performance
compiled_regex = re.compile(REGEX_PATTERN)


@backoff.on_exception(backoff.expo, NotFound, max_time=60)
def get_container() -> Container:
    return client.containers.get(CONTAINER_NAME)


def notify_server_ready():
    data = {
        "content": SERVER_READY_MESSAGE,
        "avatar_url": HalvarTheSkald.avatar_url,
        "username": HalvarTheSkald.name,
    }
    result = requests.post(DISCORD_WEBHOOK, json=data)
    result.raise_for_status()


# Establish a connection to the Docker server using the default socket
client = docker.from_env()

try:
    container = get_container()

    # Stream the logs from the container, both old and new
    for log_line in container.logs(stream=True, follow=True, tail="all"):
        log_line = log_line.decode("utf-8").strip()

        if compiled_regex.search(log_line):
            logger.info("Matched log line: {log_line}", log_line=log_line)
            notify_server_ready()
            break
        else:
            logger.debug("Unmatched log line: {log_line}", log_line=log_line)

except NotFound:
    logger.error(
        "Container '{CONTAINER_NAME}' not found.", CONTAINER_NAME=CONTAINER_NAME
    )
except Exception as e:
    logger.error("An error occurred: {e}", e=e)
finally:
    client.close()
