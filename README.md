
# Reverse.nix

Leveraging [microvm.nix](https://github.com/microvm-nix/microvm.nix) to provide a fast and simple malware reverse engineering environment

## One-liners

### On NixOS (with flakes)

```bash
nix run github:Yunor743/reverse.nix#coruscant
```

### On others *nix distros

```bash
sudo docker run -v $(pwd):/workspace -w /workspace --rm -it --device /dev/kvm --privileged nixos/nix nix run --extra-experimental-features 'nix-command flakes' github:Yunor743/reverse.nix#coruscant
```

