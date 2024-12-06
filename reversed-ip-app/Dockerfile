FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /reversed-ip-app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY reversed-ip-app.py .

EXPOSE 5000

CMD ["python", "reversed-ip-app.py"]
