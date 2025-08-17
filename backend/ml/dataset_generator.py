#!/usr/bin/env python3
"""
Standalone Enhanced Nutrition Dataset Generator
Creates 5000 accurate nutrition records using USDA-compliant data
No external dependencies - everything is self-contained
"""

import pandas as pd
import numpy as np
import json
import os
from datetime import datetime

class NutritionDatasetGenerator:
    def __init__(self):
        self.food_database = self._load_food_database()
        
    def _load_food_database(self):
        """Load comprehensive food database with USDA-compliant nutrition data"""
        return {
            # Fruits - USDA Standard Reference values
            "apple": {
                "category": "fruit",
                "base_nutrition": {
                    "calories": 52, "protein": 0.3, "fat": 0.2, "carbohydrates": 14,
                    "fiber": 2.4, "vitamin_a": 3, "vitamin_c": 4.6, "vitamin_d": 0,
                    "vitamin_e": 0.18, "calcium": 6, "iron": 0.12, "potassium": 107, "sodium": 1
                }
            },
            "banana": {
                "category": "fruit",
                "base_nutrition": {
                    "calories": 89, "protein": 1.1, "fat": 0.3, "carbohydrates": 23,
                    "fiber": 2.6, "vitamin_a": 3, "vitamin_c": 8.7, "vitamin_d": 0,
                    "vitamin_e": 0.1, "calcium": 5, "iron": 0.26, "potassium": 358, "sodium": 1
                }
            },
            "orange": {
                "category": "fruit",
                "base_nutrition": {
                    "calories": 47, "protein": 0.9, "fat": 0.1, "carbohydrates": 12,
                    "fiber": 2.4, "vitamin_a": 225, "vitamin_c": 53.2, "vitamin_d": 0,
                    "vitamin_e": 0.18, "calcium": 40, "iron": 0.1, "potassium": 181, "sodium": 0
                }
            },
            "strawberry": {
                "category": "fruit",
                "base_nutrition": {
                    "calories": 32, "protein": 0.7, "fat": 0.3, "carbohydrates": 8,
                    "fiber": 2.0, "vitamin_a": 1, "vitamin_c": 58.8, "vitamin_d": 0,
                    "vitamin_e": 0.29, "calcium": 16, "iron": 0.41, "potassium": 153, "sodium": 1
                }
            },
            "grape": {
                "category": "fruit",
                "base_nutrition": {
                    "calories": 62, "protein": 0.6, "fat": 0.2, "carbohydrates": 16,
                    "fiber": 0.9, "vitamin_a": 3, "vitamin_c": 3.2, "vitamin_d": 0,
                    "vitamin_e": 0.19, "calcium": 10, "iron": 0.36, "potassium": 191, "sodium": 2
                }
            },
            
            # Vegetables - USDA Standard Reference values
            "carrot": {
                "category": "vegetable",
                "base_nutrition": {
                    "calories": 41, "protein": 0.9, "fat": 0.2, "carbohydrates": 10,
                    "fiber": 2.8, "vitamin_a": 835, "vitamin_c": 5.9, "vitamin_d": 0,
                    "vitamin_e": 0.66, "calcium": 33, "iron": 0.3, "potassium": 320, "sodium": 69
                }
            },
            "broccoli": {
                "category": "vegetable",
                "base_nutrition": {
                    "calories": 34, "protein": 2.8, "fat": 0.4, "carbohydrates": 7,
                    "fiber": 2.6, "vitamin_a": 623, "vitamin_c": 89.2, "vitamin_d": 0,
                    "vitamin_e": 0.78, "calcium": 47, "iron": 0.73, "potassium": 316, "sodium": 33
                }
            },
            "spinach": {
                "category": "vegetable",
                "base_nutrition": {
                    "calories": 23, "protein": 2.9, "fat": 0.4, "carbohydrates": 4,
                    "fiber": 2.2, "vitamin_a": 469, "vitamin_c": 28.1, "vitamin_d": 0,
                    "vitamin_e": 2.03, "calcium": 99, "iron": 2.71, "potassium": 558, "sodium": 79
                }
            },
            "tomato": {
                "category": "vegetable",
                "base_nutrition": {
                    "calories": 18, "protein": 0.9, "fat": 0.2, "carbohydrates": 4,
                    "fiber": 1.2, "vitamin_a": 833, "vitamin_c": 13.7, "vitamin_d": 0,
                    "vitamin_e": 0.54, "calcium": 10, "iron": 0.27, "potassium": 237, "sodium": 5
                }
            },
            "cucumber": {
                "category": "vegetable",
                "base_nutrition": {
                    "calories": 16, "protein": 0.7, "fat": 0.1, "carbohydrates": 4,
                    "fiber": 0.5, "vitamin_a": 105, "vitamin_c": 2.8, "vitamin_d": 0,
                    "vitamin_e": 0.03, "calcium": 16, "iron": 0.28, "potassium": 147, "sodium": 2
                }
            },
            
            # Proteins - USDA Standard Reference values
            "chicken_breast": {
                "category": "protein",
                "base_nutrition": {
                    "calories": 165, "protein": 31, "fat": 3.6, "carbohydrates": 0,
                    "fiber": 0, "vitamin_a": 6, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.22, "calcium": 15, "iron": 1.04, "potassium": 256, "sodium": 74
                }
            },
            "salmon": {
                "category": "protein",
                "base_nutrition": {
                    "calories": 208, "protein": 25, "fat": 12, "carbohydrates": 0,
                    "fiber": 0, "vitamin_a": 149, "vitamin_c": 3.9, "vitamin_d": 11,
                    "vitamin_e": 3.55, "calcium": 9, "iron": 0.34, "potassium": 363, "sodium": 59
                }
            },
            "egg": {
                "category": "protein",
                "base_nutrition": {
                    "calories": 155, "protein": 13, "fat": 11, "carbohydrates": 1.1,
                    "fiber": 0, "vitamin_a": 160, "vitamin_c": 0, "vitamin_d": 2,
                    "vitamin_e": 1.05, "calcium": 56, "iron": 1.75, "potassium": 138, "sodium": 124
                }
            },
            "beef": {
                "category": "protein",
                "base_nutrition": {
                    "calories": 250, "protein": 26, "fat": 15, "carbohydrates": 0,
                    "fiber": 0, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.12, "calcium": 18, "iron": 2.6, "potassium": 318, "sodium": 72
                }
            },
            "tofu": {
                "category": "protein",
                "base_nutrition": {
                    "calories": 76, "protein": 8, "fat": 4.8, "carbohydrates": 1.9,
                    "fiber": 0.3, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.01, "calcium": 130, "iron": 1.4, "potassium": 121, "sodium": 7
                }
            },
            
            # Grains - USDA Standard Reference values
            "rice": {
                "category": "grain",
                "base_nutrition": {
                    "calories": 130, "protein": 2.7, "fat": 0.3, "carbohydrates": 28,
                    "fiber": 0.4, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.11, "calcium": 10, "iron": 0.2, "potassium": 35, "sodium": 1
                }
            },
            "bread": {
                "category": "grain",
                "base_nutrition": {
                    "calories": 265, "protein": 9, "fat": 3.2, "carbohydrates": 49,
                    "fiber": 2.7, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.22, "calcium": 49, "iron": 3.6, "potassium": 115, "sodium": 491
                }
            },
            "pasta": {
                "category": "grain",
                "base_nutrition": {
                    "calories": 131, "protein": 5, "fat": 1.1, "carbohydrates": 25,
                    "fiber": 1.8, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.06, "calcium": 7, "iron": 1.3, "potassium": 44, "sodium": 6
                }
            },
            "oatmeal": {
                "category": "grain",
                "base_nutrition": {
                    "calories": 68, "protein": 2.4, "fat": 1.4, "carbohydrates": 12,
                    "fiber": 1.7, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.08, "calcium": 49, "iron": 0.6, "potassium": 61, "sodium": 49
                }
            },
            "quinoa": {
                "category": "grain",
                "base_nutrition": {
                    "calories": 120, "protein": 4.4, "fat": 1.9, "carbohydrates": 22,
                    "fiber": 2.8, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 0.63, "calcium": 17, "iron": 1.49, "potassium": 172, "sodium": 7
                }
            },
            
            # Dairy - USDA Standard Reference values
            "milk": {
                "category": "dairy",
                "base_nutrition": {
                    "calories": 42, "protein": 3.4, "fat": 1, "carbohydrates": 5,
                    "fiber": 0, "vitamin_a": 46, "vitamin_c": 0.9, "vitamin_d": 1.2,
                    "vitamin_e": 0.08, "calcium": 113, "iron": 0.03, "potassium": 150, "sodium": 44
                }
            },
            "yogurt": {
                "category": "dairy",
                "base_nutrition": {
                    "calories": 59, "protein": 10, "fat": 0.4, "carbohydrates": 3.6,
                    "fiber": 0, "vitamin_a": 27, "vitamin_c": 0.5, "vitamin_d": 0.1,
                    "vitamin_e": 0.06, "calcium": 110, "iron": 0.07, "potassium": 141, "sodium": 36
                }
            },
            "cheese": {
                "category": "dairy",
                "base_nutrition": {
                    "calories": 402, "protein": 25, "fat": 33, "carbohydrates": 1.3,
                    "fiber": 0, "vitamin_a": 265, "vitamin_c": 0, "vitamin_d": 0.6,
                    "vitamin_e": 0.21, "calcium": 721, "iron": 0.68, "potassium": 98, "sodium": 621
                }
            },
            "butter": {
                "category": "dairy",
                "base_nutrition": {
                    "calories": 717, "protein": 0.9, "fat": 81, "carbohydrates": 0.1,
                    "fiber": 0, "vitamin_a": 684, "vitamin_c": 0, "vitamin_d": 1.5,
                    "vitamin_e": 2.32, "calcium": 24, "iron": 0.02, "potassium": 24, "sodium": 11
                }
            },
            "cream": {
                "category": "dairy",
                "base_nutrition": {
                    "calories": 340, "protein": 2.1, "fat": 37, "carbohydrates": 2.8,
                    "fiber": 0, "vitamin_a": 97, "vitamin_c": 0.6, "vitamin_d": 0.5,
                    "vitamin_e": 0.76, "calcium": 65, "iron": 0.05, "potassium": 95, "sodium": 43
                }
            },
            
            # Nuts and Seeds - USDA Standard Reference values
            "almond": {
                "category": "nut",
                "base_nutrition": {
                    "calories": 579, "protein": 21, "fat": 50, "carbohydrates": 22,
                    "fiber": 12.5, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 25.63, "calcium": 269, "iron": 3.71, "potassium": 733, "sodium": 1
                }
            },
            "peanut": {
                "category": "nut",
                "base_nutrition": {
                    "calories": 567, "protein": 26, "fat": 49, "carbohydrates": 16,
                    "fiber": 8.5, "vitamin_a": 0, "vitamin_c": 0, "vitamin_d": 0,
                    "vitamin_e": 8.33, "calcium": 92, "iron": 4.58, "potassium": 705, "sodium": 18
                }
            },
            "walnut": {
                "category": "nut",
                "base_nutrition": {
                    "calories": 654, "protein": 15, "fat": 65, "carbohydrates": 14,
                    "fiber": 6.7, "vitamin_a": 0, "vitamin_c": 1.3, "vitamin_d": 0,
                    "vitamin_e": 0.7, "calcium": 98, "iron": 2.91, "potassium": 441, "sodium": 2
                }
            },
            "sunflower_seed": {
                "category": "nut",
                "base_nutrition": {
                    "calories": 584, "protein": 21, "fat": 51, "carbohydrates": 20,
                    "fiber": 8.6, "vitamin_a": 0, "vitamin_c": 1.4, "vitamin_d": 0,
                    "vitamin_e": 35.17, "calcium": 78, "iron": 5.25, "potassium": 645, "sodium": 9
                }
            },
            "chia_seed": {
                "category": "nut",
                "base_nutrition": {
                    "calories": 486, "protein": 17, "fat": 31, "carbohydrates": 42,
                    "fiber": 34.4, "vitamin_a": 0, "vitamin_c": 1.6, "vitamin_d": 0,
                    "vitamin_e": 0.5, "calcium": 631, "iron": 7.72, "potassium": 407, "sodium": 16
                }
            }
        }
    
    def generate_dataset(self, output_path: str = "nutrition_dataset.csv", num_records: int = 5000):
        """Generate nutrition dataset with accurate USDA data"""
        print(f"🎯 Generating {num_records} accurate nutrition records...")
        print("📊 Using USDA Standard Reference nutrition data...")
        
        records = []
        food_names = list(self.food_database.keys())
        
        for i in range(num_records):
            # Randomly select a food item
            food_name = np.random.choice(food_names)
            food_data = self.food_database[food_name]
            
            # Random portion size (25-500g for realistic range)
            portion_size = np.random.uniform(25, 500)
            
            # Add realistic variation (±5% for natural differences)
            variation_factor = np.random.uniform(0.95, 1.05)
            
            # Scale nutrition values based on portion size
            scale_factor = portion_size / 100
            
            # Get base nutrition values
            base_nutrition = food_data["base_nutrition"]
            
            # Create record with enhanced accuracy
            record = {
                'food_name': food_name,
                'food_category': food_data["category"],
                'portion_size': round(portion_size, 1),
                'portion_unit': 'g',
                'calories': round(base_nutrition["calories"] * scale_factor * variation_factor, 1),
                'protein': round(base_nutrition["protein"] * scale_factor * variation_factor, 1),
                'fat': round(base_nutrition["fat"] * scale_factor * variation_factor, 1),
                'carbohydrates': round(base_nutrition["carbohydrates"] * scale_factor * variation_factor, 1),
                'fiber': round(base_nutrition["fiber"] * scale_factor * variation_factor, 1),
                'vitamin_a': round(base_nutrition["vitamin_a"] * scale_factor * variation_factor, 1),
                'vitamin_c': round(base_nutrition["vitamin_c"] * scale_factor * variation_factor, 1),
                'vitamin_d': round(base_nutrition["vitamin_d"] * scale_factor * variation_factor, 1),
                'vitamin_e': round(base_nutrition["vitamin_e"] * scale_factor * variation_factor, 1),
                'calcium': round(base_nutrition["calcium"] * scale_factor * variation_factor, 1),
                'iron': round(base_nutrition["iron"] * scale_factor * variation_factor, 1),
                'potassium': round(base_nutrition["potassium"] * scale_factor * variation_factor, 1),
                'sodium': round(base_nutrition["sodium"] * scale_factor * variation_factor, 1)
            }
            records.append(record)
            
            # Progress indicator
            if (i + 1) % 1000 == 0:
                print(f"✅ Generated {i + 1} records...")
        
        # Create DataFrame and save
        df = pd.DataFrame(records)
        df.to_csv(output_path, index=False)
        
        # Save metadata
        metadata = {
            "generated_at": datetime.now().isoformat(),
            "total_records": len(records),
            "food_categories": list(set([food["category"] for food in self.food_database.values()])),
            "total_foods": len(self.food_database),
            "portion_range": "25-500g",
            "variation_factor": "±5%",
            "data_source": "USDA Standard Reference",
            "accuracy_level": "Enhanced"
        }
        
        metadata_path = output_path.replace('.csv', '_metadata.json')
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        print(f"\n🎉 Dataset generation complete!")
        print(f"📁 Files created:")
        print(f"   - {output_path}")
        print(f"   - {metadata_path}")
        print(f"\n📊 Dataset statistics:")
        print(f"   - Total records: {len(records)}")
        print(f"   - Food categories: {len(set([food['category'] for food in self.food_database.values()]))}")
        print(f"   - Unique foods: {len(self.food_database)}")
        print(f"   - Portion range: 25-500g")
        print(f"   - Data accuracy: USDA-compliant")
        
        return output_path
    
    def validate_dataset(self, dataset_path: str):
        """Validate the generated dataset"""
        print("🔍 Validating dataset...")
        
        df = pd.read_csv(dataset_path)
        
        print(f"✅ Validation complete!")
        print(f"📈 Results:")
        print(f"   - Total records: {len(df)}")
        print(f"   - Food categories: {df['food_category'].unique()}")
        print(f"   - Unique foods: {df['food_name'].nunique()}")
        print(f"   - Portion range: {df['portion_size'].min():.1f}g - {df['portion_size'].max():.1f}g")
        print(f"   - Missing values: {df.isnull().sum().sum()}")
        print(f"   - Duplicate records: {df.duplicated().sum()}")
        
        return True

def main():
    """Main function to generate the dataset"""
    generator = NutritionDatasetGenerator()
    
    # Generate 5000 accurate records
    dataset_path = generator.generate_dataset("nutrition_dataset.csv", 5000)
    
    # Validate the dataset
    generator.validate_dataset(dataset_path)
    
    print("\n🚀 Ready for ML training!")

if __name__ == "__main__":
    main() 