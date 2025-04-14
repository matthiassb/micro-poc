from fastapi import FastAPI, Depends, HTTPException
from typing import Any, Dict, List, Optional
from mangum import Mangum
from sqlalchemy.orm import Session
from pydantic import BaseModel
import datetime

from config.database import get_db, create_schema
from models.order import Order

# Create schema if it doesn't exist
create_schema()

app = FastAPI()

# Pydantic models for request/response
class OrderBase(BaseModel):
    customer_id: int
    total_amount: float
    status: Optional[str] = "pending"

class OrderCreate(OrderBase):
    pass

class OrderResponse(OrderBase):
    id: int
    created_at: datetime.datetime
    updated_at: datetime.datetime

    class Config:
        orm_mode = True

# Helper function to normalize order data
async def normalize_order(order: Dict[str, Any]) -> Dict[str, Any]:
    # Normalize orders into standard format
    return order

# Routes
@app.get("/", response_model=List[OrderResponse])
async def get_orders(db: Session = Depends(get_db)):
    orders = db.query(Order).all()
    return orders

@app.get("/{order_id}", response_model=OrderResponse)
async def get_order(order_id: int, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@app.post("/", response_model=OrderResponse, status_code=201)
async def create_order(order_data: OrderCreate, db: Session = Depends(get_db)):
    normalized = await normalize_order(order_data.dict())
    new_order = Order(**normalized)
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    return new_order

@app.put("/{order_id}", response_model=OrderResponse)
async def update_order(order_id: int, order_data: OrderBase, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    normalized = await normalize_order(order_data.dict())
    for key, value in normalized.items():
        setattr(order, key, value)
    
    db.commit()
    db.refresh(order)
    return order

@app.delete("/{order_id}")
async def delete_order(order_id: int, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    db.delete(order)
    db.commit()
    return {"message": "Order deleted successfully"}

# AWS Lambda handler
handler = Mangum(app, lifespan="off")
