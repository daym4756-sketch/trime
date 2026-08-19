import logging
import requests
from abc import ABC, abstractmethod
from datetime import datetime
from config import (
    WA_PROVIDER,
    FONNTE_CONFIG,
    WHACENTER_CONFIG,
    TWILIO_CONFIG,
    ENABLE_WA_NOTIF,
)

logger = logging.getLogger(__name__)


class WhatsAppProvider(ABC):
    @abstractmethod
    def send_message(self, phone_number: str, message: str) -> tuple[bool, str]:
        pass


class FonnteProvider(WhatsAppProvider):
    def __init__(self):
        self.token = FONNTE_CONFIG["token"]
        self.base_url = FONNTE_CONFIG["base_url"]

    def send_message(self, phone_number: str, message: str) -> tuple[bool, str]:
        if not self.token:
            return False, "FONNTE token tidak diatur di .env"
        try:
            clean_phone = phone_number.replace("+", "").replace(" ", "")
            if clean_phone.startswith("0"):
                clean_phone = "62" + clean_phone[1:]
            payload = {
                "target": clean_phone,
                "message": message,
                "url": "",
                "delay": "0",
                "schedule": "0",
                "typing": False,
                "disclaimer": "auto",
            }
            headers = {
                "Authorization": self.token,
            }
            resp = requests.post(self.base_url, data=payload, headers=headers, timeout=15)
            data = resp.json()
            if resp.status_code == 200 and data.get("status", False):
                return True, f"Berhasil kirim WA ke {clean_phone}"
            return False, f"FONNTE error: {data.get('detail', str(data))}"
        except Exception as e:
            return False, f"FONNTE exception: {str(e)}"


class WhacenterProvider(WhatsAppProvider):
    def __init__(self):
        self.token = WHACENTER_CONFIG["token"]
        self.base_url = WHACENTER_CONFIG["base_url"]

    def send_message(self, phone_number: str, message: str) -> tuple[bool, str]:
        if not self.token:
            return False, "WHACENTER token tidak diatur di .env"
        try:
            clean_phone = phone_number.replace("+", "").replace(" ", "")
            if clean_phone.startswith("0"):
                clean_phone = "62" + clean_phone[1:]
            payload = {
                "device_id": self.token,
                "number": clean_phone,
                "message": message,
            }
            resp = requests.post(f"{self.base_url}/send", data=payload, timeout=15)
            data = resp.json()
            if data.get("status") == "success":
                return True, f"Berhasil kirim WA ke {clean_phone}"
            return False, f"Whacenter error: {data.get('message', str(data))}"
        except Exception as e:
            return False, f"Whacenter exception: {str(e)}"


class TwilioProvider(WhatsAppProvider):
    def __init__(self):
        self.account_sid = TWILIO_CONFIG["account_sid"]
        self.auth_token = TWILIO_CONFIG["auth_token"]
        self.wa_from = TWILIO_CONFIG["wa_from"]

    def send_message(self, phone_number: str, message: str) -> tuple[bool, str]:
        if not self.account_sid or not self.auth_token:
            return False, "TWILIO credentials tidak diatur di .env"
        try:
            from twilio.rest import Client
            client = Client(self.account_sid, self.auth_token)
            clean_phone = phone_number.replace(" ", "")
            if not clean_phone.startswith("whatsapp:"):
                if clean_phone.startswith("0"):
                    clean_phone = "+62" + clean_phone[1:]
                clean_phone = f"whatsapp:{clean_phone}"
            sent = client.messages.create(
                from_=self.wa_from,
                body=message,
                to=clean_phone,
            )
            return True, f"Berhasil kirim WA via Twilio: {sent.sid}"
        except Exception as e:
            return False, f"Twilio exception: {str(e)}"


def _get_provider() -> WhatsAppProvider:
    if WA_PROVIDER.lower() == "twilio":
        return TwilioProvider()
    elif WA_PROVIDER.lower() == "whacenter":
        return WhacenterProvider()
    return FonnteProvider()


class WhatsAppService:
    def __init__(self):
        self._provider = _get_provider()
        self.enabled = ENABLE_WA_NOTIF

    def _format_price(self, price: int) -> str:
        return f"Rp {price:,.0f}".replace(",", ".")

    def _format_datetime(self, dt: datetime) -> str:
        return dt.strftime("%d %b %Y %H:%M WIB")

    def send_booking_created(
        self,
        booking_id: str,
        customer_name: str,
        customer_phone: str,
        barbershop_name: str,
        kapster_name: str,
        service_name: str,
        booking_date: datetime,
        price: int,
        notes: str | None = None,
    ) -> tuple[bool, str]:
        if not self.enabled:
            return False, "WA notifikasi dinonaktifkan via .env"
        msg = (
            f"✅ *BOOKING BERHASIL* ✅\n\n"
            f"Halo *{customer_name}*, booking kamu sudah tercatat!\n\n"
            f"📋 *Detail Booking*\n"
            f"━━━━━━━━━━━━━━\n"
            f"ID Booking : {booking_id}\n"
            f"Barbershop : {barbershop_name}\n"
            f"Kapster    : {kapster_name}\n"
            f"Layanan    : {service_name}\n"
            f"Tanggal    : {self._format_datetime(booking_date)}\n"
            f"Total      : {self._format_price(price)}\n"
            f"━━━━━━━━━━━━━━\n"
        )
        if notes:
            msg += f"\n📝 Catatan: {notes}\n"
        msg += (
            "\n⚠️ *PENTING:* Kamu akan menerima reminder 30 menit sebelum booking dimulai.\n"
            "Terima kasih telah menggunakan TRIME! 💈"
        )
        ok, info = self._provider.send_message(customer_phone, msg)
        logger.info(f"[WA-BOOKING] {booking_id} -> {customer_phone}: {info}")
        return ok, info

    def send_booking_reminder(
        self,
        booking_id: str,
        customer_name: str,
        customer_phone: str,
        barbershop_name: str,
        kapster_name: str,
        service_name: str,
        booking_date: datetime,
        minutes_left: int = 30,
    ) -> tuple[bool, str]:
        if not self.enabled:
            return False, "WA notifikasi dinonaktifkan via .env"
        msg = (
            f"⏰ *REMINDER BOOKING* ⏰\n\n"
            f"Halo *{customer_name}*, booking kamu tinggal *{minutes_left} menit* lagi!\n\n"
            f"📋 *Detail Booking*\n"
            f"━━━━━━━━━━━━━━\n"
            f"ID Booking : {booking_id}\n"
            f"Barbershop : {barbershop_name}\n"
            f"Kapster    : {kapster_name}\n"
            f"Layanan    : {service_name}\n"
            f"Jam        : {self._format_datetime(booking_date)}\n"
            f"━━━━━━━━━━━━━━\n\n"
            f"Silakan datang tepat waktu ya! 🙏\n"
            f"— TRIME 💈"
        )
        ok, info = self._provider.send_message(customer_phone, msg)
        logger.info(f"[WA-REMINDER] {booking_id} -> {customer_phone}: {info}")
        return ok, info

    def send_booking_status_change(
        self,
        booking_id: str,
        customer_name: str,
        customer_phone: str,
        old_status: str,
        new_status: str,
        barbershop_name: str,
    ) -> tuple[bool, str]:
        if not self.enabled:
            return False, "WA notifikasi dinonaktifkan via .env"
        status_label = {
            "confirmed": "✅ Dikonfirmasi",
            "done": "💈 Selesai",
            "cancelled": "❌ Dibatalkan",
            "pending": "⏳ Menunggu",
        }.get(new_status, new_status.title())

        msg = (
            f"🔔 *STATUS BOOKING DIUBAH* 🔔\n\n"
            f"Halo *{customer_name}*, status booking di *{barbershop_name}*:\n\n"
            f"ID Booking: {booking_id}\n"
            f"Status Baru: {status_label}\n\n"
            f"— TRIME 💈"
        )
        ok, info = self._provider.send_message(customer_phone, msg)
        logger.info(f"[WA-STATUS] {booking_id} -> {customer_phone}: {info}")
        return ok, info

    def send_owner_new_booking(
        self,
        booking_id: str,
        customer_name: str,
        customer_phone: str,
        owner_phone: str,
        barbershop_name: str,
        kapster_name: str,
        service_name: str,
        booking_date: datetime,
        price: int,
    ) -> tuple[bool, str]:
        if not self.enabled:
            return False, "WA notifikasi dinonaktifkan via .env"
        msg = (
            f"🔔 *BOOKING BARU MASUK!* 🔔\n\n"
            f"*Barbershop: {barbershop_name}*\n\n"
            f"📋 Detail:\n"
            f"━━━━━━━━━━━━━━\n"
            f"ID Booking : {booking_id}\n"
            f"Pelanggan  : {customer_name}\n"
            f"No. WA     : {customer_phone}\n"
            f"Kapster    : {kapster_name}\n"
            f"Layanan    : {service_name}\n"
            f"Tanggal    : {self._format_datetime(booking_date)}\n"
            f"Total      : {self._format_price(price)}\n"
            f"━━━━━━━━━━━━━━\n\n"
            f"Segera konfirmasi booking ini ya! 🙏\n"
            f"— TRIME 💈"
        )
        ok, info = self._provider.send_message(owner_phone, msg)
        logger.info(f"[WA-OWNER] {booking_id} -> owner {owner_phone}: {info}")
        return ok, info


wa_service = WhatsAppService()
