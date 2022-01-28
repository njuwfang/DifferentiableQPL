FROM mcr.microsoft.com/quantum/iqsharp-base:latest

USER root
COPY . ${HOME}

RUN pip install ./dist/pqwhile-0.1.0.tar.gz