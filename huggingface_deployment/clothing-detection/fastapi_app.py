import io
import os
import requests
from PIL import Image
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse

HF_ENDPOINT = os.getenv("HF_ENDPOINT", "https://crushedkatana-clothing-detection.hf.space/detect")

app = FastAPI(title="Clothing Detection API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok", "hf_endpoint": HF_ENDPOINT}

@app.post("/detect")
async def detect(image: UploadFile = File(...)):
    try:
        content = await image.read()
        # Validate image
        try:
            Image.open(io.BytesIO(content)).verify()
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file")

        # Forward to Hugging Face Space
        files = {"image": (image.filename or "upload.jpg", content, image.content_type or "image/jpeg")}
        try:
            resp = requests.post(HF_ENDPOINT, files=files, timeout=20)
        except requests.exceptions.RequestException as e:
            raise HTTPException(status_code=502, detail=f"Upstream error: {e}")

        if resp.status_code != 200:
            raise HTTPException(status_code=resp.status_code, detail=resp.text)

        # Expect JSON payload from HF Space
        try:
            data = resp.json()
        except ValueError:
            # If upstream returns plain text, wrap it
            return JSONResponse(content={"raw": resp.text})

        return data
    finally:
        await image.close()
