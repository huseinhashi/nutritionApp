import { DataTypes } from "sequelize";
import sequelize from "../database/connection.js";

// Models
import User from "./users.model.js";
import HealthProfile from "./health_profiles.model.js";
import WaterIntake from "./water_intake.model.js";
import FoodEntry from "./food_entries.model.js";
import MealPlan from "./meal_plans.model.js";
import MealPlanItem from "./meal_plan_items.model.js";

// Define associations
User.hasOne(HealthProfile, { foreignKey: "userId" });
HealthProfile.belongsTo(User, { foreignKey: "userId" });

User.hasMany(WaterIntake, { foreignKey: "userId" });
WaterIntake.belongsTo(User, { foreignKey: "userId" });

User.hasMany(FoodEntry, { foreignKey: "userId" });
FoodEntry.belongsTo(User, { foreignKey: "userId" });

User.hasMany(MealPlan, { foreignKey: "userId" });
MealPlan.belongsTo(User, { foreignKey: "userId" });

MealPlan.hasMany(MealPlanItem, { foreignKey: "mealPlanId" });
MealPlanItem.belongsTo(MealPlan, { foreignKey: "mealPlanId" });

export {
  User,
  HealthProfile,
  WaterIntake,
  FoodEntry,
  MealPlan,
  MealPlanItem,
  sequelize,
};
