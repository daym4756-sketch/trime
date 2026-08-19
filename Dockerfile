FROM python:3.10-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential cmake libboost-all-dev libopenblas-dev liblapack-dev libjpeg-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY recognition_service/requirements.txt /app/requirements.txt

RUN python -m pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY recognition_service /app

ENV PYTHONPATH=/app

EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
