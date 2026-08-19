from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


class BookingCreatedRequest(BaseModel):
    booking_id: str = Field(..., min_length=2)
    customer_name: str = Field(..., min_length=1)
    customer_phone: str = Field(..., min_length=8)
    barbershop_name: str = Field(..., min_length=1)
    kapster_name: str = ""
    service_name: str = Field(..., min_length=1)
    booking_date: datetime
    price: int = Field(..., ge=0)
    notes: Optional[str] = None
    owner_phone: Optional[str] = None


class BookingReminderRequest(BaseModel):
    booking_id: str
    customer_name: str
    customer_phone: str
    barbershop_name: str
    kapster_name: str = ""
    service_name: str
    booking_date: datetime
    minutes_left: int = 30


class BookingStatusRequest(BaseModel):
    booking_id: str
    customer_name: str
    customer_phone: str
    old_status: str
    new_status: str
    barbershop_name: str


class SendWATestRequest(BaseModel):
    phone: str
    message: str
