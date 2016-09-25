---
- hosts: clients mdss
  become: yes
  tasks:
  - name: zip logs
    shell: gzip /var/log/ceph/*log
  - name: create logs dir
    file: path=./logs/{{ansible_nodename}}/ state=directory mode=0755
    delegate_to: localhost
    become: no
  - name: copy logs
    synchronize: mode=pull src=/var/log/ceph/ dest=./logs/{{ansible_nodename}}/
    ignore_errors: yes
  - name: create stats dir
    file: path=./stats/{{ansible_nodename}}/ state=directory mode=0755
    delegate_to: localhost
    become: no
  - name: copy stats.db
    synchronize: mode=pull src=/root/stats.db dest=./stats/{{ansible_nodename}}/
    ignore_errors: yes
  - name: create coredumps dir
    file: path=./crash/{{ansible_nodename}}/ state=directory mode=0755
    delegate_to: localhost
    become: no
  - name: copy coredumps
    synchronize: mode=pull src=/crash/ dest=./crash/{{ansible_nodename}}/
    ignore_errors: yes
