'use client'
import { useState } from 'react';

export default function Home() {
  const [Age, setAge] = useState<number | null>(null);
  const [Gender, setGender] = useState<number | null>(null);
  const [Education_Level, setEducation_Level] = useState<number | null>(null);
  const [Years_of_Experience, setYears_of_Experience] = useState<number | null>(null);

  const [Salary, setSalary] = useState<number | null>(null);
  const [currency, setCurrency] = useState<string | null>(null);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const calculateSalary = async () => {
    if (Age === null || Gender === null || Education_Level === null || Years_of_Experience === null) {
      setError('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    setLoading(true);
    setError(null);
    setSalary(null);
    setCurrency(null);

    try {
      console.log('Sending data:', { Age, Gender, Education_Level, Years_of_Experience });
      
      const response = await fetch('http://127.0.0.1:8000/api/salary', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          Age: Age,
          Gender: Gender,   
          Education_Level: Education_Level,
          Years_of_Experience: Years_of_Experience
        })
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      console.log('API Response:', data);
      
      const calculatedSalary = data.Salary;
      const getCurrency = data.currency;
      
      if (calculatedSalary !== undefined && calculatedSalary !== null) {
        setSalary(Number(calculatedSalary));
      } else {
        setError('ไม่ได้รับข้อมูลเงินเดือนจาก API');
        return;
      }
      
      if (getCurrency !== undefined && getCurrency !== null) {
        setCurrency(String(getCurrency));
      } else {
        setCurrency('THB');
      }
      
    } catch (err: any) {
      console.error('Full error object:', err);
      
      if (err.name === 'TypeError' && err.message.includes('Failed to fetch')) {
        setError('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบว่า API server ทำงานอยู่');
      } else {
        setError(`เกิดข้อผิดพลาด: ${err.message}`);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-50 via-pink-50 to-blue-50 flex items-center justify-center p-4">
      <div className="bg-white/80 backdrop-blur-sm p-8 rounded-3xl shadow-xl border border-white/50 max-w-md w-full">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold bg-gradient-to-r from-yellow-400 via-pink-400 to-blue-400 bg-clip-text text-transparent mb-2">
            ประเมินเงินเดือน
          </h1>
          <div className="w-20 h-1 bg-gradient-to-r from-yellow-300 via-pink-300 to-blue-300 mx-auto rounded-full"></div>
        </div>
        
        <div className="space-y-6">
          <div>
            <label htmlFor="Age" className="block text-gray-700 font-medium mb-3 text-lg">อายุ</label>
            <input
              id="Age"
              type="number"
              value={Age ?? ''}
              onChange={(e) => setAge(Number(e.target.value))}
              className="w-full px-4 py-3 border-2 border-yellow-200 rounded-2xl focus:outline-none focus:border-yellow-400 focus:ring-4 focus:ring-yellow-100 text-gray-800 bg-yellow-50/50 transition-all duration-300"
              placeholder="20 - 55"
            />
          </div>

          <div>
            <label htmlFor="Gender" className="block text-gray-700 font-medium mb-3 text-lg">เพศ</label>
            <select
              id="Gender"
              value={Gender ?? ''}
              onChange={(e) => setGender(Number(e.target.value))}
              className="w-full px-4 py-3 border-2 border-pink-200 rounded-2xl focus:outline-none focus:border-pink-400 focus:ring-4 focus:ring-pink-100 text-gray-800 bg-pink-50/50 transition-all duration-300"
            >
              <option value="" disabled>เลือกเพศ</option>
              <option value="0">หญิง</option>
              <option value="1">ชาย</option>
            </select>
          </div>

          <div>
            <label htmlFor="Education_Level" className="block text-gray-700 font-medium mb-3 text-lg">ระดับการศึกษา</label>
            <select
              id="Education_Level"
              value={Education_Level ?? ''}
              onChange={(e) => setEducation_Level(Number(e.target.value))}
              className="w-full px-4 py-3 border-2 border-blue-200 rounded-2xl focus:outline-none focus:border-blue-400 focus:ring-4 focus:ring-blue-100 text-gray-800 bg-blue-50/50 transition-all duration-300"
            >
              <option value="" disabled>เลือกระดับการศึกษา</option>
              <option value="0">ปริญญาตรี</option>
              <option value="1">ปริญญาโท</option>
              <option value="2">ปริญญาเอก</option>
            </select>
          </div>

          <div>
            <label htmlFor="Years_of_Experience" className="block text-gray-700 font-medium mb-3 text-lg">ประสบการณ์การทำงาน (ปี)</label>
            <input
              id="Years_of_Experience"
              type="number"
              value={Years_of_Experience ?? ''}
              onChange={(e) => setYears_of_Experience(Number(e.target.value))}
              className="w-full px-4 py-3 border-2 border-yellow-200 rounded-2xl focus:outline-none focus:border-yellow-400 focus:ring-4 focus:ring-yellow-100 text-gray-800 bg-yellow-50/50 transition-all duration-300"
              placeholder="0 - 30"
            />
          </div>
        </div>

        <button
          onClick={calculateSalary}
          disabled={loading || Education_Level === null || Years_of_Experience === null}
          className="mt-8 w-full bg-gradient-to-r from-yellow-400 via-pink-400 to-blue-400 text-white font-bold py-4 px-6 rounded-2xl hover:from-yellow-500 hover:via-pink-500 hover:to-blue-500 transform hover:scale-105 transition-all duration-300 disabled:from-gray-300 disabled:via-gray-300 disabled:to-gray-300 disabled:transform-none focus:outline-none focus:ring-4 focus:ring-pink-200 shadow-lg"
        >
          {loading ? (
            <div className="flex items-center justify-center space-x-2">
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
              <span>กำลังคำนวณ...</span>
            </div>
          ) : (
            'คำนวณเงินเดือน'
          )}
        </button>

        {error && (
          <div className="mt-6 p-4 bg-red-50 text-red-700 border-2 border-red-200 rounded-2xl shadow-sm">
            <div className="flex items-center space-x-2">
              <div className="w-5 h-5 bg-red-400 rounded-full flex-shrink-0"></div>
              <span className="font-medium">{error}</span>
            </div>
          </div>
        )}

        {Salary !== null && (
          <div className="mt-8 p-6 bg-gradient-to-r from-green-50 via-emerald-50 to-teal-50 border-2 border-green-200 rounded-3xl shadow-lg transform hover:scale-105 transition-all duration-300">
            <div className="text-center">
              <h2 className="text-2xl font-bold text-green-800 mb-3">เงินเดือนประเมิน</h2>
              <div className="bg-white/70 rounded-2xl p-4 shadow-inner">
                <p className="text-4xl font-bold bg-gradient-to-r from-green-600 via-emerald-600 to-teal-600 bg-clip-text text-transparent">
                  {typeof Salary === 'number' ? Salary.toLocaleString() : '0'}
                </p>
                <p className="text-lg font-medium text-green-700 mt-1">
                  {currency || 'บาท'}
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};