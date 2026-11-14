# microsandbox-bin-nix

Nix packaging for the official prebuilt [microsandbox](https://microsandbox.dev)
`msb` CLI and matching `libkrunfw`.

## Use

```bash
nix run github:xuoe/microsandbox-bin-nix -- --version
nix shell github:xuoe/microsandbox-bin-nix
```

Supports `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin` (Apple silicon).
Linux requires `/dev/kvm` access. On NixOS:

```nix
users.users.YOUR_USER.extraGroups = [ "kvm" ];
```

## Install

To add `msb` to your user profile:

```bash
nix profile add github:xuoe/microsandbox-bin-nix
```

### NixOS

Add this input to your flake:

```nix
inputs.microsandbox = {
  url = "github:xuoe/microsandbox-bin-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

With `microsandbox` in your `outputs` arguments, add this inline NixOS module
(adjust the system as needed):

```nix
{
  environment.systemPackages = [
    microsandbox.packages.x86_64-linux.default
  ];
}
```

The flake also exports `overlays.default`. For non-flake use, the repository
provides `default.nix` and `overlay.nix`.

## Updates

Updates are checked and built automatically every six hours. Refresh your input with:

```bash
nix flake update microsandbox
```
