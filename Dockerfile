# Dockerfile for automated build on DockerHub

FROM ubuntu:14.04
MAINTAINER bhell <bastien.hell@ign.fr>

RUN apt-get update && apt-get install -y software-properties-common \
	&& add-apt-repository ppa:openjdk-r/ppa \
	&& apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        vim \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-scipy \
        maven \
        unzip \
        zip \
        unzip \
        libopenblas-dev \
        openssh-server \
        openssh-client \
        libopenblas-dev \
        libboost-all-dev \
	&& apt-get install -y software-properties-common \
	&& add-apt-repository ppa:openjdk-r/ppa \
	&& apt-get update && apt-get install -y openjdk-8-jdk \
	&& rm -rf /var/lib/apt/lists/*

# Apache Hadoop and Spark section
RUN wget http://apache.mirrors.tds.net/hadoop/common/hadoop-2.6.4/hadoop-2.6.4.tar.gz \
	&& wget http://archive.apache.org/dist/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz \
	&& gunzip hadoop-2.6.4.tar.gz \
	&& gunzip spark-1.6.0-bin-hadoop2.6.tgz \
	&& tar -xf hadoop-2.6.4.tar \
	&& tar -xf spark-1.6.0-bin-hadoop2.6.tar \
	&& sudo cp -r hadoop-2.6.4 /usr/local/hadoop \
	&& sudo cp -r spark-1.6.0-bin-hadoop2.6 /usr/local/spark \
	&& rm hadoop-2.6.4.tar spark-1.6.0-bin-hadoop2.6.tar \
	&& rm -rf hadoop-2.6.4/ spark-1.6.0-bin-hadoop2.6/

# Environment variables
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV PATH $PATH:$JAVA_HOME/bin
ENV PATH $PATH:$HADOOP_HOME/bin
ENV PATH $PATH:$HADOOP_HOME/sbin
ENV PATH $PATH:$SPARK_HOME/bin
ENV PATH $PATH:$SPARK_HOME/sbin
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_HOME /usr/local/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR /usr/local/hadoop/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_HOME/lib"

# Some of the Hadoop part extracted from "https://hub.docker.com/r/sequenceiq/hadoop-docker/~/dockerfile/"
RUN mkdir ${HADOOP_HOME}/input \
	&& cp ${HADOOP_HOME}/etc/hadoop/*.xml ${HADOOP_HOME}/input \
	&& cd /usr/local/hadoop/input
ENV BOOTSTRAP /etc/bootstrap.sh

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64\nexport HADOOP_HOME=/usr/local/hadoop\n:' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh \
	&& sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh \
	&& chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh \
	&& ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

#Other ports
EXPOSE 49707 2122

# Clone CaffeOnSpark, continue with CaffeOnSpark build, clean source code.
ENV CAFFE_ON_SPARK /opt/CaffeOnSpark
WORKDIR ${CAFFE_ON_SPARK}
RUN git clone https://github.com/yahoo/CaffeOnSpark.git . --recursive \
	&& cp ${CAFFE_ON_SPARK}/scripts/*.xml  ${HADOOP_HOME}/etc/hadoop # Copy .xml files. \
	&& cd ${CAFFE_ON_SPARK} \
	&& cp caffe-public/Makefile.config.example caffe-public/Makefile.config \
	&& echo "INCLUDE_DIRS += ${JAVA_HOME}/include" >> caffe-public/Makefile.config \
	&& sed -i "s/# CPU_ONLY := 1/CPU_ONLY := 1/g" caffe-public/Makefile.config \
	&& sed -i "s|CUDA_DIR := /usr/local/cuda|# CUDA_DIR := /usr/local/cuda|g" caffe-public/Makefile.config \
	&& sed -i "s|CUDA_ARCH :=|# CUDA_ARCH :=|g" caffe-public/Makefile.config \
	&& sed -i "s|BLAS := atlas|BLAS := open|g" caffe-public/Makefile.config \
	&& sed -i "s|TEST_GPUID := 0|# TEST_GPUID := 0|g" caffe-public/Makefile.config \
	&& make build \
	&& rm -rf ${CAFFE_ON_SPARK}/*/src && rm -rf ${CAFFE_ON_SPARK}/data

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:${CAFFE_ON_SPARK}/caffe-public/distribute/lib:${CAFFE_ON_SPARK}/caffe-distri/distribute/lib

WORKDIR /root/spark-1.6.0-bin-hadoop2.6/
