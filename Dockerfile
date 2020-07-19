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


# Create home dir, add yourself to sudoers etc.; Replace 1000 with your user / group id
RUN export uid=1003 gid=1003 && \
	mkdir -p /home/developer && \
	mkdir -p /etc/sudoers.d && \
	echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:${uid}:" >> /etc/group && \
	echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
	chmod 0440 /etc/sudoers.d/developer && \
	chown ${uid}:${gid} -R /home/developer




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

# Commented since developer is not getting write priviledges
# USER developer
