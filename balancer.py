import json
import logging
import sys
import time

from contextlib import closing

from paramiko.client import SSHClient, AutoAddPolicy

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(levelname)s %(message)s')

def get_subtrees(node):
    with closing(SSHClient()) as client:
        client.set_missing_host_key_policy(AutoAddPolicy())
        client.connect(hostname=node['ip_public'], username=node['user'])
        stdin, stdout, stderr = client.exec_command("ceph --admin-daemon /var/run/ceph/ceph-mds.*.asok status")
        status = json.loads(stdout.read())
        subtrees = []
        if status['state'] == "up:active":
            stdin, stdout, stderr = client.exec_command("ceph --admin-daemon /var/run/ceph/ceph-mds.*.asok get subtrees")
            subtrees = stdout.read()
            print(subtrees)
            subtrees = json.loads(subtrees)
        return {"node":node, "status":status, "subtrees":subtrees}

def listroot(node):
    with closing(SSHClient()) as client:
        client.set_missing_host_key_policy(AutoAddPolicy())
        client.connect(hostname=node['ip_public'], username=node['user'])
        stdin, stdout, stderr = client.exec_command("find /mnt/ -mindepth 1 -maxdepth 1 -type d -printf '/%f\\0'")
        entries = set(filter(lambda x: len(x)>0, stdout.read().split('\0')))
        logging.info("root entries: {}".format(entries))
        return entries

def export(node, source, target, path):
     logging.info("export {} {} {}".format(source, target, path))
     with closing(SSHClient()) as client:
        client.set_missing_host_key_policy(AutoAddPolicy())
        client.connect(hostname=node['ip_public'], username=node['user'])
        stdin, stdout, stderr = client.exec_command("ceph --admin-daemon /var/run/ceph/ceph-mds.*.asok export dir '{p}' {t}".format(p=path, t=target))
        result = json.loads(stdout.read())
        if result['return_code'] != 0:
            raise RuntimeError("export failed: {}", result)

def balance(mdss, clients):
    if True:
        subtrees = filter(lambda s: s['status']['state'] == "up:active", map(get_subtrees, mdss))
        logging.debug("subtrees: {}".format(str(subtrees)))

        # get node with auth on root subtree
        authdirs = {}
        rank0 = None
        for subtree in subtrees:
            dirs = set()
            rank = subtree['status']['whoami']
            authdirs[rank] = (subtree['node'], dirs)
            for s in subtree['subtrees']:
                path = s['dir']['path']
                if s['is_auth']:
                    if path == '':
                        rank0 = rank
                    elif path[0] != '~':
                        assert(path.count('/') == 1)
                        dirs.add(path)

        # get top-level directories that are not managed by other non-zero ranks
        entries = listroot(clients[0])
        map(lambda s: entries.difference_update(s), [authdir[1] for authdir in authdirs.values()])
        authdirs[rank0][1].update(entries)

        total = 0
        for authdir in authdirs.values():
            for dirs in authdir[1]:
                total += 1
        ideal = total // len(authdirs)

        changed = False
        for source in authdirs.keys():
            if source in authdirs:
                node = authdirs[source][0]
                paths = authdirs[source][1]
                for target in authdirs.keys():
                    if len(paths) > ideal:
                        if target != source and len(authdirs[target][1]) < ideal:
                            logging.info("target {} paths: {}", target, str(authdirs[target][1]))
                            path = paths.pop()
                            export(node, source, target, path)
                            changed = True
                            authdirs[target][1].add(path)
                    else:
                        break

        return not changed

def main():
    with open("linodes") as f:
        linodes = json.loads(f.read())

    mdss = filter(lambda linode: linode['group'] == 'mdss', linodes)
    clients = filter(lambda linode: linode['group'] == 'clients', linodes)

    while not balance(mdss, clients):
        time.sleep(10)

if __name__ == "__main__":
    main()
