**🌱 MobilePlantViT

A Lightweight Hybrid Vision Transformer for Plant Disease Detection (CCMT Dataset)**

📌 Project Overview

Plant diseases significantly reduce crop yield and threaten food security, especially in regions where expert diagnosis is not easily accessible. While deep learning models have shown strong performance in plant disease classification, most existing approaches are computationally heavy and unsuitable for deployment on mobile or edge devices.

MobilePlantViT is a lightweight hybrid CNN–Vision Transformer (ViT) model designed to enable real-time plant disease detection on mobile and edge devices.
The project focuses on efficient model design, practical deployment, and realistic evaluation using the CCMT dataset.

🎯 Objectives

Design a lightweight hybrid CNN–ViT architecture for plant disease classification

Achieve reliable accuracy with low computational and memory requirements

Enable mobile and edge deployment for real-world agricultural usage

Evaluate performance using only the CCMT dataset

📂 Dataset Used

This project is evaluated strictly on the CCMT dataset, which contains leaf images from the following crops:

🌰 Cashew

🌿 Cassava

🌽 Maize

🍅 Tomato

⚠️ Note: No other datasets (e.g., PlantVillage) were used in training or evaluation.

🧠 Model Architecture: MobilePlantViT

MobilePlantViT follows a hybrid CNN–Transformer design optimized for efficiency and mobile readiness.

Key Components

CNN Backbone

Depthwise Convolutions

Group Convolutions

Efficient local feature extraction with reduced parameters

CBAM (Convolutional Block Attention Module)

Channel Attention: emphasizes important feature channels

Spatial Attention: focuses on diseased regions of the leaf

Vision Transformer Encoder

Patch embedding with positional encoding

Linear self-attention mechanism with O(n) complexity for mobile efficiency

Classification Head

Global Average Pooling

Fully connected layer with Softmax activation

🔹 Total Parameters: ~0.69 million
🔹 Design Goal: Balance accuracy, speed, and deployability

⚙️ Training Setup

Framework: PyTorch

Optimizer: Adam

Image Size: 224 × 224

Preprocessing:

Image resizing

Normalization

Data Augmentation:

Rotation

Horizontal flipping

Brightness and contrast adjustments

Training Platform: Google Colab (GPU)

📊 Results Summary (CCMT Only)

Strong classification performance across CCMT crops

Best accuracy observed on Cashew and Cassava datasets

Stable performance on Maize and Tomato

Efficient inference suitable for real-time usage

The model was also compared against EfficientNetV2 as a benchmark to analyze the accuracy vs efficiency trade-off.

📱 Deployment Pipeline

The project supports mobile and edge deployment through an optimized inference pipeline:

Leaf image captured via mobile or web interface

Image preprocessing (resize and normalization)

Inference using MobilePlantViT

Disease prediction displayed with confidence score

Deployment Technologies

Backend: Flask (API-based inference)

Model Conversion:

PyTorch → ONNX → TensorFlow Lite (TFLite)

Optimization:

Quantization to reduce model size and improve inference speed

Frontend (Prototype / Planned):

Flutter or Web-based interface

✔️ Supports offline inference after deployment
✔️ Suitable for low-resource environments

🌍 Real-World Impact

Enables early plant disease detection

Reduces dependency on expert diagnosis

Supports precision agriculture

Makes AI tools accessible to farmers in rural and low-resource areas

🚧 Limitations

Evaluated only on the CCMT dataset

Limited to selected crops and disease classes

Large-scale field testing not yet conducted

🔮 Future Work

Extend the model to additional crops and diseases

Integrate IoT sensor data (temperature, humidity, soil moisture)

Add multilingual voice-based diagnosis support

Improve mobile UI and real-time camera inference performance

👥 Team

K. Vaishnavi

Additi Naik

P. Varun Tej

CH. Ashwanth

A.Sai Krishna

📜 License

This project is intended for academic and research purposes only.

⭐ Final Note

MobilePlantViT demonstrates that efficient, lightweight AI models can bridge the gap between research and real-world agricultural applications, enabling practical and accessible plant disease detection on mobile devices.
