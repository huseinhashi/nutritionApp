#!/usr/bin/env python3
"""
CLI interface for the Nutrition Predictor model
Usage: python nutrition_cli.py [command] [options]
"""

import sys
import json
import argparse
from nutrition_model import NutritionPredictor
import os

def train_model(args):
    """Train the nutrition prediction model"""
    predictor = NutritionPredictor()
    
    # Use existing dataset
    dataset_path = args.dataset_path
    
    # Check if dataset exists
    if not os.path.exists(dataset_path):
        print(f"❌ Dataset not found: {dataset_path}")
        print("💡 Please run dataset_generator.py first to create the dataset.")
        return {}
    
    # Train models
    print("Training nutrition prediction models...")
    results = predictor.train_models(dataset_path)
    
    # Print results
    print("\nTraining Results:")
    for target, metrics in results.items():
        print(f"{target}: MAE={metrics['mae']:.2f}, R²={metrics['r2']:.3f}")
    
    return results

def predict_nutrition(args):
    """Make nutrition predictions"""
    predictor = NutritionPredictor()
    
    # Load trained models
    if not predictor.load_models():
        print("Error: No trained models found. Please train models first.")
        return None
    
    # Make prediction
    prediction = predictor.predict_nutrition(
        food_name=args.food_name,
        portion_size=args.portion_size,
        food_category=args.food_category,
        portion_unit=args.portion_unit
    )
    
    if prediction:
        print(f"Nutrition prediction for {args.portion_size}{args.portion_unit} of {args.food_name}:")
        for nutrient, value in prediction.items():
            print(f"  {nutrient}: {value:.1f}")
        
        # Return JSON for API integration
        if args.json_output:
            print(json.dumps(prediction, indent=2))
    
    return prediction

def test_model(args):
    """Test the model with sample predictions"""
    predictor = NutritionPredictor()
    
    # Load trained models
    if not predictor.load_models():
        print("Error: No trained models found. Please train models first.")
        return
    
    # Test cases
    test_cases = [
        ("apple", 150, "fruit"),
        ("chicken_breast", 200, "protein"),
        ("rice", 100, "grain"),
        ("broccoli", 120, "vegetable"),
        ("bariis", 250, "grain")
    ]
    
    print("Testing nutrition predictions:")
    print("-" * 50)
    
    for food_name, portion_size, category in test_cases:
        prediction = predictor.predict_nutrition(food_name, portion_size, category)
        if prediction:
            print(f"\n{portion_size}g of {food_name} ({category}):")
            for nutrient, value in prediction.items():
                print(f"  {nutrient}: {value:.1f}")

def main():
    parser = argparse.ArgumentParser(description="Nutrition Prediction Model CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Train command
    train_parser = subparsers.add_parser("train", help="Train the nutrition prediction model")
    train_parser.add_argument("--dataset-path", default="nutrition_dataset.csv", 
                             help="Path to the training dataset")
    
    # Predict command
    predict_parser = subparsers.add_parser("predict", help="Make nutrition predictions")
    predict_parser.add_argument("--food-name", required=True, help="Name of the food")
    predict_parser.add_argument("--portion-size", type=float, required=True, 
                               help="Portion size")
    predict_parser.add_argument("--food-category", default="unknown", 
                               help="Food category")
    predict_parser.add_argument("--portion-unit", default="g", help="Portion unit")
    predict_parser.add_argument("--json-output", action="store_true",
                               help="Output results in JSON format")
    
    # Test command
    test_parser = subparsers.add_parser("test", help="Test the model with sample predictions")
    
    args = parser.parse_args()
    
    if args.command == "train":
        train_model(args)
    elif args.command == "predict":
        predict_nutrition(args)
    elif args.command == "test":
        test_model(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main() 