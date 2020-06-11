## Adapted from https://hub.docker.com/r/makarius/isabelle
FROM ubuntu
SHELL ["/bin/bash", "-c"]

# packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && \
  apt-get install -y curl less libfontconfig1 libgomp1 libwww-perl rlwrap unzip texlive-full && \
  apt-get clean

# user
RUN useradd -m isabelle && (echo isabelle:isabelle | chpasswd)
USER isabelle

# Isabelle
WORKDIR /home/isabelle
RUN curl -L -O  http://isabelle.in.tum.de/dist/Isabelle2020_linux.tar.gz && \
  tar xzf Isabelle2020_linux.tar.gz && \
  rm Isabelle2020_linux.tar.gz && \
  mv Isabelle2020 Isabelle && \
  perl -pi -e 's,ISABELLE_HOME_USER=.*,ISABELLE_HOME_USER="\$USER_HOME/.isabelle",g;' Isabelle/etc/settings && \
  perl -pi -e 's,ISABELLE_LOGIC=.*,ISABELLE_LOGIC=HOL,g;' Isabelle/etc/settings && \
  Isabelle/bin/isabelle build -o system_heaps -b HOL

# Afp
RUN curl -L -O https://www.isa-afp.org/release/afp-2020-04-30.tar.gz && \
  tar xzf afp-current.tar.gz && \
  rm afp-current.tar.gz && \
  mkdir -p ~/.isabelle/Isabelle2020/ && \
  echo "/home/isabelle/afp-2020-04-30/thys" >> ~/.isabelle/ROOTS && \
  echo "/home/isabelle/afp-2020-04-30/thys" >> ~/.isabelle/Isabelle2020/ROOTS


ENV PATH="/home/isabelle/Isabelle/bin:${PATH}"