# tvm-tool
a tool for convenient model build and deploy use tvm
## How to use
build.sh - script for auto build model use [tvm](https://github.com/apache/tvm). 
Usage: build.sh [OPTIONS] [VALUE]
 Options:
 -m : model filename, format onnx.
 -t : build target, llvm or cuda, default llvm.
Rember to modify the docker image used in the script to your image.
## build docker images
- make sure build tvm first. see the official guide [tvm](https://github.com/apache/tvm).
- use the Dockerfile in `docker` folder to build image.
