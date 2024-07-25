# Use the official Python base image
FROM python:3.9-bullseye as build

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Copy the requirements file
COPY ./requirements.txt /tmp/requirements.txt

# Install system dependencies
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt-get --allow-releaseinfo-change update \
    && apt-get install -y --no-install-recommends jq chromium chromium-driver tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Python dependencies
RUN cd /tmp \
    && pip config --global set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip config --global set install.trusted-host pypi.tuna.tsinghua.edu.cn \
    && python3 -m pip install --upgrade pip \
    && PIP_ROOT_USER_ACTION=ignore pip install \
    --disable-pip-version-check \
    --no-cache-dir \
    -r requirements.txt \
    && rm -rf /tmp/* \
    && pip cache purge \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/*

# Copy the application code and scripts
COPY ./scripts /app/scripts
COPY ./main.py /app

# Set environment variable for language
ENV LANG C.UTF-8

# Set the default command
CMD ["python", "main.py"]
