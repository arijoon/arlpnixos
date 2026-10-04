{ ... }:
{
  users.groups.prediction-sports = { };

  users.users.prediction-sports = {
    isSystemUser = true;
    group = "prediction-sports";
    extraGroups = [ "docker" ];
    home = "/var/lib/prediction-sports";
    createHome = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCLVEnr4Q5qyBjZADvizKYNg2ILv3uKbZ3Q1jHrhCghQPbpAzoyq39SW8v5DSGWo9PeKAVaATIbvGmL2Ee+z5fv7u1ADaMzQYxmq6M4dFpmanpVnjCuFL5pQdhppsOpJlbmVBkhp0NVWuB/h9hDSpur4ykac/39ODCcKBVO1YmjoIDLFcG+eJ0wLAXLshzKC2lCHSYZE56CRFdo9MhIStWj/4CzcEGnzh+/bjlItDtt2S4aKlJQx0/ex07keyMxyPAZz+bsw4Ztixl/qrjZhLgygq3bFCn6uD4mHTMVtb6WTvW95UN2nIn/DXgBLZFT+aBpmNo+koYMcx/Zz0duNS0EWwFjBHv9fB7Gi8Xvh4pdCs78ASmk1SOkwDAzE0Jwh3PiCKLxJLQ/lRVyNWAhrlWS7KACpJQEoIS1I1ZrY0LCa3HYvQSFM6ZHEKW1SAdfa59jwQiDceQKnrEwrqAZVZxOl48pQuVVVT3NJ0Pj7/8DWM2rWjFSxEQYgeKs41EkAcXXn7ObQ7kG3sM0VSLLP9rVMHAA2+eFracD6MSYvkHWkEiE3m1og4gFuDev3SPKjefDy9XTtlNFSyOhaHhY/gLPDDrw9tLTWCUQeyh11iH4VtnEDOs6v3g8pg9Nk9oh/PRN27wMTyFvNucEVMz7X4CgLaJZC7U8q/eo8Xajj5RpxQ== arman@yaraee.net"
    ];
  };
}
