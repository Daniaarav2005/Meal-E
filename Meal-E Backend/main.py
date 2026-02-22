from fastapi import FastAPI
from dotenv import load_dotenv
import os
import json
from genai import generate_meal_plan
import uvicorn

import psycopg2

load_dotenv()

def get_connection():
    return psycopg2.connect(os.getenv("DB_URL"))

app = FastAPI()

# Pantry
@app.get("/pantry")
def get_pantry():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(os.getenv("SQL_GET_PANTRY_QUERY"))
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    
    pantry = []
    for row in rows:
        pantry.append({
            "id": row[0],
            "name": row[1],
            "brand": row[2],
            "quantity": row[3],
            "serving_size": row[18],
            "expiry_date": row[19],
            "nutrients": {
                "calories": row[4],
                "carbohydrates": row[5],
                "protein": row[6],
                "fat": row[7],
                "saturated_fat": row[8],
                "trans_fat": row[9],
                "sugar": row[10],
                "added_sugar": row[11],
                "fiber": row[12],
                "sodium": row[13],
                "iron": row[14],
                "calcium": row[15],
                "potassium": row[16],
                "vitamin_d": row[17],
            }
        })
    
    return {"pantry": pantry}

@app.delete("/pantry")
def delete_ingredient(id: int):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(os.getenv("SQL_DELETE_ITEM_PANTRY_QUERY"), (id,))
    conn.commit()
    cursor.close()
    conn.close()

# Preferences

# Get preferences
@app.get("/preferences")
def get_preferences():
    with open("json/preferences.json") as file:
        preferences = json.load(file)
        return preferences
    return {"error":"Unable to retrieve user preferences."}

# Edit preferences
@app.put("/preferences")
def update_preferences(updates: dict):

    with open("json/preferences.json") as file:
        preferences = json.load(file)
    
    preferences.update(updates)
    
    with open("json/preferences.json","w") as file:
        json.dump(preferences, file, indent=2)
    
    return preferences

# Generate meal plan

def attach_macros(ingredients: dict):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(os.getenv("SQL_GET_INGREDIENTS_NUTRITIONAL_QUERY"), (list(ingredients.keys()),))
    columns = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()
    cursor.close()
    conn.close()

    nutrient_keys = ["calories", "carbohydrates", "protein", "fat", "saturated_fat", "trans_fat", "sugar", "added_sugar", "fiber", "sodium", "iron", "calcium", "potassium", "vitamin_d"]
    totals = {key: 0.0 for key in nutrient_keys}

    for row in rows:
        item = dict(zip(columns, row))
        quantity = ingredients.get(item["name"], [1.0, ""])[0]# take index 0 for multiplier
        for key in nutrient_keys:
            if item.get(key):
                totals[key] += item[key] * quantity

    return totals

def process_meal(meal: dict):
    raw = meal["ingredients"]  # {"Spinach": [2.0, "2 cups (60g)"], ...}
    meal["macros"] = attach_macros({name: values for name, values in raw.items()})
    meal["ingredients"] = {name: values[1] for name, values in raw.items()}
    return meal

@app.get("/meal-plan")
def get_meal_plan(generate: bool):
    if generate:
        # Get the gemini api key
        gemini_api_key = os.getenv("GEMINI_API_KEY")

        # Get the ingredients
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(os.getenv("SQL_GET_INGREDIENTS_QUERY"))
        rows = cursor.fetchall()
        pantry = [
            {
                "name": row[0],
                "brand": row[1],
                "quantity": row[2],
                "serving_size": row[3],
                "expiry_date" : row[4]
            }
            for row in rows
        ]

        # Get preferences
        with open("json/preferences.json") as f:
            preferences = json.load(f)

        plan = json.loads(generate_meal_plan(pantry, preferences, gemini_api_key))["plan"]
        for day in plan:
            for i, meal in enumerate(day["meals"]):
                if "macros" in meal:
                    del meal["macros"]
                day["meals"][i] = process_meal(meal)
                
        with open("json/meal_plan.json", "w") as f:
            json.dump({"plan":plan}, f, indent=2)
        return {"plan":plan}

    
    else:
        full_path = "json/meal_plan.json"
        if os.path.isfile(full_path):
            with open(full_path) as file:
                return json.load(file)
        else:
            return {"error": "Meal plan not found"}
        
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
