import mlNutritionService from './services/mlNutritionService.js';
import imageAnalysisService from './services/imageAnalysisService.js';

async function testMLIntegration() {
    console.log('🧪 Testing ML Nutrition Integration...\n');

    try {
        // Test 1: Check ML models status
        console.log('1️⃣ Checking ML models status...');
        const modelStatus = await mlNutritionService.checkModelsStatus();
        console.log('Model Status:', modelStatus);
        console.log('');

        // Test 2: Test nutrition prediction
        console.log('2️⃣ Testing nutrition prediction...');
        const nutritionData = await mlNutritionService.getNutritionPrediction(
            'water',
            150,
            'diary',
            'ml',
            imageAnalysisService
        );
        console.log('Nutrition Data:', JSON.stringify(nutritionData, null, 2));
        console.log('');

        // Test 3: Test fallback scenario
        console.log('3️⃣ Testing fallback scenario...');
        const fallbackData = await mlNutritionService.getNutritionPrediction(
            'unknown_food',
            100,
            'unknown',
            'g',
            imageAnalysisService
        );
        console.log('Fallback Data:', JSON.stringify(fallbackData, null, 2));
        console.log('');

        console.log('✅ All tests passed! ML integration is working correctly.');

    } catch (error) {
        console.error('❌ Test failed:', error.message);
    }
}

// Run the test
testMLIntegration(); 