import subprocess
import pathlib
import os

SCRIPTS_PATH = pathlib.Path(__file__).parent.parent.joinpath("scripts")

DEFAULT_ENV = {**os.environ, "GAME_NAME": "factorio", "GAME_DISPLAY_NAME": "Factorio"}


def start_server():
    subprocess.run([SCRIPTS_PATH / "start.sh"], check=True, env=DEFAULT_ENV)


def stop_server():
    subprocess.run([SCRIPTS_PATH / "teardown.sh"], check=True, env=DEFAULT_ENV)
