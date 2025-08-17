import OpenAI from "openai";
import dotenv from "dotenv";
import fs from "fs";
import mlNutritionService from "./mlNutritionService.js";

dotenv.config();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

class ImageAnalysisService {
  async analyzeFoodImage(imagePath, existingAnalysis = null) {
    try {
      // If we already have analysis results, use them
      if (existingAnalysis) {
        console.log("📋 Using existing analysis results");
        return existingAnalysis;
      }

      // Read the image file and convert to base64
      const imageBuffer = fs.readFileSync(imagePath);
      const base64Image = imageBuffer.toString("base64");

      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: `You are a food analysis and nutrition expert. Analyze the food items in the image and provide:
      1. English name of each food item
      2. Somali name of each food item
      3. Estimated portion size in grams or ml (always include the unit, e.g., "100g" or "250ml")
      4. Food category (fruit, vegetable, protein, grain, dairy, nut, or unknown)
      
      Return ONLY a JSON object with this exact structure, no markdown formatting or additional text:
      {
        "food_items": [
          {
            "name": "food name in English",
            "namesom": "food name in Somali",
            "portionsize": "estimated portion size with unit (e.g., 100g or 250ml)",
            "category": "food category (fruit/vegetable/protein/grain/dairy/nut/unknown)"
          }
        ]
      }`,
          },
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "Please analyze this food image and return ONLY the JSON object with food items, their portion sizes, and categories.",
              },
              {
                type: "image_url",
                image_url: {
                  url: `data:image/jpeg;base64,${base64Image}`,
                },
              },
            ],
          },
        ],
        max_tokens: 1000,
        response_format: { type: "json_object" },
      });

      // Get the response content
      const content = response.choices[0].message.content;

      // Clean up the response content
      const cleanedContent = content
        .replace(/```json\s*/g, "") // Remove ```json prefix
        .replace(/```\s*$/g, "") // Remove ``` suffix
        .trim(); // Remove any extra whitespace

      // Parse the cleaned JSON
      const parsedResponse = JSON.parse(cleanedContent);

      // Validate the response structure
      if (
        !parsedResponse.food_items ||
        !Array.isArray(parsedResponse.food_items)
      ) {
        throw new Error("Invalid response format from OpenAI");
      }

      // Validate each food item
      parsedResponse.food_items.forEach((item, index) => {
        if (
          !item.name ||
          !item.namesom ||
          !item.portionsize ||
          !item.category
        ) {
          throw new Error(
            `Invalid food item at index ${index}: missing required fields`
          );
        }
      });

      // Now get nutrition data using ML models with fallback to OpenAI
      const enhancedFoodItems = await this.getNutritionDataForFoodItems(parsedResponse.food_items);

      return {
        food_items: enhancedFoodItems
      };

    } catch (error) {
      console.error("Error in analyzeFoodImage:", error);
      throw new Error(`Failed to analyze food image: ${error.message}`);
    }
  }

  /**
   * Get nutrition data for food items using ML models with OpenAI fallback
   */
  async getNutritionDataForFoodItems(foodItems) {
    const enhancedFoodItems = [];

    for (const foodItem of foodItems) {
      try {
        // Extract portion size and unit
        const portionMatch = foodItem.portionsize.match(/(\d+(?:\.\d+)?)(\w+)/);
        const portionSize = portionMatch ? parseFloat(portionMatch[1]) : 100;
        const portionUnit = portionMatch ? portionMatch[2] : 'g';

        console.log(`🍎 Processing: ${portionSize}${portionUnit} of ${foodItem.name} (${foodItem.category})`);

        // Get nutrition data using ML models with fallback
        const nutritionData = await mlNutritionService.getNutritionPrediction(
          foodItem.name,
          portionSize,
          foodItem.category,
          portionUnit,
          this // Pass this service as fallback
        );

        // Create enhanced food item with nutrition data
        const enhancedItem = {
          ...foodItem,
          nutrients: nutritionData
        };

        enhancedFoodItems.push(enhancedItem);
        console.log(`✅ Nutrition data obtained for ${foodItem.name}`);

      } catch (error) {
        console.error(`❌ Failed to get nutrition data for ${foodItem.name}:`, error.message);
        
        // Add food item with default nutrition data
        enhancedFoodItems.push({
          ...foodItem,
          nutrients: {
            calories: 0,
            protein: 0,
            carbs: 0,
            fats: 0,
            fiber: 0,
            vitamins: { A: 0, C: 0, D: 0, E: 0 },
            minerals: { calcium: 0, iron: 0, potassium: 0, sodium: 0 }
          }
        });
      }
    }

    return enhancedFoodItems;
  }

  /**
   * Fallback method for nutrition prediction using OpenAI
   */
  async getNutritionFromOpenAI(foodName, portionSize, foodCategory) {
    try {
      console.log(`🤖 OpenAI Fallback: Getting nutrition for ${portionSize}g of ${foodName}`);
      
      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: `You are a nutrition expert. Provide nutrition data for the given food item.
            Return ONLY a JSON object with nutrition values for the specified portion size.
            Use realistic USDA-compliant nutrition values.`,
          },
          {
            role: "user",
            content: `Provide nutrition data for ${portionSize}g of ${foodName} (category: ${foodCategory}).
            Return ONLY a JSON object with this structure:
            {
              "calories": number,
              "protein": number,
              "carbs": number,
              "fats": number,
              "fiber": number,
              "vitamins": { "A": number, "C": number, "D": number, "E": number },
              "minerals": { "calcium": number, "iron": number, "potassium": number, "sodium": number }
            }`,
          },
        ],
        max_tokens: 500,
        response_format: { type: "json_object" },
      });

      const content = response.choices[0].message.content;
      const nutritionData = JSON.parse(content);
      
      console.log(`✅ OpenAI nutrition data obtained for ${foodName}`);
      return nutritionData;

    } catch (error) {
      console.error(`❌ OpenAI nutrition fallback failed for ${foodName}:`, error.message);
      throw error;
    }
  }
}

export default new ImageAnalysisService();
