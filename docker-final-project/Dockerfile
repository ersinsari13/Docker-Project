FROM python:alpine
RUN apk update && apk add --no-cache curl && pip install cryptography
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD [ curl -f http://localhost || exit 1 ]
CMD [ "python","bookstore-api.py" ]