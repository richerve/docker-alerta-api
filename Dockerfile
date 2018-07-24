FROM python:3.6-slim
ENV PYTHONUNBUFFERED 1

ARG VERSION

ENV _ALERTA_CONF_DIR /etc/alerta
ENV _ALERTA_APP_DIR /alerta
ENV _UWSGI_CONF_DIR /etc/uwsgi
ENV UWSGI_PROCESSES 5

ENV ALERTA_SVR_CONF_FILE ${_ALERTA_CONF_DIR}/alertad.conf
ENV ALERTA_CONF_FILE ${_ALERTA_CONF_DIR}/alerta.conf
ENV BASE_URL /
ENV INSTALL_PLUGINS ""

RUN mkdir -p ${_ALERTA_CONF_DIR}

RUN groupadd -r alerta --gid=9999 && useradd --no-log-init -r -g alerta --uid=9999 -d ${_ALERTA_APP_DIR} alerta

RUN apt-get update && apt-get install -y \
        git \
        gcc \
        libldap2-dev \
        libsasl2-dev

RUN pip install --no-cache-dir \
        uwsgi \
        python-ldap \
        alerta \
        alerta-server==$VERSION

COPY wsgi.py ${_ALERTA_APP_DIR}/
COPY uwsgi.ini ${_UWSGI_CONF_DIR}/

WORKDIR ${_UWSGI_CONF_DIR}

EXPOSE 8080

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["uwsgi", "--ini", "uwsgi.ini"]
