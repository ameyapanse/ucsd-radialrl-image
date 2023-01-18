# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_CONTAINER=ucsdets/scipy-ml-notebook:2023.1-stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root

RUN apt-get update && \
    apt-get -y install g++

RUN apt-get -y install libglew-dev

# 3) install packages using notebook user
USER apanse
WORKDIR /home/apanse
RUN mkdir -p radialrl-atari && \
    mkdir -p radialrl-mujoco && \
    mkdir -p radialrl-procgen

COPY ./requirements/atari-requirements.txt radialrl-atari/requirements.txt
COPY ./requirements/mujoco-requirements.txt radialrl-mujoco/requirements.txt
COPY ./requirements/procgen-requirements.txt radialrl-procgen/requirements.txt

RUN python3 -m venv /home/apanse/radialrl-atari && \
    python3 -m venv /home/apanse/radialrl-mujoco && \
    python3 -m venv /home/apanse/radialrl-procgen

RUN . /radialrl-atari/bin/activate && which python && pip install -r --no-cache-dir requirements.txt
RUN . /radialrl-mujoco/bin/activate && which python && pip install -r --no-cache-dir requirements.txt
RUN . /radialrl-procgen/bin/activate && which python && pip install -r --no-cache-dir requirements.txt

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
