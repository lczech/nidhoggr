FROM ubuntu:18.04

RUN apt-get update &&\
    apt-get -y install wget git cmake build-essential zlib1g-dev gzip unzip flex bison

RUN git clone --recursive https://github.com/BenoitMorel/ParGenes.git &&\
    cd ParGenes/ && git checkout tags/v1.1.2 && ./install.sh $(nproc)


RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh &&\
    chmod u+x miniconda.sh &&\
    ./miniconda.sh -b &&\
    /root/miniconda3/condabin/conda init &&\
    rm -f miniconda.sh 

RUN /root/miniconda3/condabin/conda install -y -c conda-forge -c bioconda snakemake

RUN git clone --recursive https://github.com/lczech/nidhoggr.git

# when testing, this obviates the need to commit/pull
# COPY . /nidhoggr

ENTRYPOINT ["/nidhoggr/search.sh"]
