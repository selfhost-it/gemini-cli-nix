# Gemini CLI - Google's AI coding assistant in your terminal
#
# Built from GitHub source using buildNpmPackage.
#
# To update:
#   1. Change `version`
#   2. Update `hash` (run: nix-prefetch-github google-gemini gemini-cli --rev v<VERSION>)
#   3. Update `npmDepsHash` (set to "" and build — nix will tell you the correct hash)
#   4. Run `nix build`

{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs_22
, pkg-config
, libsecret
, python3
}:

let
  version = "0.39.0";
in
buildNpmPackage {
  pname = "gemini-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${version}";
    hash = "sha256-cVEDCnDmICw0b3wQyU3hWynBjn+xPH9Tfmd085nyAUw=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-xysC1nSj70nRyIndJgNgbUh/0Dr1W1p7sZTg0ZuzXNs=";

  # Native dependencies needed by keytar (libsecret) and node-gyp (python3).
  nativeBuildInputs = [ pkg-config python3 ];
  buildInputs = [ libsecret ];

  # The monorepo uses workspaces — npm ci handles them automatically.
  # Build: compile workspaces, then bundle with esbuild.
  npmBuildScript = "bundle";

  # esbuild produces a self-contained bundle/gemini.js.
  # Native addons (keytar, node-pty) are optional — copy them if present.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/gemini-cli $out/bin

    # Copy the bundle, dereferencing symlinks (they point to /build/ which
    # won't exist after the build).
    cp -rL bundle $out/lib/gemini-cli/

    # Copy native addons that esbuild marks as external
    for mod in keytar node-pty; do
      if [ -d "node_modules/$mod" ]; then
        mkdir -p "$out/lib/gemini-cli/node_modules/$mod"
        cp -r "node_modules/$mod/." "$out/lib/gemini-cli/node_modules/$mod/"
      fi
    done

    cat > $out/bin/gemini << EOF
#!/usr/bin/env bash
export NODE_PATH="$out/lib/gemini-cli/node_modules"
exec ${nodejs_22}/bin/node $out/lib/gemini-cli/bundle/gemini.js "\$@"
EOF
    chmod +x $out/bin/gemini

    runHook postInstall
  '';

  meta = with lib; {
    description = "Gemini CLI - Google's AI coding assistant in your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = licenses.asl20;
    platforms = platforms.all;
    mainProgram = "gemini";
  };
}
