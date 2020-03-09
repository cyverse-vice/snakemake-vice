FROM jupyter/scipy-notebook:latest

# reset user to root for installing additional packages
USER root

COPY jupyter_notebook_config.json /opt/conda/etc/jupyter/jupyter_notebook_config.json
# Add project files
COPY environment.yml /home/jovyan/environment.yml
COPY Snakefile_mrsa /home/jovyan/Snakefile_mrsa
COPY config.yml /home/jovyan/config.yml
COPY code /home/jovyan/code

# Use bash as shell
SHELL ["/bin/bash", "-c"]

# Install a few dependencies for iCommands, text editing, and monitoring instances
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    gcc \
    gnupg \
    htop \
    less \
    libfuse2 \
    libpq-dev \
    libssl1.0 \
    lsb \
    nano \
    nodejs \
    python-requests \
    software-properties-common \
    vim \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    fontconfig \
    git \
    language-pack-en \
    tzdata \
    unzip \
    && apt-get clean

# Install iCommands
RUN wget https://files.renci.org/pub/irods/releases/4.1.12/ubuntu14/irods-icommands-4.1.12-ubuntu14-x86_64.deb && \
dpkg -i irods-icommands-4.1.12-ubuntu14-x86_64.deb && \
rm irods-icommands-4.1.12-ubuntu14-x86_64.deb

# reset container user to jovyan
USER jovyan

# Install conda environment
RUN conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda env update -n base -f environment.yml && \
    conda clean --all

# set the work directory
WORKDIR /home/jovyan/

# Open port for running Jupyter Notebook
# (Jupyter Notebook has to be separately installed in the container)
EXPOSE 8888

ENTRYPOINT ["jupyter"]

CMD snakemake -rp --configfile config.yml

CMD ["lab", "--no-browser"]
