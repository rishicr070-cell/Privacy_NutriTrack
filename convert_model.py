"""
YOLOv8 to TFLite Converter for Indian Food Classification
GitHub: https://github.com/johnw1llliam/Indian_Food_Classification
"""

from ultralytics import YOLO
import os

def convert_yolo_to_tflite(model_path='best.pt', output_name='indian_food'):
    """
    Convert YOLOv8 model to TFLite format
    
    Args:
        model_path: Path to YOLOv8 .pt file
        output_name: Name for output files
    """
    
    print(f"Loading YOLOv8 model from: {model_path}")
    
    # Load the trained model
    model = YOLO(model_path)
    
    print("Model loaded successfully!")
    print(f"Model type: {type(model)}")
    print(f"Number of classes: {len(model.names)}")
    print(f"Class names: {model.names}")
    
    # Export to TFLite (FP32 - full precision)
    print("\nExporting to TFLite FP32...")
    tflite_path = model.export(
        format='tflite',
        imgsz=640,  # Input image size
        int8=False,  # Use FP32, not INT8
    )
    
    print(f"\n✅ TFLite model saved to: {tflite_path}")
    
    # Also export INT8 quantized version for smaller size
    print("\nExporting to TFLite INT8 (quantized)...")
    try:
        tflite_int8_path = model.export(
            format='tflite',
            imgsz=640,
            int8=True,
        )
        print(f"✅ INT8 TFLite model saved to: {tflite_int8_path}")
    except Exception as e:
        print(f"⚠️ INT8 export failed: {e}")
    
    print("\n" + "="*50)
    print("CONVERSION COMPLETE!")
    print("="*50)
    print(f"\nCopy this file to your Flutter project:")
    print(f"  {tflite_path}")
    print(f"\nTo: assets/models/Fooddetector.tflite")
    print("\n" + "="*50)
    
    return tflite_path

if __name__ == "__main__":
    # Run conversion
    # Make sure you have the model file in current directory
    
    # Check if best.pt exists
    if os.path.exists('best.pt'):
        convert_yolo_to_tflite('best.pt')
    elif os.path.exists('weights/best.pt'):
        convert_yolo_to_tflite('weights/best.pt')
    elif os.path.exists('runs/detect/train/weights/best.pt'):
        convert_yolo_to_tflite('runs/detect/train/weights/best.pt')
    else:
        print("❌ Model file not found!")
        print("Please specify the path to your .pt file")
        print("\nUsage:")
        print("  python convert_model.py")
        print("\nOr manually call:")
        print("  convert_yolo_to_tflite('path/to/your/model.pt')")
