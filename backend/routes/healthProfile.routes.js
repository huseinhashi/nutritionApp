import express from "express";
import { authenticate } from "../middlewares/authmiddleware.js";
import {
  createOrUpdateProfile,
  getProfile,
  deleteProfile,
} from "../controllers/healthProfileController.js";

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Create or update health profile
router.post("/", createOrUpdateProfile);

// Get user's health profile
router.get("/", getProfile);

// Delete health profile
router.delete("/", deleteProfile);

export default router;
