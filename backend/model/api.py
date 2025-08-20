from flask import Flask, request, jsonify
from flask_cors import CORS
from pydantic import BaseModel, Field, ValidationError
from werkzeug.exceptions import BadRequest
import joblib
import numpy as np

# Configuration
app = Flask(__name__)
CORS(app)
MODEL_PATH = "SalaryPredict.pkl"

# Load ML model at startup
try:
    model = joblib.load(MODEL_PATH)
except Exception as e:
    raise RuntimeError(f"Failed to load model: {e}")

# Define input schema to validate inputs 
class SalaryFeatures(BaseModel):
    Age: int = Field(..., ge=20, le=55)                   # อายุ 20-55 ปี
    Gender: int = Field(..., ge=0, le=1)                  # เพศ 0-หญิง, 1-ชาย
    Education_Level: int = Field(..., ge=0, le=2)         # การศึกษา 0-ปริญญาตรี, 1-ปริญญาโท, 2-ปริญญาเอก
    Years_of_Experience: int = Field(..., ge=0, le=30)    # ประสบการณ์ทำงาน 0-30 ปี

# Test API endpoint to check if server is running
@app.route("/api/hello", methods=["GET"])
def hello_world():
    return jsonify({"message": "hello world"}) 

# Salary Prediction API
@app.route("/api/salary", methods=["POST"])
def predict_house_price():
    try:
        data = request.get_json()

        features = SalaryFeatures(**data)

        x = np.array([[features.Age, features.Gender, features.Education_Level, features.Years_of_Experience]])

        prediction = model.predict(x)

        return jsonify({
            "status": True,
            "Salary": np.round(float(prediction[0]), 2),  #เป็นจำนวนเงินที่คาดการณ์
            "currency": "THB"
        })

    except ValidationError as ve:
        errors = {}
        print(ve.errors())
        for error in ve.errors():
            field = error['loc'][0]
            msg = error['msg']                        
            errors.setdefault(field, []).append(msg) #errors[field] = msg
        return jsonify({"status": False, "detail": errors}), 400
    except BadRequest as e: 
        return jsonify({
            "status": False,
            "error": "Invalid JSON format",
            "detail": str(e)
        }), 400
    except Exception as e:
        return jsonify({"status": False, "error": str(e)}), 500

# Run API server
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)