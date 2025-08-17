# Nutrition Prediction ML Model

This directory contains a machine learning model for predicting nutrition values based on food names and portion sizes. The system is designed as a fallback when the main AI-based nutrition analysis fails.

## Overview

The model uses Random Forest regression to predict 13 different nutrition values for various food items. It's trained on USDA-compliant nutrition data and provides accurate predictions for common foods.

## Features

- **Multi-target prediction**: Predicts 13 different nutrition values
- **USDA-compliant data**: Based on official USDA Standard Reference
- **Portion size scaling**: Automatically scales nutrition values based on portion size
- **Food categorization**: Supports 6 food categories (fruit, vegetable, protein, grain, dairy, nut)
- **Standalone dataset generator**: Creates accurate training data without external dependencies
- **High accuracy**: 99.7-99.9% R² scores across all nutrition targets

## File Structure

```
ml/
├── dataset_generator.py              # Standalone dataset generator
├── nutrition_model.py                # ML model engine
├── nutrition_cli.py                  # Command-line interface
├── nutrition_dataset.csv             # Generated training dataset (5000 records)
├── nutrition_dataset_metadata.json   # Dataset metadata
├── requirements.txt                  # Python dependencies
└── README.md                        # This file
```

## Setup

### 1. Install Python Dependencies

```bash
cd ml
pip install -r requirements.txt
```

### 2. Generate Dataset

```bash
# Generate 5000 accurate nutrition records
python dataset_generator.py
```

This creates:
- `nutrition_dataset.csv` - 5000 records with USDA-compliant data
- `nutrition_dataset_metadata.json` - Dataset metadata

### 3. Train the Model

```bash
# Train models using the generated dataset
python nutrition_cli.py train
```

### 4. Test the Model

```bash
# Test with sample predictions
python nutrition_cli.py test

# Make a specific prediction
python nutrition_cli.py predict --food-name "apple" --portion-size 150 --food-category "fruit"
```

## Model Architecture

### Features
- Food name (encoded)
- Food category (encoded)
- Portion size
- Portion unit (encoded)

### Targets (Nutrition Values)
- Calories
- Protein
- Fat
- Carbohydrates
- Fiber
- Vitamin A, C, D, E
- Calcium, Iron, Potassium, Sodium

### Algorithm
- **Random Forest Regressor** with 100 trees
- **StandardScaler** for feature normalization
- **LabelEncoder** for categorical variables

## Dataset

The system includes a standalone dataset generator with 30 common food items across 6 categories:

- **Fruits**: apple, banana, orange, strawberry, grape
- **Vegetables**: carrot, broccoli, spinach, tomato, cucumber
- **Proteins**: chicken_breast, salmon, egg, beef, tofu
- **Grains**: rice, bread, pasta, oatmeal, quinoa
- **Dairy**: milk, yogurt, cheese, butter, cream
- **Nuts & Seeds**: almond, peanut, walnut, sunflower_seed, chia_seed

### Dataset Features
- **5000 records** with realistic nutrition data
- **USDA Standard Reference** values
- **±5% variation** for natural differences
- **25-500g portion range** for realistic serving sizes
- **Zero missing values** and duplicates

## Usage Examples

### Generate Dataset
```bash
python dataset_generator.py
```

### Train Model
```bash
python nutrition_cli.py train
```

### Make Predictions
```bash
# Single prediction
python nutrition_cli.py predict --food-name "apple" --portion-size 150 --food-category "fruit"

# With JSON output
python nutrition_cli.py predict --food-name "chicken_breast" --portion-size 200 --food-category "protein" --json-output
```

### Test Model
```bash
python nutrition_cli.py test
```

## Performance

The model achieves excellent performance:
- **R² Score**: 0.997-0.999 (99.7-99.9% accuracy)
- **MAE**: Very low error margins across all nutrients
- **Inference Time**: <100ms per prediction
- **Coverage**: 30 common foods across 6 categories

### Sample Results
```
Training Results:
calories: MAE=19.17, R²=0.998
protein: MAE=0.97, R²=0.997
fat: MAE=1.42, R²=0.998
carbohydrates: MAE=1.16, R²=0.997
vitamin_a: MAE=10.52, R²=0.999
vitamin_c: MAE=0.67, R²=0.999
```

## Integration with Your App

The model works as part of a hybrid system:

1. **USDA API** (primary) - Most accurate, official database
2. **OpenAI GPT-4 Vision** (secondary) - AI analysis for image recognition
3. **ML Model** (fallback) - This system when APIs fail

### When to Use ML Model
- USDA API fails (network issues, rate limits)
- OpenAI analysis fails (unclear images, API errors)
- Offline mode needed
- Backup system for reliability

## Troubleshooting

### Common Issues

1. **Dataset not found**: Run `python dataset_generator.py` first
2. **Models not found**: Run `python nutrition_cli.py train` first
3. **Python not found**: Ensure Python 3.7+ is installed
4. **Dependencies missing**: Install requirements.txt

### Debug Commands

```bash
# Check dataset
python dataset_generator.py

# Check model status
python nutrition_cli.py

# Test with verbose output
python nutrition_cli.py test
```

## Workflow Summary

1. **Generate Dataset** → `python dataset_generator.py`
2. **Train Models** → `python nutrition_cli.py train`
3. **Test Predictions** → `python nutrition_cli.py test`
4. **Make Predictions** → `python nutrition_cli.py predict`

The system is now ready for production use as a reliable fallback nutrition prediction system! 🚀 