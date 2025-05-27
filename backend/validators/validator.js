import { z } from "zod";

// User Schema
export const userSchema = z.object({
  username: z
    .string()
    .min(2, "Username must be at least 2 characters")
    .max(255, "Username cannot exceed 255 characters"),
  phone: z.string().regex(/^\d{10}$/, "Phone number must be exactly 10 digits"),
  password: z
    .string()
    .min(6, "Password must be at least 6 characters")
    .max(100, "Password cannot exceed 100 characters"),
});

// Health Profile Schema
export const healthProfileSchema = z.object({
  age: z.number().int().min(1, "Age must be at least 1"),
  gender: z.enum(["male", "female"]),
  weight: z.number().positive("Weight must be positive"),
  height: z.number().positive("Height must be positive"),
  goal: z.enum(["weight_loss", "maintenance", "muscle_gain"]),
  activityLevel: z.enum(["lightly_active", "moderately_active", "very_active"]),
});

// Water Intake Schema
export const waterIntakeSchema = z.object({
  intake_amount: z.number().positive("Intake amount must be positive"),
  intake_date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Date must be in YYYY-MM-DD format"),
});

// Food Entry Schema
export const foodEntrySchema = z.object({
  food_name: z.string().min(1, "Food name is required"),
  food_name_somali: z.string().min(1, "Somali food name is required"),
  calories: z.number().int().min(0, "Calories must be non-negative"),
  protein: z.number().min(0, "Protein must be non-negative").optional(),
  fat: z.number().min(0, "Fat must be non-negative").optional(),
  carbohydrates: z
    .number()
    .min(0, "Carbohydrates must be non-negative")
    .optional(),
  vitamin_a: z.number().min(0, "Vitamin A must be non-negative").optional(),
  vitamin_c: z.number().min(0, "Vitamin C must be non-negative").optional(),
  calcium: z.number().min(0, "Calcium must be non-negative").optional(),
  iron: z.number().min(0, "Iron must be non-negative").optional(),
});

// Meal Plan Schema
export const mealPlanSchema = z.object({
  name: z.string().min(1, "Meal plan name is required"),
  goal: z.enum(["weight_loss", "maintenance", "muscle_gain"]),
  start_date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Start date must be in YYYY-MM-DD format"),
  end_date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "End date must be in YYYY-MM-DD format"),
});

// Meal Plan Item Schema
export const mealPlanItemSchema = z.object({
  food_name: z.string().min(1, "Food name is required"),
  meal_type: z.enum(["breakfast", "lunch", "dinner", "snack"]),
  day_of_week: z.number().int().min(0).max(6),
  serving_size: z.number().positive("Serving size must be positive"),
  serving_unit: z.string().min(1, "Serving unit is required"),
});

// Login Schema
export const loginSchema = z.object({
  phone: z.string().regex(/^\d{10}$/, "Phone number must be exactly 10 digits"),
  password: z
    .string()
    .min(6, "Password must be at least 6 characters")
    .max(100, "Password cannot exceed 100 characters"),
});
