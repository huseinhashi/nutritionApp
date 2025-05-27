import jwt from "jsonwebtoken";
import { JWT_SECRET } from "../config/env.js";

// Middleware to authenticate users
export const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      message: "Authentication token is missing or invalid",
    });
  }

  const authToken = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(authToken, JWT_SECRET);
    req.user = decoded; // Attach the decoded token payload to the request object
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
}; // Error handler middleware for consistent error responses
export const errorHandler = (err, req, res, next) => {
  console.error("Error:", err);

  // Handle Zod validation errors
  if (err.name === "ZodError") {
    const errors = err.errors
      .map((e) => `${e.path.join(".")}: ${e.message}`)
      .join(", ");
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors: errors,
    });
  }

  // Handle Sequelize validation errors
  if (
    err.name === "SequelizeValidationError" ||
    err.name === "SequelizeUniqueConstraintError"
  ) {
    const errors = err.errors.map((e) => e.message).join(", ");
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors: errors,
    });
  }
  // Default error response
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || "Internal server error",
  });
};
