import logging
from datetime import datetime, timedelta
from typing import Any
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.jobstores.base import JobLookupError
from config import REMINDER_MINUTES_BEFORE, SCHEDULER_ENABLED
from services.whatsapp_service import wa_service

logger = logging.getLogger(__name__)


class BookingScheduler:
    def __init__(self):
        self.scheduler: BackgroundScheduler | None = None
        self._active_reminders: dict[str, str] = {}
        if SCHEDULER_ENABLED:
            self._init_scheduler()

    def _init_scheduler(self):
        try:
            self.scheduler = BackgroundScheduler(timezone="Asia/Jakarta")
            self.scheduler.start()
            logger.info("BookingScheduler started successfully")
        except Exception as e:
            logger.error(f"Failed to start scheduler: {e}")
            self.scheduler = None

    def _send_reminder_job(self, booking_data: dict[str, Any]):
        try:
            wa_service.send_booking_reminder(
                booking_id=booking_data["booking_id"],
                customer_name=booking_data["customer_name"],
                customer_phone=booking_data["customer_phone"],
                barbershop_name=booking_data["barbershop_name"],
                kapster_name=booking_data["kapster_name"],
                service_name=booking_data["service_name"],
                booking_date=datetime.fromisoformat(booking_data["booking_date"]),
                minutes_left=booking_data.get("minutes_left", REMINDER_MINUTES_BEFORE),
            )
        except Exception as e:
            logger.error(f"Reminder job error for {booking_data.get('booking_id')}: {e}")

    def schedule_reminder(
        self,
        booking_id: str,
        customer_name: str,
        customer_phone: str,
        barbershop_name: str,
        kapster_name: str,
        service_name: str,
        booking_date: datetime,
    ) -> bool:
        if not self.scheduler:
            logger.warning("Scheduler tidak aktif; reminder tidak dijadwalkan")
            return False

        try:
            self.cancel_reminder(booking_id)

            run_time = booking_date - timedelta(minutes=REMINDER_MINUTES_BEFORE)
            now = datetime.now(tz=run_time.tzinfo) if run_time.tzinfo else datetime.now()

            if run_time <= now:
                logger.info(
                    f"Booking {booking_id} sudah lewat atau <{REMINDER_MINUTES_BEFORE}menit lagi, skip scheduling"
                )
                return False

            job_id = f"reminder_{booking_id}"
            self.scheduler.add_job(
                self._send_reminder_job,
                "date",
                run_date=run_time,
                id=job_id,
                replace_existing=True,
                kwargs={
                    "booking_data": {
                        "booking_id": booking_id,
                        "customer_name": customer_name,
                        "customer_phone": customer_phone,
                        "barbershop_name": barbershop_name,
                        "kapster_name": kapster_name,
                        "service_name": service_name,
                        "booking_date": booking_date.isoformat(),
                        "minutes_left": REMINDER_MINUTES_BEFORE,
                    }
                },
            )
            self._active_reminders[booking_id] = job_id
            logger.info(
                f"Reminder dijadwalkan: {booking_id} pada {run_time.strftime('%d %b %Y %H:%M')}"
            )
            return True
        except Exception as e:
            logger.error(f"Gagal schedule reminder {booking_id}: {e}")
            return False

    def cancel_reminder(self, booking_id: str):
        try:
            job_id = self._active_reminders.pop(booking_id, f"reminder_{booking_id}")
            if self.scheduler:
                self.scheduler.remove_job(job_id)
                logger.info(f"Reminder dibatalkan: {booking_id}")
        except JobLookupError:
            pass
        except Exception as e:
            logger.debug(f"Cancel reminder (trivial): {e}")

    def list_jobs(self) -> list[dict[str, Any]]:
        if not self.scheduler:
            return []
        return [
            {
                "id": j.id,
                "next_run": j.next_run_time.isoformat() if j.next_run_time else None,
                "trigger": str(j.trigger),
            }
            for j in self.scheduler.get_jobs()
        ]

    def shutdown(self):
        if self.scheduler:
            self.scheduler.shutdown(wait=False)
            self.scheduler = None


booking_scheduler = BookingScheduler()
