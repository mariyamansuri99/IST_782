# Enhancing Radiological Diagnoses through Pattern Imaging Analytics

## Project Overview
The project was done by my group for the class IST 707 Applied Machine Learning, this project leverages Convolutional Neural Networks (CNNs) to enhance radiological diagnoses by improving image classification accuracy in medical imaging. Using a dataset of over 100,000 chest X-ray images sourced from the **National Institutes of Health (NIH) Clinical Center**, we aim to develop an efficient deep learning model for detecting abnormalities.

## Repository Structure
This repository contains the following files:

### 1. Code (`Final_Submission.ipynb`)
- **Description:** Jupyter Notebook containing the full pipeline for data preprocessing, model training, and evaluation.
- **Key Components:**
  - Data cleaning and transformation
  - CNN model implementation with various activation functions (ReLU, Sigmoid, Tanh)
  - Performance evaluation using accuracy, sensitivity, and specificity

### 2. Presentation (`Final Presentation-CNN.pptx`)
- **Description:** PowerPoint presentation summarizing the project, including problem definition, methodology, results, and future directions.
- **Key Components:**
  - Dataset overview and exploratory data analysis
  - Model architecture and hyperparameter tuning
  - Key results and insights
  - Challenges faced and future improvements


## Required Software
To run the code and review the findings, ensure you have the following installed:

### Software Requirements:
- Python 3.2+
- Jupyter Notebook
- GPU (Recommended for faster training)

### Required Python Libraries:
Install dependencies using the following command:
```bash
pip install numpy pandas matplotlib seaborn tensorflow keras opencv-python
```

## How to Review the Files
1. **Code:**
   - Open `Final_Submission.ipynb` in Jupyter Notebook.
   - Run each cell sequentially to execute data preprocessing, model training, and evaluation.
   - Modify parameters to experiment with different activation functions or architectures.

2. **Presentation:**
   - Open `Final Presentation-CNN.pptx` in PowerPoint or Google Slides.
   - Review the slides for a summary of the project’s goals, findings, and insights.

## Key Findings
- **Model Accuracy:** CNN using **ReLU activation** and **256x256 image size** achieved **66% accuracy**.
- **Impact of Layers:** Increasing the depth of CNN (from 3 to 5 layers) improved pattern recognition.
- **Data Size:** Reducing dataset to **6000 images** led to accuracy drop, highlighting data volume significance.

## Future Directions
- Implement advanced architectures like **ResNet** or **EfficientNet** to improve accuracy.
- Expand dataset and utilize more computational power (e.g., **TPUs or high-end GPUs**).
- Fine-tune hyperparameters for optimal performance.