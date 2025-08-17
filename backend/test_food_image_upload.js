import axios from "axios";
import fs from "fs";
import FormData from "form-data";
import path from "path";

// CONFIGURATION
const API_URL = "http://localhost:5000/api/food-entries/image"; // Adjust if your server runs elsewhere
const IMAGE_PATH = path.join(__dirname, "uploads", "image.png");
const JWT_TOKEN = process.env.TEST_JWT_TOKEN || "YOUR_JWT_TOKEN_HERE"; // Set your token here or via env

async function testFoodImageUpload() {
  try {
    const form = new FormData();
    form.append("image", fs.createReadStream(IMAGE_PATH));

    const response = await axios.post(API_URL, form, {
      headers: {
        ...form.getHeaders(),
        Authorization: `Bearer ${JWT_TOKEN}`,
      },
      maxBodyLength: Infinity,
    });

    console.log("Response:", JSON.stringify(response.data, null, 2));
  } catch (error) {
    if (error.response) {
      console.error(
        "Error response:",
        error.response.status,
        error.response.data
      );
    } else {
      console.error("Error:", error.message);
    }
  }
}

testFoodImageUpload();
