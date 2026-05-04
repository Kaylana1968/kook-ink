import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv
from fastapi import HTTPException, UploadFile
import os

load_dotenv()

cloudinary.config(cloudinary_url=os.getenv("CLOUDINARY_URL"))


def upload_image(file: UploadFile, folder: str = "kook-ink") -> str:
    if not os.getenv("CLOUDINARY_URL"):
        raise HTTPException(status_code=500, detail="CLOUDINARY_URL is not configured")

    try:
        response = cloudinary.uploader.upload(
            file.file,
            folder=folder,
            resource_type="image",
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Cloudinary upload failed: {exc}")

    secure_url = response.get("secure_url")
    if not secure_url:
        raise HTTPException(status_code=500, detail="Cloudinary did not return an image URL")

    return secure_url
