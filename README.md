# gemini-cli-nix

> # ⚠️ Deprecated — no longer maintained
>
> Google has shifted its terminal AI tooling from Gemini CLI to **Antigravity**, so this package is no longer maintained and will receive no further updates.
>
> **Successor → [antigravity-cli-nix](https://github.com/selfhost-it/antigravity-cli-nix)** — the Nix package for Google's Antigravity CLI (`agy`).
>
> The flake here still builds the last packaged Gemini CLI version, but it will drift from (and eventually break against) upstream. Pin a specific commit if you need to keep using it.

Nix package for [Gemini CLI](https://github.com/google-gemini/gemini-cli) — Google's AI coding assistant in your terminal.

## Why this package?

The Gemini CLI in nixpkgs may lag behind upstream releases. This flake lets you:

1. **Always have the latest version** — update as soon as a new release drops
2. **Declarative installation** — managed in your NixOS or Home Manager config
3. **Reproducible builds** — built from source via `buildNpmPackage` + esbuild

## Project Structure

| File | Purpose |
|---|---|
| `flake.nix` | Flake definition: inputs (nixpkgs, flake-utils), overlay, packages, app |
| `package.nix` | Build recipe: fetches the GitHub monorepo, runs esbuild bundle, installs native addons |
| `flake.lock` | Pinned inputs |
| `.gitignore` | Excludes Nix build artifacts and editor files |

## Quick Start

```bash
# Run directly without installing
nix run github:selfhost-it/gemini-cli-nix

# Install to your profile
nix profile install github:selfhost-it/gemini-cli-nix
```

## NixOS / Home Manager Integration

### Add to your flake inputs

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    gemini-cli = {
      url = "github:selfhost-it/gemini-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### Apply the overlay

```nix
{
  nixpkgs.overlays = [
    gemini-cli.overlays.default
  ];
}
```

### Add to your packages

NixOS (`configuration.nix`):

```nix
environment.systemPackages = with pkgs; [
  gemini-cli
];
```

Home Manager (`home.nix`):

```nix
home.packages = with pkgs; [
  gemini-cli
];
```

## Building Locally

```bash
git clone git@github.com:selfhost-it/gemini-cli-nix.git
cd gemini-cli-nix
nix build .

# Test
./result/bin/gemini --version

# Or run directly
nix run .
```

## Updating to a new Gemini CLI version

1. Change `version` in `package.nix` (e.g. `"0.32.0"`)

2. Update the source hash:
   ```bash
   nix-prefetch-github google-gemini gemini-cli --rev v0.32.0
   ```
   Copy the `hash` value into `package.nix`.

3. Set `npmDepsHash = "";` in `package.nix` and run:
   ```bash
   nix build .
   ```
   The build will fail and print the correct hash. Paste it back.

4. Run `nix build .` again — it should succeed.

5. Commit and push.

## Technical Details

- **Source**: Built from the [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) GitHub monorepo
- **Builder**: `buildNpmPackage` with npm workspaces + esbuild bundle
- **Runtime**: Node.js 22
- **Native deps**: `pkg-config`, `libsecret` (for keytar), `python3` (for node-gyp)
- **Binary**: `gemini` (at `$out/bin/gemini`)
- The monorepo uses npm workspaces; `buildNpmPackage` runs `npm ci` which handles them automatically
- esbuild produces a self-contained `bundle/gemini.js`; native modules (keytar, node-pty) are marked as external and copied separately
- Symlinks in the bundle point to the build directory, so `cp -rL` (dereference) is used during install

## Troubleshooting

On first run you may need to create the Gemini config directory:

```bash
mkdir -p ~/.gemini
```

## License

Gemini CLI is licensed under [Apache 2.0](https://github.com/google-gemini/gemini-cli/blob/main/LICENSE) by Google.

---

Maintained by [self-host.it](https://self-host.it)
