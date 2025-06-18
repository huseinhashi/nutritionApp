import OpenAI from "openai";
import dotenv from "dotenv";
import fs from "fs";

dotenv.config();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

class ImageAnalysisService {
  async analyzeFoodImage(imagePath) {
    try {
      // Read the image file and convert to base64
      const imageBuffer = fs.readFileSync(imagePath);
      const base64Image = imageBuffer.toString("base64");

      const response = await openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: `You are a food analysis expert. Analyze the food items in the image and provide:
            1. English name of each food item
            2. Somali name of each food item
            3. Estimated portion size in grams or ml (always include the unit, e.g., "100g" or "250ml")
            Return ONLY a JSON object with this exact structure, no markdown formatting or additional text:
            {
              "food_items": [
                {
                  "name": "food name in English",
                  "namesom": "food name in Somali",
                  "portionsize": "estimated portion size with unit (e.g., 100g or 250ml)"
                }
              ]
            }`,
          },
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "Please analyze this food image and return ONLY the JSON object with food items.",
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
        max_tokens: 500,
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
        if (!item.name || !item.namesom || !item.portionsize) {
          throw new Error(
            `Invalid food item at index ${index}: missing required fields`
          );
        }
      });

      return parsedResponse;
    } catch (error) {
      console.error("Error in analyzeFoodImage:", error);
      throw new Error(`Failed to analyze food image: ${error.message}`);
    }
  }
}

export default new ImageAnalysisService();
