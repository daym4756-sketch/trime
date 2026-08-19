FROM continuumio/miniconda3

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# ── System dependencies ────────────────────────────────────────────────────
# ・Debian Trixie (testing) menghapus libgl1-mesa-glx, libatlas-base-dev, dll.
# ・Ganti dengan package pengganti yang tersedia, dan pakai --fix-missing + apt-get update
#   agar semua mirror disinkronkan terlebih dahulu.
RUN apt-get update -y --fix-missing \
    && apt-get install -y --no-install-recommends --fix-missing \
        libgomp1 \
        libgl1 \
        libglx-mesa0 \
        libglib2.0-0t64 \
        libglib2.0-bin \
        libsm6 \
        libxext6 \
        libxrender1 \
        libx11-6 \
        libopenblas-dev \
        libboost-all-dev \
        build-essential \
        cmake \
        pkg-config \
        ca-certificates \
        curl \
    ; apt-get clean \
    ; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── Copy kode & requirements ──────────────────────────────────────────────
COPY recognition_service/requirements.txt /app/requirements.txt
COPY recognition_service /app

# ── Conda packages (menghindari compile dlib/opencv dari source) ──────────
RUN conda config --set channel_priority strict \
    && conda install -y -c conda-forge python=3.10 dlib=19.24.0 numpy scikit-learn opencv pillow joblib \
    && rm -rf /opt/conda/pkgs/* /root/.cache/pip

# ── Python packages (yang tidak diinstall conda) ───────────────────────────
RUN grep -v -E '^(dlib|numpy|scikit-learn|opencv-python-headless|opencv-python|joblib|Pillow)' /app/requirements.txt > /app/pip_requirements.txt \
    && python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /app/pip_requirements.txt

ENV PYTHONPATH=/app
ENV TZ=Asia/Jakarta

EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "1"]
