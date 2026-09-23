FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PREFECT_SERVER_ANALYTICS_ENABLED=false

# Generate synthetic data and run the pipeline once at build time, so the
# dashboard has data to show immediately on first request. The container
# can always re-run via POST /api/pipeline/run afterward.
RUN python pipeline/generate_data.py && python -m pipeline.flow

EXPOSE 8000
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
