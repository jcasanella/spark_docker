FROM alpine:3.11.6

LABEL author="Jordi Casanella" email="jordikiter@hotmail.es"
LABEL VERSION="1.0"

# Sw
ENV SCALA_VERSION=2.12.4
ENV SCALA_HOME=/usr/share/scala 
ENV SBT_VERSION=1.3.8 
ENV SBT_HOME=/usr/local/sbt
ENV SPARK_VERSION=2.4.5
ENV SPARK_HOME=/usr/local/spark

# User
ENV USER=spark_docker
ENV GROUP=spark_docker
ENV UID=12345
ENV GID=23456

# Install java8 and python3
RUN apk update && apk upgrade && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache bash bash-doc bash-completion curl jq openjdk8=8.242.08-r0 python3 python3-dev && \
    pip3 install --no-cache-dir --upgrade pip && \
    cd /usr/bin && \
    ln -sf python3 python && \
    ln -sf pip3 pip

WORKDIR "/tmp"

# Install scala
RUN wget --no-verbose https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}.tgz" && \
    rm -rf "scala-${SCALA_VERSION}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    echo "export SCALA_HOME=${SCALA_HOME}" >> /etc/profile.d/spark_vars.sh 

# Install sbt
RUN wget --no-verbose https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz && \
    mkdir -p "${SBT_HOME}" && \
    tar xzf "sbt-${SBT_VERSION}.tgz" && \
    mv "sbt/bin" "sbt/conf" "sbt/lib" "${SBT_HOME}" && \
    rm "sbt-${SBT_VERSION}.tgz" && \
    rm -rf "sbt" && \
    echo "export SBT_HOME=${SBT_HOME}" >> /etc/profile.d/spark_vars.sh && \
    export PATH="/usr/local/sbt/bin:$PATH" && sbt sbtVersion

# Install Spark
RUN wget --no-verbose  https://downloads.apache.org/spark/spark-2.4.5/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz && \
    mkdir "${SPARK_HOME}" && \
    tar xzf "spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" && \
    rm "spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" && \
    mv "spark-${SPARK_VERSION}-bin-hadoop2.7/licenses" "spark-${SPARK_VERSION}-bin-hadoop2.7/python" "spark-${SPARK_VERSION}-bin-hadoop2.7/sbin" "spark-${SPARK_VERSION}-bin-hadoop2.7/yarn" "spark-${SPARK_VERSION}-bin-hadoop2.7/bin" "spark-${SPARK_VERSION}-bin-hadoop2.7/conf" "spark-${SPARK_VERSION}-bin-hadoop2.7/data" "spark-${SPARK_VERSION}-bin-hadoop2.7/R" "spark-${SPARK_VERSION}-bin-hadoop2.7/examples" "spark-${SPARK_VERSION}-bin-hadoop2.7/jars" "spark-${SPARK_VERSION}-bin-hadoop2.7/kubernetes" "${SPARK_HOME}" && \
    rm -rf "spark-${SPARK_VERSION}-bin-hadoop2.7" && \
    echo "export SPARK_HOME=${SPARK_HOME}" >> /etc/profile.d/spark_vars.sh && \
    echo "export PATH=${SPARK_HOME}/bin:${SCALA_HOME}/bin:${SBT_HOME}/bin:$PATH" >> /etc/profile.d/spark_vars.sh && \
    apk del .build-dependencies && \
    rm -rf "/var/cache/apk/*"

# Add user
RUN addgroup -g "${GID}" "${GROUP}" && \
    adduser -D -u "${UID}" -G "${GROUP}" "${USER}" 

WORKDIR "/home/${USER}"

USER ${USER}

CMD [ "sh", "--login" ]
