FROM continuumio/miniconda3

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION=ignore

# ── System dependencies (light) ────────────────────────────────────────────
# Pakai nama package yang tersedia di Debian Trixie (testing)
# LEBIH RINGAN: tanpa cmake, libboost, dkk karena fitur face analysis bisa skip
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
        build-essential \
        ca-certificates \
        curl \
    ; apt-get clean \
    ; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── Copy code ─────────────────────────────────────────────────────────────
COPY recognition_service/requirements.txt /app/requirements.txt
COPY recognition_service /app

# ── Setup Python 3.10 + install packages via PIP SAJA ──────────────────────
#  LEBIH STABLE tanpa conda-forge pinning (karena conda sering miss dependencies)
#  Pip install numpy, dll. langsung dengan binary wheel resmi PyPI.
RUN conda install -y -c conda-forge python=3.10 pip=24.0 \
    && rm -rf /opt/conda/pkgs/* /root/.cache/pip/* \
    && python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /app/requirements.txt

ENV PYTHONPATH=/app
ENV TZ=Asia/Jakarta

EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "1"]
