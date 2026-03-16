FROM python:3.11-slim

WORKDIR /app

COPY app.py .

RUN pip install flask requests

ENV PORT=8080

EXPOSE 8080

CMD ["python", "-u", "app.py"]
