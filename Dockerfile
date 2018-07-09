FROM python:3.6-slim
ENV PYTHONUNBUFFERED 1

ARG VERSION

ENV _ALERTA_SOURCE_DIR /usr/src/app
ENV UWSGI_PROCESSES 5

ENV ALERTA_SVR_CONF_FILE ${_ALERTA_SOURCE_DIR}/alertad.conf
ENV ALERTA_CONF_FILE ${_ALERTA_SOURCE_DIR}/alerta.conf
ENV ALERTA_WEB_CONF_FILE /web/config.js
ENV BASE_URL /
ENV INSTALL_PLUGINS ""

WORKDIR $_ALERTA_SOURCE_DIR

RUN groupadd -r alerta --gid=9999 && useradd --no-log-init -r -g alerta --uid=9999 alerta

RUN apt-get update && apt-get install -y \
        gcc

RUN pip install --no-cache-dir \
        uwsgi \
        alerta \
        alerta-server==$VERSION

COPY wsgi.py .
COPY uwsgi.ini .

EXPOSE 8080

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["uwsgi", "--ini", "uwsgi.ini"]
