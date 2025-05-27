import express from "express";
import authRoutes from "./auth.routes.js";
import healthProfileRoutes from "./healthProfile.routes.js";
import waterIntakeRoutes from "./waterIntake.routes.js";
import foodEntryRoutes from "./foodEntry.routes.js";

const router = express.Router();

// Authentication routes
router.use("/auth", authRoutes);
router.use("/health-profile", healthProfileRoutes);
router.use("/water-intake", waterIntakeRoutes);
router.use("/food-entries", foodEntryRoutes);

export default router;
