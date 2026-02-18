import torch
import torch.nn.functional as F
from torchvision import transforms
from PIL import Image
import timm
import io

# Choose device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ✅ Common class labels
class_names = [
    "Cashew_anthracnose", "Cashew_gumosis", "Cashew_healthy", "Cashew_leaf miner", "Cashew_red rust",
    "Cassava_bacterial blight", "Cassava_brown spot", "Cassava_green mite", "Cassava_healthy", "Cassava_mosaic",
    "Maize_fall armyworm", "Maize_grasshoper", "Maize_Healthy", "Maize_leaf beetle", "Maize_leaf blight",
    "Maize_leaf spot", "Maize_streak virus",
    "Tomato_Healthy", "Tomato_leaf blight", "Tomato_leaf curl", "Tomato_septoria leaf spot", "Tomato_verticulium wilt"
]

# ✅ Preprocessing (same for both)
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5])
])


# =====================================
# 🔹 Load Model 1 (Mobile_Vision Transformer)
# =====================================
def load_vit_model(model_path="plant_vit_model.pth"):
    model = timm.create_model("vit_small_patch16_224", pretrained=False, num_classes=len(class_names))
    checkpoint = torch.load(model_path, map_location=device)
    if "model" in checkpoint:
        checkpoint = checkpoint["model"]
    checkpoint.pop("head.weight", None)
    checkpoint.pop("head.bias", None)
    model.load_state_dict(checkpoint, strict=False)
    model.to(device)
    model.eval()
    return model


# =====================================
# 🔹 Load Model 2 (EfficientNet or similar)
# =====================================
def load_efficientnet_model(model_path="efficientnetv2_ccmt_best.pth"):
    model = timm.create_model("efficientnetv2_rw_s", pretrained=False, num_classes=len(class_names))
    checkpoint = torch.load(model_path, map_location=device)
    if "model" in checkpoint:
        checkpoint = checkpoint["model"]
    checkpoint.pop("classifier.weight", None)
    checkpoint.pop("classifier.bias", None)
    model.load_state_dict(checkpoint, strict=False)
    model.to(device)
    model.eval()
    return model










































# =====================================
# 🔹 Common Prediction Logic
# =====================================
def predict_disease(image_bytes, model):
    """Predict disease using selected model"""
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    tensor = transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        outputs = model(tensor)
        probs = F.softmax(outputs, dim=1)
        confidence, predicted_idx = torch.max(probs, 1)

    class_name = class_names[predicted_idx.item()]
    if "_" in class_name:
        plant_name, disease_name = class_name.split("_", 1)
    else:
        plant_name = "Unknown"
        disease_name = class_name

    # Debug prints
    print(f"[DEBUG] Predicted class: {class_name}, Plant: {plant_name}, Disease: {disease_name}, Confidence: {confidence.item():.4f}")

    return {
        "plant_name": plant_name,
        "disease_name": disease_name,
        "confidence": float(confidence.item())
    }
