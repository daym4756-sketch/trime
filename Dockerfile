FROM continuumio/miniconda3

WORKDIR /app

# Copy requirements and service code
COPY recognition_service/requirements.txt /app/requirements.txt
COPY recognition_service /app

# Install prebuilt native packages from conda-forge to avoid compiling dlib from source
# Pin Python to 3.10 to avoid conflicts if the base image or pins force Python 3.14
RUN conda config --set channel_priority strict \
    && conda install -y -c conda-forge python=3.10 dlib=19.24.0 numpy scikit-learn opencv pillow joblib \
    && rm -rf /opt/conda/pkgs/* /root/.cache/pip

# Install remaining Python-only requirements (exclude packages already installed via conda)
RUN grep -v -E '^(dlib|numpy|scikit-learn|opencv-python-headless|opencv-python|joblib|Pillow)' /app/requirements.txt > /app/pip_requirements.txt \
    && python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /app/pip_requirements.txt

ENV PYTHONPATH=/app

EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
