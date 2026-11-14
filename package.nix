{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
  versionCheckHook,
}:
let
  inherit (stdenv) hostPlatform;
  inherit (hostPlatform) system;
  release = builtins.fromJSON (builtins.readFile ./release.json);
  inherit (release) version hashes;
  arch = hostPlatform.parsed.cpu.name;
  os = hostPlatform.parsed.kernel.name;
in
assert hashes ? ${system} || throw "microsandbox ${version} has no release asset for ${system}";
stdenv.mkDerivation {
  pname = "microsandbox";
  inherit version;

  src = fetchurl {
    url = "https://github.com/superradcompany/microsandbox/releases/download/v${version}/microsandbox-${os}-${arch}.tar.gz";
    sha256 = hashes.${system};
  };

  # The bundle has no top-level directory.
  sourceRoot = ".";

  # The vendor binaries are already stripped.
  dontStrip = true;

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optional hostPlatform.isLinux autoPatchelfHook;

  # libstdc++ and libgcc_s are needed on Linux.
  buildInputs = lib.optional hostPlatform.isLinux stdenv.cc.cc.lib;

  # Ensure parity between Nix package version and binary version.
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 msb $out/bin/msb
    install -Dm755 -t $out/lib libkrunfw.*

    ${lib.optionalString hostPlatform.isLinux "autoPatchelf $out/bin"}
    installShellCompletion --cmd msb \
      --bash <($out/bin/msb completion bash) \
      --fish <($out/bin/msb completion fish) \
      --zsh <($out/bin/msb completion zsh)
    runHook postInstall
  '';

  meta = {
    platforms = builtins.attrNames hashes;
    description = "Easy, fast, programmable and local-first microVM runtime";
    homepage = "https://microsandbox.dev";
    license = with lib.licenses; [
      asl20 # msb
      gpl2Only # linux kernel + patches
      lgpl21Only # libkrunfw
    ];
    mainProgram = "msb";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
