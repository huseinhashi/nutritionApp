import express from "express";
import { authenticate } from "../middlewares/authmiddleware.js";
import {
  addFoodEntry,
  getFoodEntries,
  deleteFoodEntry,
} from "../controllers/foodEntryController.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Add food entry
router.post("/", addFoodEntry);

// Get food entries with optional date range
router.get("/", getFoodEntries);

// Delete food entry
router.delete("/:id", deleteFoodEntry);

export default router;
