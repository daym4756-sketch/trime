FROM continuumio/miniconda3

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libx11-6 \
    libgthread-2.0-0 \
    libatlas-base-dev \
    libboost-all-dev \
    build-essential \
    cmake \
    pkg-config \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY recognition_service/requirements.txt /app/requirements.txt
COPY recognition_service /app

RUN conda config --set channel_priority strict \
    && conda install -y -c conda-forge python=3.10 dlib=19.24.0 numpy scikit-learn opencv pillow joblib \
    && rm -rf /opt/conda/pkgs/* /root/.cache/pip

RUN grep -v -E '^(dlib|numpy|scikit-learn|opencv-python-headless|opencv-python|joblib|Pillow)' /app/requirements.txt > /app/pip_requirements.txt \
    && python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /app/pip_requirements.txt

ENV PYTHONPATH=/app
ENV TZ=Asia/Jakarta

EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "1"]
