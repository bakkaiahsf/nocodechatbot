import os
from openai import OpenAI
from rasa_sdk import Action

# Get API key from environment variable (set on Render)
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    raise ValueError(
        "\\n\\n================================================================\\n"
        "ERROR: OPENAI_API_KEY environment variable not set.\\n"
        "Please set this environment variable on your Render service.\\n"
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