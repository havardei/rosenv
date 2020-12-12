FROM jupyter/base-notebook:python-3.7.6
USER root
ADD install /opt/install
WORKDIR /opt/install

ENV APP_UID=999 \
    APP_GID=999
RUN groupadd -g "$APP_GID" notebook && \
    useradd -m -s /bin/bash -N -u "$APP_UID" -g notebook notebook && \
    usermod -G users notebook && chmod go+rwx -R "$CONDA_DIR/bin"

ENV HOME=/home/notebook \
    XDG_CACHE_HOME=/home/notebook/.cache/ \
    NB_USER=notebook
RUN mkdir -p /home/notebook/.ipython/profile_default/security/ && chmod go+rwx -R "$CONDA_DIR/bin" && chown notebook:notebook -R "$CONDA_DIR/bin" "$HOME" && \
    mkdir -p "$CONDA_DIR/.condatmp" && chmod go+rwx "$CONDA_DIR/.condatmp" && chown notebook:notebook "$CONDA_DIR"

RUN chown -R $NB_USER /opt/install
RUN chown -R $NB_USER /opt/conda
COPY --chown=$NB_USER jupyter/normalize-username.py jupyter/start-notebook.sh /usr/local/bin/


RUN apt-get -y update \
 && apt-get install -y dbus-x11 \
   firefox \
   xfce4 \
   xfce4-panel \
   xfce4-session \
   xfce4-settings \
   xorg \
   xubuntu-icon-theme\
   mesa-utils \
   libgl1 \
   libgl1-mesa-dri \
   libgl1-mesa-glx \
   libglapi-mesa \
   libglvnd0 \
   libglx-mesa0 \
   libglx0 \
   curl \
   git \
   build-essential \
   cmake \
   ant \
   libvtk7.1p \ 
   libvtk7-java \
   nano

COPY vnc /srv/conda/vnc
COPY vnc/lib64 /usr/lib64


# Install Python 3.6.10 virtual environment
# 1. Add keys
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
# 2. Install venv
RUN apt-get update && \
    apt-get install -y software-properties-common curl && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.6 python3.6-venv

# Install py36 kernel
RUN conda create --name python3.6 python=3.6
RUN source activate python3.6 && \
    pip install ipykernel && \
    python -m ipykernel install --user --name python3.6 --display-name "Python3.6"

RUN pip install escapism

# apt-get may result in root-owned directories/files under $HOME
RUN chmod go+w -R "$HOME" && chown -R $NB_USER "$HOME"  && chown $NB_USER /home
COPY jupyter/python3.6 /opt/conda/share/jupyter/kernels/python3.6

COPY install/default.xml /etc/xdg/xfce4/panel/
RUN /opt/install/noetic.sh

USER $NB_USER
RUN /opt/install/dune.sh
RUN /opt/install/neptus.sh

RUN cd /opt/install && \
   conda env update -n base --file environment.yml

RUN pip install jupyter-launcher-shortcuts
RUN jupyter labextension install jupyterlab-launcher-shortcuts
COPY jupyter/notebook_config.py /opt/.jupyter/notebook_config.py

USER root
RUN cp /opt/install/build/dune* /usr/local/bin/
COPY install/neptus.desktop /usr/share/applications/neptus.desktop

USER $NB_USER
WORKDIR $HOME
CMD ["/usr/local/bin/start-notebook.sh"]
