import FoodEntry from "../models/food_entries.model.js";
import { foodEntrySchema } from "../validators/validator.js";
import { Op } from "sequelize";
import foodTranslationService from "../services/foodTranslationService.js";
import imageAnalysisService from "../services/imageAnalysisService.js";
import mlNutritionService from "../services/mlNutritionService.js";
import multer from "multer";
import path from "path";
import fs from "fs";

// Configure multer for image upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = "uploads";
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir);
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = ["image/jpeg", "image/png", "image/jpg"];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("Invalid file type. Only JPEG, PNG and JPG are allowed."));
    }
  },
}).single("image");

// Initialize ML models when the controller is loaded
let mlModelsInitialized = false;

async function initializeMLModels() {
  if (!mlModelsInitialized) {
    try {
      console.log("🚀 Initializing ML nutrition models...");
      await mlNutritionService.initializeModels();
      mlModelsInitialized = true;
      console.log("✅ ML models initialized successfully");
    } catch (error) {
      console.error("❌ Failed to initialize ML models:", error.message);
      console.log("⚠️ Will use OpenAI fallback for nutrition prediction");
    }
  }
}

// Initialize ML models
initializeMLModels();

// Add food entry
export const addFoodEntry = async (req, res) => {
  try {
    const { food_name, food_name_somali, portion_size = "N/A" } = req.body;
    const userId = req.user.user_id;

    // If only Somali name is provided, translate it
    let englishFoodName = food_name;
    if (!englishFoodName && food_name_somali) {
      englishFoodName = await foodTranslationService.translateToEnglish(
        food_name_somali
      );
    }

    // Get nutrition data using ML models with fallback
    let nutritionData;
    try {
      // Try to get nutrition data using ML models
      const portionSize = parseFloat(portion_size) || 100;
      nutritionData = await mlNutritionService.getNutritionPrediction(
        englishFoodName,
        portionSize,
        "unknown", // Default category
        "g",
        imageAnalysisService // Pass as fallback service
      );
    } catch (error) {
      console.log("⚠️ ML nutrition prediction failed, using USDA API fallback");
      // Fallback to USDA API
      nutritionData = await foodTranslationService.getNutritionInfo(
        englishFoodName
      );
    }

    // Create food entry with nutrition data
    const foodEntry = await FoodEntry.create({
      userId,
      foodName: englishFoodName,
      foodNameSomali: food_name_somali || englishFoodName,
      calories: nutritionData.nutrients?.calories || nutritionData.calories || 0,
      protein: nutritionData.nutrients?.protein || nutritionData.protein || 0,
      fat: nutritionData.nutrients?.fats || nutritionData.fat || 0,
      carbohydrates: nutritionData.nutrients?.carbs || nutritionData.carbohydrates || 0,
      vitaminA: nutritionData.nutrients?.vitamins?.A || nutritionData.vitamins?.A || 0,
      vitaminC: nutritionData.nutrients?.vitamins?.C || nutritionData.vitamins?.C || 0,
      calcium: nutritionData.nutrients?.minerals?.calcium || nutritionData.minerals?.calcium || 0,
      iron: nutritionData.nutrients?.minerals?.iron || nutritionData.minerals?.iron || 0,
      fdcId: nutritionData.fdcId || null,
      servingSize: nutritionData.servingSize || portion_size,
      servingUnit: nutritionData.servingUnit || "g",
      portionSize: portion_size || "N/A",
    });

    res.json({
      success: true,
      message: "Food entry added successfully",
      data: foodEntry,
    });
  } catch (error) {
    console.error("Error in addFoodEntry:", error);
    res.status(500).json({
      success: false,
      message: error.message || "Failed to add food entry",
    });
  }
};

// Get food entries with date range and summary
export const getFoodEntries = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { start_date, end_date } = req.query;

    // Build where clause
    const whereClause = { userId };
    if (start_date && end_date) {
      whereClause.createdAt = {
        [Op.between]: [start_date, `${end_date} 23:59:59`],
      };
    }

    // Get food entries
    const entries = await FoodEntry.findAll({
      where: whereClause,
      order: [["createdAt", "DESC"]],
    });

    // Group entries by date
    const groupedEntries = entries.reduce((acc, entry) => {
      const date = entry.createdAt.toISOString().split("T")[0];
      if (!acc[date]) {
        acc[date] = [];
      }
      acc[date].push(entry);
      return acc;
    }, {});

    // Calculate daily summaries
    const dailySummaries = Object.entries(groupedEntries).map(
      ([date, entries]) => {
        const summary = entries.reduce(
          (acc, entry) => ({
            calories: acc.calories + Number(entry.calories),
            protein: acc.protein + Number(entry.protein),
            fat: acc.fat + Number(entry.fat),
            carbohydrates: acc.carbohydrates + Number(entry.carbohydrates),
          }),
          { calories: 0, protein: 0, fat: 0, carbohydrates: 0 }
        );

        // Round the summary values
        summary.protein = Number(summary.protein.toFixed(2));
        summary.fat = Number(summary.fat.toFixed(2));
        summary.carbohydrates = Number(summary.carbohydrates.toFixed(2));

        return {
          date,
          entries,
          summary,
        };
      }
    );

    // Calculate overall summary
    const overallSummary = dailySummaries.reduce(
      (acc, day) => ({
        calories: acc.calories + day.summary.calories,
        protein: acc.protein + day.summary.protein,
        fat: acc.fat + day.summary.fat,
        carbohydrates: acc.carbohydrates + day.summary.carbohydrates,
      }),
      { calories: 0, protein: 0, fat: 0, carbohydrates: 0 }
    );

    // Calculate averages
    const daysCount = dailySummaries.length || 1; // Avoid division by zero
    const averages = {
      calories: Math.round(overallSummary.calories / daysCount),
      protein: Number((overallSummary.protein / daysCount).toFixed(2)),
      fat: Number((overallSummary.fat / daysCount).toFixed(2)),
      carbohydrates: Number(
        (overallSummary.carbohydrates / daysCount).toFixed(2)
      ),
    };

    res.json({
      success: true,
      data: {
        entries: groupedEntries,
        dailySummaries,
        overallSummary,
        averages,
      },
    });
  } catch (error) {
    console.error("Error in getFoodEntries:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch food entries",
      error: error.message,
    });
  }
};

// Delete food entry
export const deleteFoodEntry = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const deleted = await FoodEntry.destroy({
      where: {
        id,
        userId,
      },
    });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: "Food entry not found",
      });
    }

    res.json({
      success: true,
      message: "Food entry deleted successfully",
    });
  } catch (error) {
    console.error("Error in deleteFoodEntry:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete food entry",
      error: error.message,
    });
  }
};

// Add food entry from image
export const addFoodEntryFromImage = async (req, res) => {
  upload(req, res, async function (err) {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No image file provided",
      });
    }

    try {
      const userId = req.user.user_id;
      const imagePath = req.file.path;

      console.log("📸 Analyzing food image...");

      // Analyze image using OpenAI for food detection
      const analysisResult = await imageAnalysisService.analyzeFoodImage(
        imagePath
      );
      
      console.log("✅ Image analysis completed");
      console.log(`🍽️ Detected ${analysisResult.food_items.length} food items`);

      // Process each food item
      const foodEntries = await Promise.all(
        analysisResult.food_items.map(async (item) => {
          console.log(`🍎 Processing: ${item.name} (${item.portionsize})`);
          
          // Extract portion size
          const portionMatch = item.portionsize.match(/(\d+(?:\.\d+)?)(\w+)/);
          const portionSize = portionMatch ? parseFloat(portionMatch[1]) : 100;
          const portionUnit = portionMatch ? portionMatch[2] : 'g';

          // Use nutrition data from ML models (already included in analysis result)
          const nutritionData = item.nutrients;

          return FoodEntry.create({
            userId,
            foodName: item.name,
            foodNameSomali: item.namesom,
            calories: nutritionData.calories || 0,
            protein: nutritionData.protein || 0,
            fat: nutritionData.fats || nutritionData.fat || 0,
            carbohydrates: nutritionData.carbs || nutritionData.carbohydrates || 0,
            vitaminA: nutritionData.vitamins?.A || 0,
            vitaminC: nutritionData.vitamins?.C || 0,
            calcium: nutritionData.minerals?.calcium || 0,
            iron: nutritionData.minerals?.iron || 0,
            fdcId: null, // No FDC ID from ML/OpenAI
            servingSize: portionSize,
            servingUnit: portionUnit,
            portionSize: item.portionsize || "N/A",
            imagePath: imagePath, // Store the image path
          });
        })
      );

      console.log(`✅ Successfully created ${foodEntries.length} food entries`);

      res.json({
        success: true,
        message: "Food entries added successfully",
        data: foodEntries,
        analysis: {
          totalItems: analysisResult.food_items.length,
          items: analysisResult.food_items.map(item => ({
            name: item.name,
            portion: item.portionsize,
            category: item.category
          }))
        }
      });
    } catch (error) {
      console.error("Error in addFoodEntryFromImage:", error);
      res.status(500).json({
        success: false,
        message: error.message || "Failed to process food image",
      });
    }
  });
};
