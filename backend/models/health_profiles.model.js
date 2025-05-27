import { DataTypes } from "sequelize";
import sequelize from "../database/connection.js";

const HealthProfile = sequelize.define(
  "HealthProfile",
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
    age: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 13,
        max: 120,
      },
    },
    gender: {
      type: DataTypes.ENUM("male", "female"),
      allowNull: false,
    },
    weight: {
      type: DataTypes.FLOAT,
      allowNull: false,
      validate: {
        min: 20,
        max: 300,
      },
    },
    height: {
      type: DataTypes.FLOAT,
      allowNull: false,
      validate: {
        min: 100,
        max: 250,
      },
    },
    bmi: {
      type: DataTypes.FLOAT,
      allowNull: false,
      validate: {
        min: 10,
        max: 50,
      },
    },
    goal: {
      type: DataTypes.ENUM("weight_loss", "maintenance", "muscle_gain"),
      allowNull: false,
    },
    activityLevel: {
      type: DataTypes.ENUM(
        "lightly_active",
        "moderately_active",
        "very_active"
      ),
      allowNull: false,
    },
    dailyCalories: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    dailyWaterMl: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 2500, // Default to 2.5L
    },
    dailySteps: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 2000,
        max: 20000,
      },
    },
  },
  {
    tableName: "health_profiles",
    timestamps: true,
    indexes: [
      {
        unique: true,
        fields: ["userId"],
      },
    ],
  }
);

export default HealthProfile;
