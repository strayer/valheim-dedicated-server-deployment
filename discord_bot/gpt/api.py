import os
import sys

from openai import AsyncAzureOpenAI

AZURE_OPENAI_KEY = os.getenv("AZURE_OPENAI_KEY")
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
AZURE_OPENAI_DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT")

OPENAI_CLIENT = None

async def respond(system_prompt: str, user_prompt: str):
    global OPENAI_CLIENT

    if AZURE_OPENAI_DEPLOYMENT == "" or AZURE_OPENAI_DEPLOYMENT is None:
        print("TODO error")
        sys.exit(-1)

    if OPENAI_CLIENT is None:
        if AZURE_OPENAI_KEY == "" or AZURE_OPENAI_KEY is None:
            print("TODO error")
            sys.exit(-1)

        if AZURE_OPENAI_ENDPOINT == "" or AZURE_OPENAI_ENDPOINT is None:
            print("TODO error")
            sys.exit(-1)

        OPENAI_CLIENT = AsyncAzureOpenAI(
            api_key=AZURE_OPENAI_KEY,
            api_version="2023-12-01-preview",
            azure_endpoint=AZURE_OPENAI_ENDPOINT,
        )

    response = await OPENAI_CLIENT.chat.completions.create(
        model=AZURE_OPENAI_DEPLOYMENT,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
    )

    # TODO handle errors
    # TODO handle content filter

    return response.choices[0].message.content

if __name__ == "__main__":
    from .api import respond
    import asyncio

    async def async_main():
        response = await respond("You are an AI test assistant", "Ping!")
        print(response)

    asyncio.run(async_main())
