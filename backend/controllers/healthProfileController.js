import HealthProfile from "../models/health_profiles.model.js";
import User from "../models/users.model.js";
import { calculateDailyCalories } from "../utils/nutritionCalculator.js";
import { healthProfileSchema } from "../validators/validator.js";

// // Calculate BMI (weight in kg / (height in m)²)
// const calculateBMI = (weight, height) => {
//   const heightInMeters = height / 100;
//   return Number((weight / (heightInMeters * heightInMeters)).toFixed(1));
// };

export const createOrUpdateProfile = async (req, res) => {
  try {
    // Validate request body using Zod schema
    const validatedData = healthProfileSchema.parse(req.body);
    const userId = req.user.user_id;

    // Calculate daily calories, water intake, and BMI
    const { dailyCalories, dailyWaterMl, bmi, dailySteps } =
      calculateDailyCalories({
        ...validatedData,
      });

    // Create or update health profile
    const [profile, created] = await HealthProfile.upsert({
      userId,
      ...validatedData,
      bmi,
      dailyCalories,
      dailyWaterMl,
      dailySteps,
    });

    res.json({
      success: true,
      message: created
        ? "Health profile created successfully"
        : "Health profile updated successfully",
      data: profile,
    });
  } catch (error) {
    console.error("Error in createOrUpdateProfile:", error);
    if (error.name === "ZodError") {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: error.errors,
      });
    }
    res.status(500).json({
      success: false,
      message: "Failed to create/update health profile",
      error: error.message,
    });
  }
};

export const getProfile = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const profile = await HealthProfile.findOne({
      where: { userId },
      include: [
        {
          model: User,
          attributes: ["username", "phone"],
        },
      ],
    });

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: "Health profile not found",
      });
    }

    res.json({
      success: true,
      data: profile,
    });
  } catch (error) {
    console.error("Error in getProfile:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch health profile",
      error: error.message,
    });
  }
};

export const deleteProfile = async (req, res) => {
  try {
    const userId = req.user.user_id;

    const deleted = await HealthProfile.destroy({
      where: { userId },
    });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: "Health profile not found",
      });
    }

    res.json({
      success: true,
      message: "Health profile deleted successfully",
    });
  } catch (error) {
    console.error("Error in deleteProfile:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete health profile",
      error: error.message,
    });
  }
};
