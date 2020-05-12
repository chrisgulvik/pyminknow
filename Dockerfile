FROM python:3.7-slim-buster

LABEL maintainer="Joe Heffer <j.heffer@sheffield.ac.uk>" \
version=0.0.2

# Create non-root user to run the daemon
RUN useradd minknow --create-home
WORKDIR /home/minknow

ENV GRPC_INSECURE_PORT=9501
EXPOSE $GRPC_INSECURE_PORT 22

# Get security updates and install packages
RUN apt-get update && apt-get --yes install openssh-server rsync \
  # Clear apt cache to reduce image size https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && pip install --upgrade pip

# Create sequencer data directory
ENV MINKNOW_DATA_DIR=/data
RUN mkdir /data && chown minknow:minknow $MINKNOW_DATA_DIR

# Install Python packages
RUN pip install pyminknow

# Compile gRPC modules
COPY compile_grpc.sh .
COPY minknow_lims_interface minknow_lims_interface
RUN pwd && ls -l
RUN sh compile_grpc.sh

RUN chown --recursive minknow:minknow /home/minknow
USER minknow

CMD ["python", "-m", "pyminknow"]
