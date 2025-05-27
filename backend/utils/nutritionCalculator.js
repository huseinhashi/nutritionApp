// Activity level multipliers
const ACTIVITY_MULTIPLIERS = {
  lightly_active: 1.375, // Light exercise 1-3 days/week
  moderately_active: 1.55, // Moderate exercise 3-5 days/week
  very_active: 1.725, // Hard exercise 6-7 days/week
};

// Base step counts for different activity levels
const BASE_STEPS = {
  lightly_active: 5000, // Base steps for lightly active
  moderately_active: 7500, // Base steps for moderately active
  very_active: 10000, // Base steps for very active
};

// Goal adjustments for steps (percentage of base steps)
const STEP_GOAL_ADJUSTMENTS = {
  weight_loss: 1.2, // 20% more steps for weight loss
  maintenance: 1.0, // No adjustment for maintenance
  muscle_gain: 0.9, // 10% less steps for muscle gain (focus on strength training)
};

// Age adjustments for steps (percentage of base steps)
const AGE_STEP_ADJUSTMENTS = {
  young: 1.0, // 13-30 years: no adjustment
  middle: 0.9, // 31-50 years: 10% reduction
  senior: 0.8, // 51+ years: 20% reduction
};

// Goal adjustments (percentage of maintenance calories)
const GOAL_ADJUSTMENTS = {
  weight_loss: 0.85, // 15% calorie deficit
  maintenance: 1.0, // No adjustment
  muscle_gain: 1.1, // 10% calorie surplus
};

// Calculate BMI (weight in kg / (height in m)²)
export const calculateBMI = (weight, height) => {
  const heightInMeters = height / 100;
  return Number((weight / (heightInMeters * heightInMeters)).toFixed(1));
};

// Calculate daily water intake in ml (30ml per kg of body weight)
const calculateDailyWater = (weight) => {
  return Math.round(weight * 30);
};

// Calculate daily step goal based on profile data
const calculateDailySteps = ({ age, activityLevel, goal }) => {
  // Get base steps for activity level
  let baseSteps = BASE_STEPS[activityLevel];

  // Apply goal adjustment
  baseSteps *= STEP_GOAL_ADJUSTMENTS[goal];

  // Apply age adjustment
  let ageAdjustment;
  if (age <= 30) {
    ageAdjustment = AGE_STEP_ADJUSTMENTS.young;
  } else if (age <= 50) {
    ageAdjustment = AGE_STEP_ADJUSTMENTS.middle;
  } else {
    ageAdjustment = AGE_STEP_ADJUSTMENTS.senior;
  }
  baseSteps *= ageAdjustment;

  // Round to nearest 500 steps
  return Math.round(baseSteps / 500) * 500;
};

export const calculateDailyCalories = ({
  age,
  gender,
  weight,
  height,
  goal,
  activityLevel,
}) => {
  // Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
  let bmr;
  if (gender === "male") {
    bmr = 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    bmr = 10 * weight + 6.25 * height - 5 * age - 161;
  }

  // Calculate Total Daily Energy Expenditure (TDEE)
  const tdee = bmr * ACTIVITY_MULTIPLIERS[activityLevel];

  // Apply goal adjustment
  const dailyCalories = Math.round(tdee * GOAL_ADJUSTMENTS[goal]);

  // Calculate daily water intake
  const dailyWaterMl = calculateDailyWater(weight);

  // Calculate BMI
  const bmi = calculateBMI(weight, height);

  // Calculate daily steps
  const dailySteps = calculateDailySteps({ age, activityLevel, goal });

  return {
    dailyCalories,
    dailyWaterMl,
    bmi,
    dailySteps,
  };
};
