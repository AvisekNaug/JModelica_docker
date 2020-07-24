FROM ubuntu:18.04


MAINTAINER Avisek Naug <avisek.naug@vanderbilt.edu>


# Set environment variables
ENV SRC_DIR=/usr/local/src \
	MODELICAPATH=/usr/local/JModelica/ThirdParty/MSL \
	JMODELICA_HOME=/usr/local/JModelica \
	PYTHONPATH=/usr/local/JModelica/Python \
	IPOPT_HOME=/usr/local/Ipopt-3.12.4 \
	SUNDIALS_HOME=/usr/local/JModelica/ThirdParty/Sundials \
	HOME=/home/developer \
	USER=developer \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
	JCC_JDK=/usr/lib/jvm/java-8-openjdk-amd64 \
	DEBIAN_FRONTEND=noninteractive \
	LANG=C.UTF-8 LC_ALL=C.UTF-8 \
	PATH=/home/developer/miniconda3/bin:$PATH \
	PYTHONPATH=/home/developer/miniconda3/envs/modelicagym/lib/python3.8/site-packages:$PYTHONPATH

# Installing Jmodelica: Copy Jmodelica zip file from local system to inside of the docker 
COPY jmodelica.zip $SRC_DIR

# Installing pre-compiled packages
RUN apt-get update --fix-missing && \
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
	nano \
	openjdk-8-jdk && \
	ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-oracle && \
	pip install --upgrade jcc==3.5 && \
	cd $SRC_DIR && \
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
	make install && \
	cd $SRC_DIR && \
	unzip jmodelica.zip && \
	rm -rf jmodelica.zip && \
	mv JModelica.org-2.14 JModelica && \
	cd JModelica && \
	mkdir build && \
	chmod +x * && \
	cd build && \
	../configure --with-ipopt=/usr/local/Ipopt-3.12.4 --prefix=/usr/local/JModelica && \
	make install && \
	make casadi_interface && \
	rm -rf $SRC_DIR && \
	export uid=1003 gid=1003 && \
	mkdir -p /home/developer && \
	mkdir -p /etc/sudoers.d && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
	chmod 0440 /etc/sudoers.d/developer && \
	chown ${uid}:${gid} -R /home/developer && \
	cd $HOME && \
	mkdir Downloads && \
	cd Downloads/ && \
	wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
	/bin/bash miniconda.sh -b -p /home/developer/miniconda3 && \
	rm miniconda.sh && \
	/home/developer/miniconda3/bin/conda clean -tipsy && \
	ln -s /home/developer/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /home/developer/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    conda config --set auto_activate_base false && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


COPY environment.yml .
RUN conda env create -f environment.yml && conda clean -a && \
	mkdir -p /root/.config/matplotlib && \
	echo "backend : tkagg" > /root/.config/matplotlib/matplotlibrc && \
	rm -rf environment.yml

USER developer
WORKDIR /home/${USER}

ENTRYPOINT echo "Welcome to the Jmodelica container! Author: avisek.naug@vanderbilt.edu" && /bin/bash -i
