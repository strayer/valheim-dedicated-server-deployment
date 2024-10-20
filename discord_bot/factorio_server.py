import subprocess
import pathlib
import os

from discord_bot.gpt import personas

SCRIPTS_PATH = pathlib.Path(__file__).parent.parent.joinpath("scripts")

DEFAULT_ENV = {
    **os.environ,
    "GAME_NAME": "factorio",
    "GAME_DISPLAY_NAME": "Factorio",
    "BOT_NAME": personas.ActiveInfrastructurePersona.name,
    "BOT_AVATAR_URL": personas.ActiveInfrastructurePersona.avatar_url,
    "BOT_GAME_PERSONA_NAME": personas.FitzgeraldGallagher.name,
    "BOT_GAME_PERSONA_AVATAR_URL": personas.FitzgeraldGallagher.avatar_url,
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
