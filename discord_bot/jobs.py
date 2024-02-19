import os
from rq import Queue
from loguru import logger
import redis
import valheim_server
import factorio_server
import db

_QUEUE = None

if _QUEUE is None:
    RQ_REDIS_URL = os.getenv("RQ_REDIS_URL", "redis://localhost:6379/0")
    redis_conn = redis.Redis.from_url(RQ_REDIS_URL)
    _QUEUE = Queue(connection=redis_conn)


def get_queue() -> Queue:
    return _QUEUE


def start_valheim_server(bot_message_server_started: str, bot_message_server_ready: str) -> None:
    with db.get_redis().lock("valheim_server"):
        logger.info("Starting Valheim server")
        valheim_server.start_server(bot_message_server_started, bot_message_server_ready)
        logger.info("Finished starting Valheim server")


def stop_valheim_server(bot_message_started: str, bot_message_finished: str) -> None:
    with db.get_redis().lock("valheim_server"):
        logger.info("Stopping Valheim server")
        valheim_server.stop_server(bot_message_started, bot_message_finished)
        logger.info("Finished stopping Valheim server")


def start_factorio_server() -> None:
    with db.get_redis().lock("factorio_server"):
        logger.info("Starting Factorio server")
        factorio_server.start_server()
        logger.info("Finished starting Factorio server")


def stop_factorio_server() -> None:
    with db.get_redis().lock("factorio_server"):
        logger.info("Stopping Factorio server")
        factorio_server.stop_server()
        logger.info("Finished stopping Factorio server")
