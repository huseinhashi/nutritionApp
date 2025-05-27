import express from "express";
import { authenticate } from "../middlewares/authmiddleware.js";
import {
  addWaterIntake,
  getWaterIntake,
  deleteWaterIntake,
} from "../controllers/waterIntakeController.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Add water intake
router.post("/", addWaterIntake);

// Get water intake entries
router.get("/", getWaterIntake);

// Delete water intake entry
router.delete("/:id", deleteWaterIntake);

export default router;
