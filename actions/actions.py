import os
from pathlib import Path
from dotenv import load_dotenv
from openai import OpenAI
from rasa_sdk import Action
from rasa_sdk.events import UserUtteranceReverted

# Build a robust path to the .env_local file in the project root
env_path = Path(__file__).parent.parent / '.env_local'

# Load the environment variables from your .env_local file
load_dotenv(dotenv_path=env_path)

api_key = os.getenv("OPENAI_API_KEY")
if not api_key or "YOUR_OPENAI_API_KEY" in api_key:
    raise ValueError(
        "\\n\\n================================================================\\n"
        f"ERROR: OpenAI API key not found in '{env_path}'.\\n"
        "Please make sure the file exists and contains your key, for example:\\n\\n"
        'OPENAI_API_KEY="sk-..."\\n\\n'
        "================================================================\\n"
    )

client = OpenAI(api_key=api_key)

class ActionFallbackGPT(Action):
    def name(self):
        return "action_fallback_gpt"

    def run(self, dispatcher, tracker, domain):
        user_msg = tracker.latest_message.get('text')

        try:
            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": user_msg}]
            )
            dispatcher.utter_message(response.choices[0].message.content)
        except Exception as e:
            print(f"Error during OpenAI API call: {e}")
            dispatcher.utter_message("I'm sorry, I seem to be having trouble thinking right now. Please try again in a moment.")

        return [] 