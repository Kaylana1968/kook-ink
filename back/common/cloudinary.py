import cloudinary
from dotenv import load_dotenv
import os

load_dotenv()

cloudinary.config(cloudinary_url=os.getenv("CLOUDINARY_URL"))
