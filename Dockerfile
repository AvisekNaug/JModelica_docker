FROM ubuntu:18.04



MAINTAINER Avisek Naug <avisek.naug@vanderbilt.edu>



# Set environment variables
ENV SRC_DIR /usr/local/src

ENV MODELICAPATH /usr/local/JModelica/ThirdParty/MSL
ENV JMODELICA_HOME=/usr/local/JModelica
ENV PYTHONPATH=/usr/local/JModelica/Python

ENV IPOPT_HOME=/usr/local/Ipopt-3.12.4
ENV SUNDIALS_HOME /usr/local/JModelica/ThirdParty/Sundials

ENV HOME /home/developer
ENV USER developer

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JCC_JDK /usr/lib/jvm/java-8-openjdk-amd64

# Make it non-interactive
ENV DEBIAN_FRONTEND noninteractive


# Installing pre-compiled packages
RUN apt-get update && \
	apt-get install -y \
	g++ \
	subversion \
	gfortran \
	ipython \
	cmake \
	swig \
	ant \
	python-dev python-pip python-tk \
	python-numpy \
	python-scipy \
	python-matplotlib \
	cython \
	python-lxml \
	python-nose \
	python-jpype \
	zlib1g-dev \
	libboost-dev \
	wget \
	unzip \
	sudo \
	nano

# Install Java 8
RUN apt install -y openjdk-8-jdk
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-oracle

# Install jcc-3.0 to avoid error in python -c "import jcc"
RUN pip install --upgrade jcc==3.5


# Installing Ipopt
RUN cd $SRC_DIR && \
	wget -O - https://github.com/AvisekNaug/JModelica_docker/raw/master/Ipopt-3.12.4.tgz | tar xzf - && \
	cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Blas && \
	./get.Blas && \
	cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Lapack && \
	./get.Lapack && \
	cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Mumps && \
	./get.Mumps && \
	cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Metis && \
	./get.Metis && \
	cd $SRC_DIR/Ipopt-3.12.4 && \
	mkdir build && \
	cd build && \
	../configure --prefix=/usr/local/Ipopt-3.12.4 && \
	make install



# Installing Jmodelica: Copy Jmodelica zip file from local system to inside of the docker 
COPY jmodelica.zip $SRC_DIR

# Installing JModelica
RUN cd $SRC_DIR && \
	unzip jmodelica.zip && \
	mv JModelica.org-2.14 JModelica && \
	cd JModelica && \
	mkdir build && \
	chmod +x * && \
	cd build && \
	../configure --with-ipopt=/usr/local/Ipopt-3.12.4 --prefix=/usr/local/JModelica && \
	make install && \
	make casadi_interface

# Remove source code
RUN rm -rf $SRC_DIR

# Create home dir, add yourself to sudoers etc.; Replace 1000 with your user / group id
RUN export uid=1003 gid=1003 && \
	mkdir -p /home/developer && \
	mkdir -p /etc/sudoers.d && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
	chmod 0440 /etc/sudoers.d/developer && \
	chown ${uid}:${gid} -R /home/developer

# ================NEW Installations for installing miniconda=================================

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /home/developer/miniconda3/bin:$PATH
ENV PYTHONPATH /home/developer/miniconda3/envs/modelicagym/lib/python3.8/site-packages:$PYTHONPATH

RUN apt-get update --fix-missing && \
	apt-get install -y \
	wget bzip2 ca-certificates curl git && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# =========Installing miniconda===========
RUN cd $HOME && \
	mkdir Downloads && \
	cd Downloads/ && \
	wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
	/bin/bash miniconda.sh -b -p /home/developer/miniconda3 && \
	rm miniconda.sh && \
	/home/developer/miniconda3/bin/conda clean -tipsy && \
	ln -s /home/developer/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /home/developer/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc

# Don't activate conda on startup
RUN conda config --set auto_activate_base false

COPY environment.yml .
RUN conda env create -f environment.yml && conda clean -a
# =========Installing miniconda===========


# Fix matplotlib issues
RUN mkdir -p /root/.config/matplotlib && \
	echo "backend : tkagg" > /root/.config/matplotlib/matplotlibrc

USER developer
# make sure user does not have root access
WORKDIR /home/${USER}

ENTRYPOINT echo "Welcome to the Jmodelica container! Author: avisek.naug@vanderbilt.edu" && /bin/bash -i
