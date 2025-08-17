import { DataTypes } from "sequelize";
import sequelize from "../database/connection.js";

const FoodEntry = sequelize.define(
  "FoodEntry",
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
    foodName: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    foodNameSomali: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    calories: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    protein: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      get() {
        const value = this.getDataValue("protein");
        return value ? parseFloat(value) : 0;
      },
    },
    fat: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      get() {
        const value = this.getDataValue("fat");
        return value ? parseFloat(value) : 0;
      },
    },
    carbohydrates: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      get() {
        const value = this.getDataValue("carbohydrates");
        return value ? parseFloat(value) : 0;
      },
    },
    vitaminA: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      get() {
        const value = this.getDataValue("vitaminA");
        return value ? parseFloat(value) : 0;
      },
    },
    vitaminC: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      get() {
        const value = this.getDataValue("vitaminC");
        return value ? parseFloat(value) : 0;
      },
    },
    calcium: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      get() {
        const value = this.getDataValue("calcium");
        return value ? parseFloat(value) : 0;
      },
    },
    iron: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
      get() {
        const value = this.getDataValue("iron");
        return value ? parseFloat(value) : 0;
      },
    },
    portionSize: {
      type: DataTypes.STRING(50),
      allowNull: true,
      defaultValue: "N/A",
    },
    imagePath: {
      type: DataTypes.STRING(500),
      allowNull: true,
      defaultValue: null,
    },
  },
  {
    tableName: "food_entries",
    hooks: {
      beforeCreate: (instance) => {
        // Ensure numeric values are stored as numbers
        instance.protein = parseFloat(instance.protein) || 0;
        instance.fat = parseFloat(instance.fat) || 0;
        instance.carbohydrates = parseFloat(instance.carbohydrates) || 0;
        instance.vitaminA = parseFloat(instance.vitaminA) || 0;
        instance.vitaminC = parseFloat(instance.vitaminC) || 0;
        instance.calcium = parseFloat(instance.calcium) || 0;
        instance.iron = parseFloat(instance.iron) || 0;
      },
      beforeUpdate: (instance) => {
        // Ensure numeric values are stored as numbers
        instance.protein = parseFloat(instance.protein) || 0;
        instance.fat = parseFloat(instance.fat) || 0;
        instance.carbohydrates = parseFloat(instance.carbohydrates) || 0;
        instance.vitaminA = parseFloat(instance.vitaminA) || 0;
        instance.vitaminC = parseFloat(instance.vitaminC) || 0;
        instance.calcium = parseFloat(instance.calcium) || 0;
        instance.iron = parseFloat(instance.iron) || 0;
      },
    },
  }
);

export default FoodEntry;
