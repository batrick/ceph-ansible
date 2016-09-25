# This Dockerfile is for setting up a dev environment for launching Ceph
# clusters on Linode.

FROM ubuntu:16.04

WORKDIR /root
RUN apt-get update
RUN apt-get install -y build-essential git ansible python-netaddr rsync
RUN wget -O vagrant_1.8.5_x86_64.deb https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5_x86_64.deb
RUN dpkg -i vagrant_1.8.5_x86_64.deb
RUN rm -f vagrant_1.8.5_x86_64.deb
RUN vagrant plugin install vagrant-linode
# Download patch from https://github.com/displague/vagrant-linode/pull/66
RUN wget -O .vagrant.d/gems/gems/vagrant-linode-0.2.7/lib/vagrant-linode/actions/create.rb https://raw.githubusercontent.com/batrick/vagrant-linode/3ac3e6768b5c1f6bf0d67d114003270d821b300c/lib/vagrant-linode/actions/create.rb
RUN mkdir .ssh && ssh-keygen -f .ssh/id_rsa -t rsa -N ''
RUN git clone https://github.com/batrick/ceph-ansible.git
WORKDIR /root/ceph-ansible
RUN git checkout multimds-tests
