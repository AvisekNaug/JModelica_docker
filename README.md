# Steps to run a Jmodelica docker that supports supports Jmodelica, python2, pyfmi, miniconda3 interaction on a Linux Server

## This assumes that
* Docker is installed
* Docker sudo group is created
* User is added to docker sudo group
* Jmodelica source code is available as a zip file
* Xming is installed on local computer if performing this set up on remote server
* DISPLAY environmental variable is set (for eg "localhost:10.0")

The docker image is hosted on docker hub. If you don't want to build from source run
```bash
docker pull aviseknaug/jmodelica:2.0
```

Do not clone this folder! This repo merely exists to have all the isntructions and is by no means complete.
Note that pymodelica and pyjmi is supported only for python 2 installed with JModelica

# Steps:

## Create directory
```bash
mkdir $HOME/JModelica_docker
cd $HOME/JModelica_docker
```
## Obtain docker file and environment file
```bash
wget https://github.com/AvisekNaug/JModelica_docker/raw/master/Dockerfile
wget https://github.com/AvisekNaug/JModelica_docker/raw/master/environment.yml
```
## Copy Jmodelica Source code in zip format to this directory and rename it
```bash
mv <path to Jmodelica installation zip file> $HOME/JModelica_docker/jmodelica.zip
```
or download JModelica installation source zip from my googledrive using
```bash
source jmodelica_downloader.sh
```

## Build the docker
```bash
docker build --tag jmodelica:2.0 .
```

## Start the docker for generic use(for use with buildings library see [next step](#follow-this-step-is-you-are-starting-the-docker-to-use-with-modelica-buildings-library))

###  If using remote server
Ensure X11 forwarding works correctly(Do this only if working on a remote server). Make sure Xming is installed on local computer and listeing on 10.0
```bash
source x11config.sh
```
```bash
docker run -it -e DISPLAY=${DISPLAY} -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH jmodelica:1.0
```

### or If setting up container on local computer
```bash
docker run -it -e DISPLAY=${DISPLAY} jmodelica:2.0
```

## Follow this step is you are starting the docker to use with modelica buildings library
###  If using remote server
```bash
source x11config.sh
```
```bash
docker run -it -e DISPLAY=${DISPLAY} -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -v $path/to/modelica-buildings_library:path/to/mount/modelica-buildings_library jmodelica:2.0
```
for example for my host system with username nauga, having the buildings library inside buildings_library_dev
```bash
docker run -it -e DISPLAY=${DISPLAY} -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -v home/nauga/buildings_library_dev:/home/developer/buildings_library_dev:ro jmodelica:2.0
```
After starting a container, add location of the buildings library to MODELICAPATH
```bash
export MODELICAPATH=path/to/mount/modelica-buildings_library:$MODELICAPATH
```
for example
```bash
export MODELICAPATH=home/developer/buildings_library_dev:$MODELICAPATH
```

* eg -v $HOME/nauga/buildings_library_dev:/home/developer/buildings_library_dev:ro" for read only. remove "ro" if you want to modify the folder components from inside the docker
### or If setting up container on local computer
```bash
docker run -it -e DISPLAY=${DISPLAY} -v $path/to/modelica-buildings_library:path/to/mount/modelica-buildings_library jmodelica:2.0
```
After starting a container, add location of the buildings library to MODELICAPATH
```bash
export MODELICAPATH=path/to/mount/modelica-buildings_library:$MODELICAPATH
```

## Compile any .mo model in python2 environment using pymodelica
```bash
ipython
```
```ipython
from pymodelica import compile_fmu
model="Buildings.Controls.OBC.CDL.Continuous.Validation.LimPID" #taken form https://github.com/lbl-srg/docker-ubuntu-jmodelica/blob/master/jmodelica.py
fmu_name = compile_fmu(model) # writes the fmu to fmu_name as well as to local folder
```
Now, you can simulate fmu either in pyfmi for python2 or pyfmi for python3

### For python2
```bash
ipython
```
```ipython
from pyfmi import load_fmu
mod = load_fmu(Buildings_Controls_OBC_CDL_Continuous_Validation_LimPID.fmu)
res = mod.simulate()
```
or
### For python3
```bash
conda activate modelicagym
ipython
```
```ipython
from pyfmi import load_fmu
mod = load_fmu(Buildings_Controls_OBC_CDL_Continuous_Validation_LimPID.fmu)
res = mod.simulate()
```

## Other examples in python 2 ipython shell in base environment

```bash
dveloper@container_id# ipython
```

```ipython
from pyfmi.examples import fmi_bouncing_ball
fmi_bouncing_ball.run_demo()
```
This should display the images of position and velocity in a matplotlib plot.

Similarly try,
```ipython
from pyjmi.examples import cstr_casadi
cstr_casadi.run_demo()
```


The following example only runs outside modelicagym conda env as pyjmi is not availablr inside modelicagym env
```ipython
from pyjmi.examples import RLC
RLC.run_demo()
```

```ipython
import matplotlib
matplotlib.use('tkagg')
import matplotlib.pyplot as plt # see link https://github.com/matplotlib/matplotlib/issues/8929#issuecomment-317233404
```

## In case you want to render standard OpenAI gym environments, install the following inside the container
```bash
sudo apt-get update
sudo apt update
sudo apt-get install -y git
sudo apt install -y freeglut3 freeglut3-dev
```
