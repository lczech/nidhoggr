FROM ubuntu:18.04

# deps from root
RUN apt-get update &&\
    apt-get -y install wget git cmake build-essential zlib1g-dev gzip unzip flex bison

# set up a user
RUN useradd -m monkey
USER monkey
RUN echo $HOME

# deps inside user
RUN cd ~ && git clone --recursive https://github.com/BenoitMorel/ParGenes.git &&\
    cd ParGenes/ && git checkout tags/v1.1.2 && ./install.sh $(nproc)


RUN cd ~ && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh &&\
    chmod u+x miniconda.sh &&\
    ./miniconda.sh -b &&\
    ./miniconda3/condabin/conda init &&\
    rm -f miniconda.sh 

RUN cd ~ && ./miniconda3/condabin/conda install -y -c conda-forge -c bioconda snakemake

RUN cd ~ && git clone --recursive https://github.com/lczech/nidhoggr.git

# when testing, this obviates the need to commit/pull
# COPY . /home/monkey/nidhoggr

# RUN ls -al /home/monkey

WORKDIR /home/monkey

ENTRYPOINT ["/home/monkey/nidhoggr/search.sh"]
