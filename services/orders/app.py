from fastapi import FastAPI
from typing import Any, Dict
from mangum import Mangum

app = FastAPI()

async def normalize_order(order: Dict[str, Any]) -> Dict[str, Any]:
    #normalize orders into standard format
    return order

@app.get("/")
async def get_orders():
    return {"message": "Hello World - From Orders (Python)"}

@app.post("/")
async def receive_orders(request: Dict[Any, Any]):
    normlized = normalize_order(request)
    return {"message": "Hello World - From Orders (Python)"}


handler = Mangum(app, lifespan="off")