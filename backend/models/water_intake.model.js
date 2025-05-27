import { DataTypes } from "sequelize";
import sequelize from "../database/connection.js";

const WaterIntake = sequelize.define(
  "WaterIntake",
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
    intakeAmount: {
      type: DataTypes.FLOAT,
      allowNull: false,
      validate: {
        min: 0,
      },
    },
    intakeDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: "water_intake",
    timestamps: true,
    indexes: [
      {
        fields: ["userId", "intakeDate"],
      },
    ],
  }
);

export default WaterIntake;
