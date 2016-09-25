#!/bin/sh

# cp .gitconfig

pacman --noconfirm -Syu
pacman --noconfirm -S base-devel git ansible python2-netaddr rsync screen htop wget vim python2-virtualenv
virtualenv2 linode-env
(source linode-env/bin/activate; pip install linode-python paramiko)
ssh-keygen
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQCpgLVt7Zphmf6nqD+9BC0N91jdmaY6ZpvrYWlzbhxXITQ6juIEtegnlZ+8ohdeEfHFBiyu1xOSQSM1X1ugvpPQE94UqQg7JVb0tuoUCNJHYnIuv8T4YgyP0/vEV48k2G0BBWlP+IJ5f1iDvZuLHWLR5JSgGqh5ELaaHr7Cbyb6JlImldb7SDIoPHMCZ+n6dLO8l5Zy7qWelw6aeA770xmPucBr6t/BVns2g77XgJz6zFd99yEaDy27i8jfzL7WqR9i93yVE9EsL7tuOjg6G9KUzxBF0bg9iVsJXypvcBuG0JwQ+SDKqYw/cN4iLy5qBa6Siqrfpc/LKU21VNmJ0e5eXNgKKbMBpBb8GVmkoLaSRcXw7LclWopjNDA+meUhDAwU7b97N7cqN8BYhBKQyiShXFHMKLuNo2fSuTRt/icfb9VisKNGBdvwgV0oOlrqbXMzZKmj9amb9b+3JDBTGB7ioCsj5x/Evf9srXRrQ9kikIr1aBbVXIWir/lasNWVydcmUYsNi8L7W0vXArLwp+GgOXJFeZUiD3z9LG4CouRxMSwoj3lgWeL2ZR8feH4D/SP/+QmBdU6+aG97au9qreeXi5X8QTR3LND0DwwEKczX+3s+Fa950Oieom/gXC57PVKVh90KVoAGw3HzJTlZrauOtLkYbTUAX6woOMhAtJ5oWuDDT4UrHQj37jRrrl2dETLwKwUJN2+2L07vnnOZ4ABcGWLsU6d3bXeUBlw3pdsYqPebDKUEpjL2kUOw+zmfjEfdVx9BfrvExvDX+3MkxccCJ8FY7od1s5fGEFHsXnIiMnLO/HZb/JN+Aoe+/ExadIcYwJnWcCJyly2/532kGFUlzOliCwPxgJpjWCKQAv6LjWmxoPXiA4JI0bp6y7lMEjmV2Bp3mwphlsW/r8Ie5hg1UPh/ttHRp/VZgcV8e6nNmP/qc6k9b2DWTNFqtWqm1hXLOwq08HzUEeH9mTqvenyAbv2RFMOS18Y2K+4BKUzHwZujrz9qEh/kqtpFScEIXkOJ+HZz3mI6XfjWFIPS487yRGfUvW3+nSWhvHc8vJY21bFRKdjD84qCVlZ2BfOCGUZSKftVItEiqXMTRs3RZd5epfCVZbJuA0hG16jUseeHqqZqDtlbLkzkxtS6v3iGRnPh/Ke/94FHHCzvYY8cmMYAVaM6p/G3edWftbaEtN70Fo7VKxPrpPzuSRZ7Vxmnb+Zad95DxxAC/vtMy/vkBVIP6dyn4HGxqa1oECFMe4oXdhnxZQoPzvWxb8upcXeAeOMMbcIlMq5a+dCBPGFNKhNhrb+9uAEDHwjE7rZlMJVSvt9v1S4hll6jiYIap+7n4reSKrS45aO9U0xiKXJJDohh pdonnell@icewind' | tee -a .ssh/authorized_keys
git clone --branch multimds-tests https://github.com/batrick/ceph-ansible.git
