import { spawn } from 'child_process';
import path from 'path';
import fs from 'fs';

class MLNutritionService {
    constructor() {
        this.mlPath = path.join(process.cwd(), 'ml');
        this.modelsDir = path.join(this.mlPath, 'models');
        this.datasetPath = path.join(this.mlPath, 'nutrition_dataset.csv');
    }

    /**
     * Check if ML models are trained and available
     */
    async checkModelsStatus() {
        try {
            // Check if models directory exists and has model files
            if (!fs.existsSync(this.modelsDir)) {
                return { available: false, reason: 'Models directory not found' };
            }

            const modelFiles = fs.readdirSync(this.modelsDir);
            const requiredModels = [
                'calories_model.pkl',
                'protein_model.pkl',
                'fat_model.pkl',
                'carbohydrates_model.pkl',
                'fiber_model.pkl',
                'vitamin_a_model.pkl',
                'vitamin_c_model.pkl',
                'vitamin_d_model.pkl',
                'vitamin_e_model.pkl',
                'calcium_model.pkl',
                'iron_model.pkl',
                'potassium_model.pkl',
                'sodium_model.pkl',
                'scaler.pkl',
                'label_encoders.pkl',
                'feature_names.json'
            ];

            const missingModels = requiredModels.filter(model => !modelFiles.includes(model));
            
            if (missingModels.length > 0) {
                return { 
                    available: false, 
                    reason: `Missing model files: ${missingModels.join(', ')}` 
                };
            }

            return { available: true };
        } catch (error) {
            return { available: false, reason: `Error checking models: ${error.message}` };
        }
    }

    /**
     * Train ML models if not already trained
     */
    async trainModels() {
        return new Promise((resolve, reject) => {
            console.log('🤖 Training ML nutrition models...');
            
            const trainProcess = spawn('python', ['nutrition_cli.py', 'train'], {
                cwd: this.mlPath,
                stdio: 'pipe'
            });

            let output = '';
            let errorOutput = '';

            trainProcess.stdout.on('data', (data) => {
                output += data.toString();
                console.log('ML Training:', data.toString().trim());
            });

            trainProcess.stderr.on('data', (data) => {
                errorOutput += data.toString();
                console.error('ML Training Error:', data.toString().trim());
            });

            trainProcess.on('close', (code) => {
                if (code === 0) {
                    console.log('✅ ML models trained successfully');
                    resolve({ success: true, output });
                } else {
                    console.error('❌ ML model training failed');
                    reject(new Error(`Training failed with code ${code}: ${errorOutput}`));
                }
            });
        });
    }

    /**
     * Predict nutrition using ML models
     */
    async predictNutrition(foodName, portionSize, foodCategory = 'unknown', portionUnit = 'g') {
        return new Promise((resolve, reject) => {
            console.log(`🤖 ML Prediction: ${portionSize}${portionUnit} of ${foodName} (${foodCategory})`);
            
            const predictProcess = spawn('python', [
                'nutrition_cli.py', 
                'predict',
                '--food-name', foodName,
                '--portion-size', portionSize.toString(),
                '--food-category', foodCategory,
                '--portion-unit', portionUnit,
                '--json-output'
            ], {
                cwd: this.mlPath,
                stdio: 'pipe'
            });

            let output = '';
            let errorOutput = '';

            predictProcess.stdout.on('data', (data) => {
                output += data.toString();
            });

            predictProcess.stderr.on('data', (data) => {
                errorOutput += data.toString();
                console.error('ML Prediction Error:', data.toString().trim());
            });

            predictProcess.on('close', (code) => {
                if (code === 0) {
                    try {
                        // Extract JSON from output
                        const jsonMatch = output.match(/\{[\s\S]*\}/);
                        if (jsonMatch) {
                            const nutritionData = JSON.parse(jsonMatch[0]);
                            console.log('✅ ML prediction successful');
                            resolve(nutritionData);
                        } else {
                            reject(new Error('No JSON output found in ML prediction'));
                        }
                    } catch (parseError) {
                        reject(new Error(`Failed to parse ML prediction output: ${parseError.message}`));
                    }
                } else {
                    reject(new Error(`ML prediction failed with code ${code}: ${errorOutput}`));
                }
            });
        });
    }

    /**
     * Get nutrition prediction with ML models as primary, ChatGPT as fallback
     */
    async getNutritionPrediction(foodName, portionSize, foodCategory = 'unknown', portionUnit = 'g', openaiService) {
        try {
            // First, check if ML models are available
            const modelStatus = await this.checkModelsStatus();
            
            if (!modelStatus.available) {
                console.log(`⚠️ ML models not available: ${modelStatus.reason}`);
                console.log('🔄 Falling back to OpenAI...');
                return await this.fallbackToOpenAI(openaiService, foodName, portionSize, foodCategory);
            }

            // Try ML prediction first
            try {
                const mlPrediction = await this.predictNutrition(foodName, portionSize, foodCategory, portionUnit);
                return this.formatMLPrediction(mlPrediction);
            } catch (mlError) {
                console.log(`⚠️ ML prediction failed: ${mlError.message}`);
                console.log('🔄 Falling back to OpenAI...');
                return await this.fallbackToOpenAI(openaiService, foodName, portionSize, foodCategory);
            }

        } catch (error) {
            console.error('❌ Error in nutrition prediction:', error.message);
            throw error;
        }
    }

    /**
     * Fallback to OpenAI for nutrition prediction
     */
    async fallbackToOpenAI(openaiService, foodName, portionSize, foodCategory) {
        try {
            console.log(`🤖 OpenAI Fallback: Getting nutrition for ${portionSize}g of ${foodName}`);
            
            // Use the OpenAI service's fallback method
            const nutritionData = await openaiService.getNutritionFromOpenAI(foodName, portionSize, foodCategory);
            
            return this.formatOpenAIPrediction(nutritionData);
        } catch (openaiError) {
            console.error('❌ OpenAI fallback also failed:', openaiError.message);
            throw new Error('Both ML and OpenAI nutrition prediction failed');
        }
    }

    /**
     * Format ML prediction to match expected structure
     */
    formatMLPrediction(mlPrediction) {
        return {
            calories: mlPrediction.calories || 0,
            protein: mlPrediction.protein || 0,
            fat: mlPrediction.fat || 0,
            carbohydrates: mlPrediction.carbohydrates || 0,
            fiber: mlPrediction.fiber || 0,
            vitamins: {
                A: mlPrediction.vitamin_a || 0,
                C: mlPrediction.vitamin_c || 0,
                D: mlPrediction.vitamin_d || 0,
                E: mlPrediction.vitamin_e || 0
            },
            minerals: {
                calcium: mlPrediction.calcium || 0,
                iron: mlPrediction.iron || 0,
                potassium: mlPrediction.potassium || 0,
                sodium: mlPrediction.sodium || 0
            }
        };
    }

    /**
     * Format OpenAI prediction to match expected structure
     */
    formatOpenAIPrediction(openaiNutrition) {
        return {
            calories: openaiNutrition.calories || 0,
            protein: openaiNutrition.protein || 0,
            fat: openaiNutrition.fats || 0,
            carbohydrates: openaiNutrition.carbs || 0,
            fiber: openaiNutrition.fiber || 0,
            vitamins: {
                A: openaiNutrition.vitamins?.A || 0,
                C: openaiNutrition.vitamins?.C || 0,
                D: openaiNutrition.vitamins?.D || 0,
                E: openaiNutrition.vitamins?.E || 0
            },
            minerals: {
                calcium: openaiNutrition.minerals?.calcium || 0,
                iron: openaiNutrition.minerals?.iron || 0,
                potassium: openaiNutrition.minerals?.potassium || 0,
                sodium: openaiNutrition.minerals?.sodium || 0
            }
        };
    }

    /**
     * Initialize ML models (train if needed)
     */
    async initializeModels() {
        try {
            const modelStatus = await this.checkModelsStatus();
            
            if (!modelStatus.available) {
                console.log('🚀 Initializing ML models...');
                await this.trainModels();
                console.log('✅ ML models initialized successfully');
            } else {
                console.log('✅ ML models already available');
            }
            
            return true;
        } catch (error) {
            console.error('❌ Failed to initialize ML models:', error.message);
            return false;
        }
    }
}

export default new MLNutritionService(); 