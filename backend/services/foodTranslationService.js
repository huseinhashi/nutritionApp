import axios from "axios";
import { config } from "dotenv";

config();

// Validate required environment variables
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const USDA_API_KEY = process.env.USDA_API_KEY;

if (!OPENROUTER_API_KEY) {
  throw new Error("OPENROUTER_API_KEY is not set in environment variables");
}
if (!USDA_API_KEY) {
  throw new Error("USDA_API_KEY is not set in environment variables");
}

const USDA_API_URL = "https://api.nal.usda.gov/fdc/v1";

class FoodTranslationService {
  async translateToEnglish(foodName) {
    try {
      // First check if the text is already English using OpenRouter
      const response = await axios.post(
        "https://openrouter.ai/api/v1/chat/completions",
        {
          model: "deepseek/deepseek-r1:free", // Using the free model that works
          messages: [
            {
              role: "system",
              content:
                "You are a helpful assistant that determines if a food name is in English or Somali and translates Somali food names to English. Only respond with the English food name, nothing else.",
            },
            {
              role: "user",
              content: `Is "${foodName}" in English? If yes, return it as is. If it's in Somali, translate it to English. Only respond with the English food name.`,
            },
          ],
        },
        {
          headers: {
            Authorization: `Bearer ${OPENROUTER_API_KEY}`,
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost:5000", // Required by OpenRouter
            "X-Title": "Nutrition Tracker", // Optional but recommended
          },
        }
      );

      if (!response.data.choices?.[0]?.message?.content) {
        throw new Error("Invalid response from translation service");
      }

      const translatedName = response.data.choices[0].message.content.trim();
      return translatedName;
    } catch (error) {
      console.error(
        "Translation error:",
        error.response?.data || error.message
      );
      if (error.response?.status === 401) {
        throw new Error("Invalid OpenRouter API key");
      }
      throw new Error("Failed to translate food name");
    }
  }

  async getNutritionInfo(foodName) {
    try {
      // Format the dataType parameter as a comma-separated string
      const dataTypes = ["Survey (FNDDS)", "Foundation", "SR Legacy"].join(",");

      const response = await axios.get(`${USDA_API_URL}/foods/search`, {
        params: {
          query: foodName,
          api_key: USDA_API_KEY,
          dataType: dataTypes,
          pageSize: 1,
        },
        paramsSerializer: (params) => {
          // Custom serializer to handle array parameters
          return Object.entries(params)
            .map(([key, value]) => {
              if (key === "dataType") {
                // Split the comma-separated string and create multiple dataType parameters
                return value
                  .split(",")
                  .map((type) => `dataType=${encodeURIComponent(type)}`)
                  .join("&");
              }
              return `${key}=${encodeURIComponent(value)}`;
            })
            .join("&");
        },
      });

      if (!response.data.foods || response.data.foods.length === 0) {
        throw new Error(`No nutrition data found for ${foodName}`);
      }

      const food = response.data.foods[0];
      return this.parseNutritionData(food);
    } catch (error) {
      console.error("Nutrition data fetch error:", error);
      if (error.response) {
        console.error("USDA API Error Response:", error.response.data);
      }
      throw new Error("Failed to fetch nutrition data");
    }
  }

  parseNutritionData(food) {
    const getNutrientValue = (nutrients, nutrientId) => {
      const nutrient = nutrients.find((n) => n.nutrientId === nutrientId);
      return nutrient ? nutrient.value : 0;
    };

    const nutrients = food.foodNutrients;

    return {
      fdcId: food.fdcId,
      description: food.description,
      servingSize: food.servingSize || 100,
      servingUnit: food.servingSizeUnit || "g",
      nutrients: {
        calories: getNutrientValue(nutrients, 1008),
        protein: getNutrientValue(nutrients, 1003),
        carbs: getNutrientValue(nutrients, 1005),
        fats: getNutrientValue(nutrients, 1004),
        fiber: getNutrientValue(nutrients, 1079),
        vitamins: {
          A: getNutrientValue(nutrients, 1104),
          C: getNutrientValue(nutrients, 1162),
          D: getNutrientValue(nutrients, 1114),
          E: getNutrientValue(nutrients, 1109),
        },
        minerals: {
          calcium: getNutrientValue(nutrients, 1087),
          iron: getNutrientValue(nutrients, 1089),
          potassium: getNutrientValue(nutrients, 1092),
          sodium: getNutrientValue(nutrients, 1093),
        },
      },
    };
  }
}

export default new FoodTranslationService();
