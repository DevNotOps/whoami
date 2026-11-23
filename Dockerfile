# syntax=docker/dockerfile:1
FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION} \
    PYTHONUNBUFFERED=1 \
    PORT=8080
RUN useradd --system --uid 10001 --no-create-home appuser
COPY --from=builder /install /usr/local
WORKDIR /srv
COPY app/ ./app/
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request,os;urllib.request.urlopen('http://127.0.0.1:%s/health'%os.environ['PORT'],timeout=2)"
CMD ["sh", "-c", "exec gunicorn --chdir app --bind 0.0.0.0:${PORT} --workers 2 main:app"]
