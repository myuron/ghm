{
  description = "A Nix-flake-based Go development environment";

  inputs = {
    nixpkgs = {
      url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    };
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
    };
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, agent-skills, anthropic-skills, ... }@inputs:

    let
      goVersion = 24; # Change this to update the whole stack

      # Agent Skills
      agentLib = agent-skills.lib.agent-skills;
      sources = {
        anthropic = {
          path = anthropic-skills;
          subdir = "skills";
        };
      };
      catalog = agentLib.discoverCatalog sources;
      allowlist = agentLib.allowlistFor {
        inherit catalog sources;
        enable = [ "doc-coauthoring" ];
      };
      selection = agentLib.selectSkills {
        inherit catalog allowlist sources;
        skills = { };
      };

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: {
        go = final."go_1_${toString goVersion}";
      };

      apps = forEachSupportedSystem (
        { pkgs }:
        let
          bundle = agentLib.mkBundle { inherit pkgs selection; };
        in
        {
          skills-install-local = {
            type = "app";
            program = "${agentLib.mkLocalInstallScript { inherit pkgs bundle; }}/bin/skills-install";
          };
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              # go (version is specified by overlay)
              go

              # goimports, godoc, etc.
              gotools

              # https://github.com/golangci/golangci-lint
              golangci-lint
            ];
          };
        }
      );
    };
}
