import subprocess
import pathlib

SCRIPTS_PATH = pathlib.Path(__file__).parent.parent.joinpath("scripts")


def start_server():
    subprocess.run([SCRIPTS_PATH / "start.sh"], check=True)

def stop_server():
    subprocess.run([SCRIPTS_PATH / "teardown.sh"], check=True)
