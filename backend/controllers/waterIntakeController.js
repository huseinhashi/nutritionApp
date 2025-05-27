import WaterIntake from "../models/water_intake.model.js";
import { waterIntakeSchema } from "../validators/validator.js";

// Add water intake
export const addWaterIntake = async (req, res) => {
  try {
    // Validate request body
    const validatedData = waterIntakeSchema.parse(req.body);
    const userId = req.user.user_id;

    // Create water intake entry
    const waterIntake = await WaterIntake.create({
      userId,
      intakeAmount: validatedData.intake_amount,
      intakeDate: validatedData.intake_date,
    });

    res.json({
      success: true,
      message: "Water intake logged successfully",
      data: waterIntake,
    });
  } catch (error) {
    console.error("Error in addWaterIntake:", error);
    if (error.name === "ZodError") {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: error.errors,
      });
    }
    res.status(500).json({
      success: false,
      message: "Failed to log water intake",
      error: error.message,
    });
  }
};

// Get water intake entries
export const getWaterIntake = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { start_date, end_date } = req.query;

    // Build where clause
    const whereClause = { userId };
    if (start_date && end_date) {
      whereClause.intakeDate = {
        [Op.between]: [start_date, end_date],
      };
    }

    // Get water intake entries
    const entries = await WaterIntake.findAll({
      where: whereClause,
      order: [
        ["intakeDate", "DESC"],
        ["createdAt", "DESC"],
      ],
    });

    // Group entries by date
    const groupedEntries = entries.reduce((acc, entry) => {
      const date = entry.intakeDate;
      if (!acc[date]) {
        acc[date] = [];
      }
      acc[date].push(entry);
      return acc;
    }, {});

    res.json({
      success: true,
      data: groupedEntries,
    });
  } catch (error) {
    console.error("Error in getWaterIntake:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch water intake entries",
      error: error.message,
    });
  }
};

// Delete water intake entry
export const deleteWaterIntake = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { id } = req.params;

    const deleted = await WaterIntake.destroy({
      where: {
        id,
        userId,
      },
    });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: "Water intake entry not found",
      });
    }

    res.json({
      success: true,
      message: "Water intake entry deleted successfully",
    });
  } catch (error) {
    console.error("Error in deleteWaterIntake:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete water intake entry",
      error: error.message,
    });
  }
};
