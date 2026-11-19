FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY backend/app /app/app
COPY backend/schema.sql /app/schema.sql
CMD ["uvicorn", "app.api:app", "--host", "0.0.0.0", "--port", "8000"]
