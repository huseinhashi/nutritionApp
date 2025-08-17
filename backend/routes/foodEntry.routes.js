import express from "express";
import { authenticate } from "../middlewares/authmiddleware.js";
import {
  addFoodEntry,
  getFoodEntries,
  deleteFoodEntry,
  addFoodEntryFromImage,
} from "../controllers/foodEntryController.js";
import path from "path";
import fs from "fs";

const router = express.Router();

// Add food entry
router.post("/", authenticate, addFoodEntry);

// Get food entries with optional date range
router.get("/", authenticate, getFoodEntries);
router.post("/image", authenticate, addFoodEntryFromImage);

// Delete food entry
router.delete("/:id", authenticate, deleteFoodEntry);

// Serve food images (NO AUTHENTICATION REQUIRED)
router.get("/image/:filename", (req, res) => {
  const { filename } = req.params;
  const imagePath = path.join(process.cwd(), "uploads", filename);
  
  // Check if file exists
  if (!fs.existsSync(imagePath)) {
    return res.status(404).json({
      success: false,
      message: "Image not found"
    });
  }
  
  // Serve the image
  res.sendFile(imagePath);
});

export default router;
