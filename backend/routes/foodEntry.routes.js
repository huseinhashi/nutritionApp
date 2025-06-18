import express from "express";
import { authenticate } from "../middlewares/authmiddleware.js";
import {
  addFoodEntry,
  getFoodEntries,
  deleteFoodEntry,
  addFoodEntryFromImage,
} from "../controllers/foodEntryController.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Add food entry
router.post("/", addFoodEntry);

// Get food entries with optional date range
router.get("/", getFoodEntries);
router.post("/image", addFoodEntryFromImage);

// Delete food entry
router.delete("/:id", deleteFoodEntry);

export default router;
