FROM spark_jordi:1.0

LABEL author="Jordi Casanella" email="jordikiter@hotmail.es"
LABEL VERSION="1.0"

ENV USER=spark_docker
ENV GROUP=spark_docker
ENV SPARK_HOME=/usr/local/spark

WORKDIR /usr/local/spark

COPY start-worker.sh .

ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_MASTER "spark://spark-master:7077"

EXPOSE 8081

USER root

RUN chown -R "${USER}:${GROUP}" "${SPARK_HOME}" && \
    chmod 755 "${SPARK_HOME}"

USER ${USER}

CMD ["/bin/bash", "start-worker.sh"]