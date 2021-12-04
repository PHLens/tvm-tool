FROM ubuntu:18.04
COPY ./tvm/python /home/tvm/python
COPY ./tvm/build/libtvm.so /usr/local/bin/
COPY ./tvm/build/libtvm_runtime.so /usr/local/bin/

RUN apt-get update && apt-get install -y --no-install-recommends make g++ wget libopenblas-dev

COPY /install/ubuntu1804_install_python.sh /home
RUN /home/ubuntu1804_install_python.sh

COPY /install/ubuntu_install_python_package.sh /home
RUN /home/ubuntu_install_python_package.sh

ENV TVM_HOME=/home/tvm
ENV PYTHONPATH=$TVM_HOME/python:${PYTHONPATH}
ENV OPENBLAS_CORETYPE=ARMV8

COPY /install/ubuntu1804_install_llvm.sh /home
RUN /home/ubuntu1804_install_llvm.sh

WORKDIR /home

COPY ./build.py /home

ENTRYPOINT ["python3","-u","build.py"]

