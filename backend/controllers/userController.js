import { User } from "../models/index.js";
import jwt from "jsonwebtoken";
import { JWT_SECRET } from "../config/env.js";
import { userSchema, loginSchema } from "../validators/validator.js";

// Generate JWT token
const generateToken = (user) => {
  return jwt.sign(
    {
      user_id: user.id,
    },
    JWT_SECRET,
    { expiresIn: "7d" }
  );
};

// Register a new user
export const registerUser = async (req, res, next) => {
  try {
    // Validate request body
    const validatedData = userSchema.parse(req.body);

    // Check if username already exists
    const existingUsername = await User.findOne({
      where: { username: validatedData.username },
    });
    if (existingUsername) {
      return res.status(400).json({
        success: false,
        message: "Username already in use",
      });
    }

    // Check if phone number already exists
    const existingPhone = await User.findOne({
      where: { phone: validatedData.phone },
    });
    if (existingPhone) {
      return res.status(400).json({
        success: false,
        message: "Phone number already in use",
      });
    }

    // Create new user
    const newUser = await User.create(validatedData);

    // Generate JWT token
    const authToken = generateToken(newUser);

    // Return user without password
    const userWithoutPassword = {
      ...newUser.get(),
      password: undefined,
    };

    res.status(201).json({
      success: true,
      data: {
        user: userWithoutPassword,
        authToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

// User login
export const loginUser = async (req, res, next) => {
  try {
    // Validate login data
    const validatedData = loginSchema.parse(req.body);

    // Find user by phone
    const user = await User.findOne({ where: { phone: validatedData.phone } });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password",
      });
    }

    // Check password
    const isPasswordValid = await user.validPassword(validatedData.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid phone number or password",
      });
    }

    // Generate JWT token
    const authToken = generateToken(user);

    // Return user without password
    const userWithoutPassword = {
      ...user.get(),
      password: undefined,
    };

    res.json({
      success: true,
      data: {
        user: userWithoutPassword,
        authToken,
      },
    });
  } catch (error) {
    next(error);
  }
};
