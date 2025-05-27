import { DataTypes } from "sequelize";
import sequelize from "../database/connection.js";

const MealPlanItem = sequelize.define(
  "MealPlanItem",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    mealPlanId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    foodName: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    mealType: {
      type: DataTypes.ENUM("breakfast", "lunch", "dinner", "snack"),
      allowNull: false,
    },
    dayOfWeek: {
      type: DataTypes.ENUM(
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday"
      ),
      allowNull: false,
    },
    serving_size: {
      type: DataTypes.FLOAT,
      allowNull: false,
    },
    serving_unit: {
      type: DataTypes.STRING(20),
      allowNull: false,
    },
  },
  {
    tableName: "meal_plan_items",
  }
);

export default MealPlanItem;
