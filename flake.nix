{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    microvm.url = "github:microvm-nix/microvm.nix";
  };
  outputs = { self, nixpkgs, microvm }:
    let
      system = "x86_64-linux";
      vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          microvm.nixosModules.microvm
          {
            system.stateVersion = "25.05";
            networking.hostName = "my-vm";
            services.getty.autologinUser = "root";
            environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
              radare2
              neovim
            ];
            microvm = {
              hypervisor = "qemu";
              shares = [{
                tag = "ro-store";
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
                proto = "9p";
              }];
              interfaces = [{
                type = "user";
                id = "qemu";
                mac = "02:00:00:01:01:01";
              }];
              forwardPorts = [{
                host.port = 2222;
                guest.port = 22;
              }];
            };
            networking.firewall.allowedTCPPorts = [ 22 ];
            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
            };
          }
        ];
      };
    in {
      nixosConfigurations.my-vm = vm;
      apps.${system}.my-vm = {
        type = "app";
        program = "${vm.config.microvm.runner.qemu}/bin/microvm-run";
      };
    };
}
