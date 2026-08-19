import logging
from datetime import datetime
from fastapi import FastAPI, UploadFile, File, HTTPException, Depends, Header
from pydantic import BaseModel

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("trime-service")

from config import (
    API_HOST,
    API_PORT,
    API_SECRET,
    ENABLE_WA_NOTIF,
    ENABLE_FACE_ANALYSIS,
)
from services.whatsapp_service import wa_service
from services.booking_scheduler import booking_scheduler
from schemas.booking import (
    BookingCreatedRequest,
    BookingReminderRequest,
    BookingStatusRequest,
    SendWATestRequest,
)

app = FastAPI(title="TRIME Backend Service", version="1.2.0")

face_shape_engine = None
FACE_ANALYSIS_AVAILABLE = False

if ENABLE_FACE_ANALYSIS:
    try:
        from engines.face_shape.engine import FaceShapeEngine
        from common.image_utils import load_image

        face_shape_engine = FaceShapeEngine()
        FACE_ANALYSIS_AVAILABLE = True
        logger.info("Face analysis engine siap di-load")
    except Exception as e:
        logger.warning(f"Face analysis engine TIDAK TERSEDIA (akan dilewati): {e}")
        FACE_ANALYSIS_AVAILABLE = False


def _verify_api_key(x_api_key: str | None = Header(default=None)):
    if not x_api_key or x_api_key != API_SECRET:
        raise HTTPException(status_code=401, detail="Unauthorized: API Key salah atau kosong")
    return True


@app.on_event("startup")
async def startup_event():
    if FACE_ANALYSIS_AVAILABLE and face_shape_engine is not None:
        try:
            face_shape_engine.load_model()
            logger.info("Face shape engine model loaded OK")
        except Exception as e:
            logger.warning(f"Gagal load face shape model: {e}")
    logger.info(
        f"TRIME Service started | WA notif: {'ON' if ENABLE_WA_NOTIF else 'OFF'} | "
        f"Face analysis: {'ON' if FACE_ANALYSIS_AVAILABLE else 'OFF'}"
    )


@app.on_event("shutdown")
async def shutdown_event():
    try:
        booking_scheduler.shutdown()
    except Exception:
        pass


@app.get("/")
async def root():
    return {
        "service": "TRIME Backend Service",
        "version": "1.2.0",
        "wa_notification": ENABLE_WA_NOTIF,
        "face_analysis": FACE_ANALYSIS_AVAILABLE,
        "scheduler_active": booking_scheduler.scheduler is not None,
        "time": datetime.now().isoformat(),
    }


@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "face_analysis": FACE_ANALYSIS_AVAILABLE,
        "scheduled_jobs": len(booking_scheduler.list_jobs()),
    }


# ─────────────────────────────────────────────
# BOOKING ENDPOINTS (trigger notif & scheduler)
# ─────────────────────────────────────────────

@app.post("/booking/created")
async def on_booking_created(
    req: BookingCreatedRequest,
    _auth: bool = Depends(_verify_api_key),
):
    result_customer = wa_service.send_booking_created(
        booking_id=req.booking_id,
        customer_name=req.customer_name,
        customer_phone=req.customer_phone,
        barbershop_name=req.barbershop_name,
        kapster_name=req.kapster_name,
        service_name=req.service_name,
        booking_date=req.booking_date,
        price=req.price,
        notes=req.notes,
    )

    result_owner = None
    if req.owner_phone:
        result_owner = wa_service.send_owner_new_booking(
            booking_id=req.booking_id,
            customer_name=req.customer_name,
            customer_phone=req.customer_phone,
            owner_phone=req.owner_phone,
            barbershop_name=req.barbershop_name,
            kapster_name=req.kapster_name,
            service_name=req.service_name,
            booking_date=req.booking_date,
            price=req.price,
        )

    scheduled = booking_scheduler.schedule_reminder(
        booking_id=req.booking_id,
        customer_name=req.customer_name,
        customer_phone=req.customer_phone,
        barbershop_name=req.barbershop_name,
        kapster_name=req.kapster_name,
        service_name=req.service_name,
        booking_date=req.booking_date,
    )

    return {
        "ok": True,
        "booking_id": req.booking_id,
        "customer_wa": result_customer,
        "owner_wa": result_owner,
        "reminder_scheduled": scheduled,
    }


@app.post("/booking/status-changed")
async def on_booking_status_changed(
    req: BookingStatusRequest,
    _auth: bool = Depends(_verify_api_key),
):
    if req.new_status in ("cancelled", "done"):
        booking_scheduler.cancel_reminder(req.booking_id)

    result = wa_service.send_booking_status_change(
        booking_id=req.booking_id,
        customer_name=req.customer_name,
        customer_phone=req.customer_phone,
        old_status=req.old_status,
        new_status=req.new_status,
        barbershop_name=req.barbershop_name,
    )
    return {"ok": True, "booking_id": req.booking_id, "wa_result": result}


@app.post("/booking/send-reminder")
async def send_manual_reminder(
    req: BookingReminderRequest,
    _auth: bool = Depends(_verify_api_key),
):
    result = wa_service.send_booking_reminder(
        booking_id=req.booking_id,
        customer_name=req.customer_name,
        customer_phone=req.customer_phone,
        barbershop_name=req.barbershop_name,
        kapster_name=req.kapster_name,
        service_name=req.service_name,
        booking_date=req.booking_date,
        minutes_left=req.minutes_left,
    )
    return {"ok": True, "wa_result": result}


@app.get("/booking/jobs")
async def list_scheduled_jobs(_auth: bool = Depends(_verify_api_key)):
    return {"jobs": booking_scheduler.list_jobs()}


@app.post("/booking/cancel-reminder/{booking_id}")
async def cancel_reminder(
    booking_id: str,
    _auth: bool = Depends(_verify_api_key),
):
    booking_scheduler.cancel_reminder(booking_id)
    return {"ok": True, "booking_id": booking_id, "cancelled": True}


# ─────────────────────────────────────────────
# WHATSAPP TEST ENDPOINT
# ─────────────────────────────────────────────

@app.post("/wa/test")
async def test_whatsapp(
    req: SendWATestRequest,
    _auth: bool = Depends(_verify_api_key),
):
    ok, info = wa_service._provider.send_message(req.phone, req.message)
    return {"ok": ok, "message": info}


# ─────────────────────────────────────────────
# FACE ANALYSIS ENDPOINT (dengan graceful fallback)
# ─────────────────────────────────────────────

@app.post("/analyze/face-shape")
async def analyze_face_shape(file: UploadFile = File(...)):
    if not FACE_ANALYSIS_AVAILABLE or face_shape_engine is None:
        raise HTTPException(
            status_code=503,
            detail="Face analysis engine tidak tersedia di server ini (dlib/cv2 error di nonaktifkan)",
        )
    try:
        from common.image_utils import load_image
        contents = await file.read()
        image = load_image(contents)
        if image is None:
            return {"error": "Invalid image format"}
        result = face_shape_engine.process(image)
        if "landmarks" in result:
            del result["landmarks"]
        return result
    except NameError:
        raise HTTPException(status_code=503, detail="Face analysis module tidak termuat")
    except Exception as e:
        logger.exception("analyze_face_shape error")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=API_HOST, port=API_PORT)
