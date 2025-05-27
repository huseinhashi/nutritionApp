import { DataTypes } from "sequelize";
import sequelize from "../database/connection.js";

const MealPlan = sequelize.define(
  "MealPlan",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    goal: {
      type: DataTypes.ENUM("weight_loss", "maintenance", "muscle_gain"),
      allowNull: false,
    },
    startDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    endDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
  },
  {
    tableName: "meal_plans",
  }
);

export default MealPlan;
