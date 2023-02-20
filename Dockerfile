ARG BASE_TAG=latest
FROM ucsdets/datahub-base-notebook:$BASE_TAG

USER root

# tensorflow, pytorch stable versions
# https://pytorch.org/get-started/previous-versions/
# https://www.tensorflow.org/install/source#linux

RUN apt-get update && \
	apt-get install -y \
			libtinfo5 build-essential g++ libglew-dev libjpeg8-dev zlib1g-dev
#			nvidia-cuda-toolkit

RUN ln -s libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5

COPY run_jupyter.sh /
RUN chmod +x /run_jupyter.sh


COPY cudatoolkit_env_vars.sh /etc/datahub-profile.d/cudatoolkit_env_vars.sh
COPY cudnn_env_vars.sh /etc/datahub-profile.d/cudnn_env_vars.sh
COPY activate.sh /tmp/activate.sh

RUN chmod 777 /etc/datahub-profile.d/*.sh /tmp/activate.sh



#RUN conda install cudatoolkit=10.2 \
#RUN conda install cudatoolkit=10.1 \
#				  cudatoolkit-dev=10.1\
#				  cudnn \
#				  nccl \
#				  -y

RUN conda install \
	cudatoolkit=11.2 \
	cudnn=8.1.0 \
	nccl \
	-y && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER

# Install pillow<7 due to dependency issue https://github.com/pytorch/vision/issues/1712
RUN pip install --no-cache-dir  datascience \
	PyQt5 \
	scapy \
	nltk \
	opencv-contrib-python-headless \
	opencv-python \
	pycocotools \
	pillow \
	tensorflow==2.11.0 && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER
#RUN pip install --no-cache-dir  datascience \
#								PyQt5 \
#								scapy \
#								nltk \
#								opencv-contrib-python-headless \
#								jupyter-tensorboard \
#								opencv-python \
#								pycocotools \
#								"pillow<7"


ARG TORCH_VER="1.7.1+cu101"
ARG TORCH_VIS_VER="0.8.2+cu101"
ARG TORCH_AUD_VER="0.7.2"
# torch must be installed separately since it requires a non-pypi repo. See stable version above
#RUN pip install torch==1.5.0+cu101 torchvision==0.6.0+cu101 pytorch-ignite -f https://download.pytorch.org/whl/torch_stable.html;

RUN pip install torch==${TORCH_VER} torchvision==${TORCH_VIS_VER} torchaudio==${TORCH_AUD_VER} \
	-f https://download.pytorch.org/whl/torch_stable.html && \
	fix-permissions $CONDA_DIR && \
	fix-permissions /home/$NB_USER

#RUN conda install pytorch torchvision torchaudio cudatoolkit=10.2 -c pytorch

RUN ln -s /usr/local/nvidia/bin/nvidia-smi /opt/conda/bin/nvidia-smi

USER $NB_UID:$NB_GID
ENV PATH=${PATH}:/usr/local/nvidia/bin:/opt/conda/bin

RUN . /tmp/activate.sh
CMD ["/bin/bash"]
