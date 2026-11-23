from fastapi import FastAPI

app = FastAPI(title="Python EKS DevOps Demo")


@app.get("/")
def root():
    return {
        "message": "Hello from EKS!",
        "version": "1.0"
    }


@app.get("/health")
def health():
    return {"status": "healthy"}