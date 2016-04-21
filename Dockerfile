FROM ubuntu:16.04
MAINTAINER Mathias Bourgoin <mathias.bourgoin@gmail.com>
RUN apt-get -y update
RUN apt-get -y install sudo pkg-config git build-essential m4 software-properties-common aspcud unzip curl libx11-dev ocaml ocaml-native-compilers camlp4-extra
RUN apt-get install -y git libffi-dev
RUN apt-get install -y emacs
RUN apt-get install -y pkg-config
RUN apt-get install -y wget aspcud

RUN git clone https://github.com/mathiasbourgoin/amd_sdk.git

RUN sh amd_sdk/amd_sdk.sh

RUN apt-get install -y opam

RUN useradd -ms /bin/bash spoc && echo "spoc:spoc" | chpasswd && adduser spoc sudo
USER spoc
WORKDIR /home/spoc
CMD /bin/bash



#RUN wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s ~/.opam

RUN opam init -a --root /home/spoc/.opam

RUN opam switch 4.02.3

RUN eval `opam config env`


RUN eval `opam config env`&& opam update
RUN eval `opam config env` && opam depext conf-pkg-config.1.0
RUN eval `opam config env` && opam install camlp4.4.02+1
RUN eval `opam config env` && opam install ctypes
RUN eval `opam config env` && opam install ocp-indent
RUN eval `opam config env` && opam install ctypes-foreign
#RUN opam install merlin
RUN eval `opam config env` && opam install ocamlfind


RUN rm -rf SPOC
RUN git clone https://github.com/mathiasbourgoin/SPOC.git

ADD .bashrc /home/spoc/.bashrc

WORKDIR SPOC/Spoc
RUN eval `opam config env` && make
RUN eval `opam config env` && ocamlfind install spoc *.cma *.a *.so *.cmxa *.cmi META
RUN cd extension && eval `opam config env` && make
RUN cd extension && eval `opam config env` && make install 

WORKDIR ../SpocLibs/Sarek
RUN eval `opam config env` && make && make install 




RUN mkdir /home/spoc/emacs_install
ADD emacs-pkg-install.el  /home/spoc/emacs_install/emacs-pkg-install.el
ADD emacs-pkg-install.sh  /home/spoc/emacs_install/emacs-pkg-install.sh

WORKDIR /home/spoc/emacs_install

RUN ./emacs-pkg-install.sh auto-complete
RUN ./emacs-pkg-install.sh company
RUN ./emacs-pkg-install.sh company-irony
RUN eval `opam config env`&& opam install merlin
RUN eval `opam config env`&& opam install tuareg
RUN eval `opam config env`&& opam install ocp-indent

ADD .emacs /home/spoc/.emacs

WORKDIR /home/spoc
