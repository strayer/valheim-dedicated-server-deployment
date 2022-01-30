import os
import redis

_REDIS = None

if _REDIS is None:
    REDIS_URL=os.getenv('REDIS_URL', 'redis://localhost:6379/1')
    _REDIS = redis.Redis.from_url(REDIS_URL)

def get_redis() -> redis.Redis:
    return _REDIS
