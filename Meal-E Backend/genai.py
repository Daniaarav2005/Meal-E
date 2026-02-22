from google import genai
import json

def generate_meal_plan(pantry: list[dict], preferences: dict, api_key: str):
    with open("prompt.xml", "r") as file:
        prompt = file.read()
        prompt = prompt.format(
            pantry=json.dumps(pantry),
            preferences=json.dumps(preferences)
        )
    client = genai.Client(api_key=api_key)

    response = client.models.generate_content(
        model="gemini-3-flash-preview",
        contents=prompt
    )


    return response.text