import os
import pathlib
import subprocess

SCRIPTS_PATH = pathlib.Path(__file__).parent.parent.joinpath("scripts")

DEFAULT_ENV = {
    **os.environ,
    "GAME_NAME": "valheim",
    "GAME_DISPLAY_NAME": "Valheim",
}


def start_server(bot_message_server_started: str, bot_message_server_ready: str):
    subprocess.run(
        [SCRIPTS_PATH / "start.sh"],
        check=True,
        env={
            **DEFAULT_ENV,
            "BOT_MESSAGE_SERVER_STARTED": bot_message_server_started,
            "BOT_MESSAGE_SERVER_READY": bot_message_server_ready,
        },
    )


def stop_server(bot_message_started: str, bot_message_finished: str):
    subprocess.run(
        [SCRIPTS_PATH / "teardown.sh"],
        check=True,
        env={
            **DEFAULT_ENV,
            "BOT_MESSAGE_STARTED": bot_message_started,
            "BOT_MESSAGE_FINISHED": bot_message_finished,
        },
    )
