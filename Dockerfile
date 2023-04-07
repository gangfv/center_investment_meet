FROM python:3.10-alpine as builder
EXPOSE 80
EXPOSE 443

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk --update add gcc libc-dev libffi-dev jpeg-dev zlib-dev libjpeg musl-dev g++ freetype-dev postgresql-dev

COPY requirements.txt .
COPY .env .
COPY manage.py .
COPY /settings ./settings
COPY /onlinemeet ./onlinemeet
COPY /templates ./templates
COPY /static ./static
COPY /db.sqlite3 ./db.sqlite3

RUN pip install --upgrade pip && pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt
FROM python:3.10-alpine
WORKDIR /app

COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .
COPY --from=builder /app/.env .
COPY --from=builder /app/manage.py .
COPY --from=builder /app/settings ./settings
COPY --from=builder /app/onlinemeet ./onlinemeet
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/static ./static
COPY --from=builder /app/db.sqlite3 ./db.sqlite3

RUN pip install --no-cache /wheels/* && python manage.py makemigrations && python manage.py migrate && python manage.py collectstatic --noinput
CMD ["gunicorn", "settings.wsgi:application", "-b", ":7777"]