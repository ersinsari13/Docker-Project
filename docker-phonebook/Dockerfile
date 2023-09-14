FROM python:alpine
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
RUN pip install cryptography
EXPOSE 80
CMD python ./phonebook-app.py