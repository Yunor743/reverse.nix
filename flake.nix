{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    microvm.url = "github:microvm-nix/microvm.nix";
  };
  outputs = { self, nixpkgs, microvm }:
    let
      system = "x86_64-linux";
      coruscant = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          microvm.nixosModules.microvm
          {
            system.stateVersion = "25.05";
            networking.hostName = "coruscant";
            services.getty.autologinUser = "root";
            environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
              radare2
              neovim
              git
              pkg-config
            ];
            microvm = {
              hypervisor = "qemu";
              mem = 4096;
              vcpu = 4;

              shares = [
                {
                  tag = "ro-store";
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                  proto = "9p";
                }
                {
                  tag = "host-shared";
                  source = ".";
                  mountPoint = "/shared";
                  proto = "9p";
                }
              ];
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
      nixosConfigurations.coruscant = coruscant;
      apps.${system}.coruscant = {
        type = "app";
        program = "${coruscant.config.microvm.runner.qemu}/bin/microvm-run";
      };
    };
}
