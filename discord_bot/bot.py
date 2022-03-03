import os

from loguru import logger
import lightbulb

import db
import jobs

GUILD_ID = int(os.environ["GUILD_ID"])
ALLOWED_CHANNEL_IDS = os.environ["CHANNEL_IDS"].split(",")

COMMAND_PREFIX = "dev-" if os.environ["ENV"] == "dev" else ""

bot = lightbulb.BotApp(token=os.environ["BOT_TOKEN"])


def is_authorized_channel(channel_id: str) -> bool:
    return channel_id in ALLOWED_CHANNEL_IDS


async def authorize(ctx: lightbulb.SlashContext) -> bool:
    if not is_authorized_channel(str(ctx.channel_id)):
        logger.warning(
            "Received {command} command from unauthorized channel {channel} by user {username}",
            username=ctx.author.username,
            channel=ctx.channel_id,
            command=ctx.command.name,
        )
        await ctx.respond("ERROR: This command is not allowed in this channel!")
        return False

    return True


def log_command(ctx: lightbulb.SlashContext) -> None:
    logger.debug(
        "Received {command} command from channel {channel} by user {username}",
        username=ctx.author.username,
        channel=ctx.channel_id,
        command=ctx.command.name,
    )


async def cooldown(ctx: lightbulb.SlashContext, seconds: int) -> bool:
    redis = db.get_redis()
    if redis.get(ctx.command.name) != None:
        logger.warning(
            "Received {command} command on cooldown in channel {channel} by user {username}",
            username=ctx.author.username,
            channel=ctx.channel_id,
            command=ctx.command.name,
        )
        ttl = redis.ttl(ctx.command.name)
        await ctx.respond(
            f"ERROR: This command is on cooldown! Please retry later. ({ttl}s left)",
        )
        return False

    set_cooldown(ctx, seconds)
    return True


def set_cooldown(ctx: lightbulb.SlashContext, seconds: int) -> None:
    redis = db.get_redis()
    redis.set(ctx.command.name, value=1, ex=seconds)


@bot.command
@lightbulb.command(
    f"{COMMAND_PREFIX}start-valheim", "Starts the Valheim dedicated server.", guilds=[GUILD_ID]
)
@lightbulb.implements(lightbulb.SlashCommand)
async def start_valheim(ctx: lightbulb.SlashContext) -> None:
    if not await authorize(ctx):
        return
    if not await cooldown(ctx, 60):
        return

    log_command(ctx)
    await ctx.respond("Server start trigger received, this may take a few minutes")

    jobs.get_queue().enqueue(jobs.start_valheim_server)


@bot.command
@lightbulb.command(
    f"{COMMAND_PREFIX}stop-valheim", "Stops the Valheim dedicated server.", guilds=[GUILD_ID]
)
@lightbulb.implements(lightbulb.SlashCommand)
async def stop_valheim(ctx: lightbulb.SlashContext) -> None:
    if not await authorize(ctx):
        return
    if not await cooldown(ctx, 60):
        return

    log_command(ctx)
    await ctx.respond("Server stop trigger received, this may take a few minutes")

    jobs.get_queue().enqueue(jobs.stop_valheim_server)


@bot.command
@lightbulb.command(f"{COMMAND_PREFIX}ping", "pong?", guilds=[GUILD_ID])
@lightbulb.implements(lightbulb.SlashCommand)
async def ping(ctx: lightbulb.SlashContext) -> None:
    log_command(ctx)
    await ctx.respond(f"Pong! (channel_id: {ctx.channel_id})")


if __name__ == "__main__":
    bot.run()
