FROM python:3

WORKDIR /usr/src/app

RUN pip install --no-cache-dir flask

COPY server.py .

CMD [ "python", "./server.py" ]
