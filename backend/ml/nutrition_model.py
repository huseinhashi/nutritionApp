import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import joblib
import os
import json
from typing import Dict, List, Optional, Tuple

class NutritionPredictor:
    def __init__(self, model_dir: str = "models"):
        self.model_dir = model_dir
        self.models = {}
        self.label_encoders = {}
        self.scaler = StandardScaler()
        self.feature_names = []
        self.is_trained = False
        
        # Nutrition targets to predict
        self.nutrition_targets = [
            'calories', 'protein', 'fat', 'carbohydrates', 'fiber',
            'vitamin_a', 'vitamin_c', 'vitamin_d', 'vitamin_e',
            'calcium', 'iron', 'potassium', 'sodium'
        ]
        
        # Create models directory if it doesn't exist
        os.makedirs(model_dir, exist_ok=True)
    
    def load_dataset(self, csv_path: str) -> pd.DataFrame:
        """Load and preprocess the nutrition dataset"""
        try:
            df = pd.read_csv(csv_path)
            print(f"Dataset loaded: {len(df)} records")
            print(f"Columns: {list(df.columns)}")
            return df
        except Exception as e:
            print(f"Error loading dataset: {e}")
            return None
    
    def preprocess_data(self, df: pd.DataFrame) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """Preprocess the data for training"""
        # Handle missing values
        df = df.fillna(0)
        
        # Convert portion_size to numeric, handling text descriptions
        if 'portion_size' in df.columns:
            df['portion_size'] = pd.to_numeric(df['portion_size'], errors='coerce').fillna(100)
        
        # Encode categorical variables
        categorical_columns = ['food_name', 'food_category', 'portion_unit']
        for col in categorical_columns:
            if col in df.columns:
                le = LabelEncoder()
                df[f'{col}_encoded'] = le.fit_transform(df[col].astype(str))
                self.label_encoders[col] = le
        
        # Select features for training
        feature_columns = [
            'portion_size', 'food_name_encoded', 'food_category_encoded', 
            'portion_unit_encoded'
        ]
        
        # Filter only available columns
        available_features = [col for col in feature_columns if col in df.columns]
        self.feature_names = available_features
        
        X = df[available_features]
        y = df[self.nutrition_targets]
        
        return X, y
    
    def train_models(self, csv_path: str) -> Dict[str, float]:
        """Train separate models for each nutrition target"""
        print("Loading and preprocessing dataset...")
        df = self.load_dataset(csv_path)
        if df is None:
            return {}
        
        X, y = self.preprocess_data(df)
        
        # Split the data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        results = {}
        
        print("Training models for each nutrition target...")
        for target in self.nutrition_targets:
            if target in y.columns:
                print(f"Training model for {target}...")
                
                # Train Random Forest model
                model = RandomForestRegressor(
                    n_estimators=100,
                    max_depth=10,
                    random_state=42,
                    n_jobs=-1
                )
                
                model.fit(X_train_scaled, y_train[target])
                
                # Make predictions
                y_pred = model.predict(X_test_scaled)
                
                # Calculate metrics
                mae = mean_absolute_error(y_test[target], y_pred)
                mse = mean_squared_error(y_test[target], y_pred)
                r2 = r2_score(y_test[target], y_pred)
                
                results[target] = {
                    'mae': mae,
                    'mse': mse,
                    'r2': r2
                }
                
                # Save model
                self.models[target] = model
                
                print(f"  {target}: MAE={mae:.2f}, R²={r2:.3f}")
        
        # Save scaler and label encoders
        self.save_models()
        self.is_trained = True
        
        return results
    
    def save_models(self):
        """Save trained models and preprocessing objects"""
        # Save models
        for target, model in self.models.items():
            model_path = os.path.join(self.model_dir, f"{target}_model.pkl")
            joblib.dump(model, model_path)
        
        # Save scaler
        scaler_path = os.path.join(self.model_dir, "scaler.pkl")
        joblib.dump(self.scaler, scaler_path)
        
        # Save label encoders
        encoders_path = os.path.join(self.model_dir, "label_encoders.pkl")
        joblib.dump(self.label_encoders, encoders_path)
        
        # Save feature names
        features_path = os.path.join(self.model_dir, "feature_names.json")
        with open(features_path, 'w') as f:
            json.dump(self.feature_names, f)
        
        print(f"Models saved to {self.model_dir}")
    
    def load_models(self) -> bool:
        """Load trained models and preprocessing objects"""
        try:
            # Load feature names
            features_path = os.path.join(self.model_dir, "feature_names.json")
            if os.path.exists(features_path):
                with open(features_path, 'r') as f:
                    self.feature_names = json.load(f)
            
            # Load scaler
            scaler_path = os.path.join(self.model_dir, "scaler.pkl")
            if os.path.exists(scaler_path):
                self.scaler = joblib.load(scaler_path)
            
            # Load label encoders
            encoders_path = os.path.join(self.model_dir, "label_encoders.pkl")
            if os.path.exists(encoders_path):
                self.label_encoders = joblib.load(encoders_path)
            
            # Load models
            for target in self.nutrition_targets:
                model_path = os.path.join(self.model_dir, f"{target}_model.pkl")
                if os.path.exists(model_path):
                    self.models[target] = joblib.load(model_path)
            
            self.is_trained = len(self.models) > 0
            print(f"Loaded {len(self.models)} models")
            return self.is_trained
            
        except Exception as e:
            print(f"Error loading models: {e}")
            return False
    
    def predict_nutrition(self, food_name: str, portion_size: float, 
                         food_category: str = "unknown", 
                         portion_unit: str = "g") -> Dict[str, float]:
        """Predict nutrition values for a given food and portion"""
        if not self.is_trained:
            print("Models not trained. Please train models first.")
            return {}
        
        try:
            # Prepare input data
            input_data = {
                'portion_size': portion_size,
                'food_name': food_name,
                'food_category': food_category,
                'portion_unit': portion_unit
            }
            
            # Encode categorical variables
            encoded_data = []
            for feature in self.feature_names:
                if 'portion_size' in feature:
                    encoded_data.append(portion_size)
                elif 'food_name_encoded' in feature:
                    le = self.label_encoders.get('food_name')
                    if le:
                        encoded_data.append(le.transform([food_name])[0])
                    else:
                        encoded_data.append(0)
                elif 'food_category_encoded' in feature:
                    le = self.label_encoders.get('food_category')
                    if le:
                        encoded_data.append(le.transform([food_category])[0])
                    else:
                        encoded_data.append(0)
                elif 'portion_unit_encoded' in feature:
                    le = self.label_encoders.get('portion_unit')
                    if le:
                        encoded_data.append(le.transform([portion_unit])[0])
                    else:
                        encoded_data.append(0)
                else:
                    encoded_data.append(0)
            
            # Scale features
            input_scaled = self.scaler.transform([encoded_data])
            
            # Make predictions
            predictions = {}
            for target in self.nutrition_targets:
                if target in self.models:
                    pred = self.models[target].predict(input_scaled)[0]
                    predictions[target] = max(0, pred)  # Ensure non-negative values
            
            return predictions
            
        except Exception as e:
            print(f"Error making prediction: {e}")
            return {}

def main():
    """Main function to train the model"""
    predictor = NutritionPredictor()
    
    # Train models using existing dataset
    dataset_path = "nutrition_dataset.csv"
    if not os.path.exists(dataset_path):
        print("❌ Dataset not found. Please run dataset_generator.py first to create the dataset.")
        return
    
    # Train models
    results = predictor.train_models(dataset_path)
    
    # Print results
    print("\nTraining Results:")
    for target, metrics in results.items():
        print(f"{target}: MAE={metrics['mae']:.2f}, R²={metrics['r2']:.3f}")
    
    # Test prediction
    test_prediction = predictor.predict_nutrition("apple", 150)
    print(f"\nTest prediction for 150g apple: {test_prediction}")

if __name__ == "__main__":
    main() 