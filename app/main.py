from fastapi import FastAPI
app = FastAPI(title="Notes API (Secure Runtime)")

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Hello from a hardened container!"}
