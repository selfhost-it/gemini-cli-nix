#!/usr/bin/env python3
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from update_common import (  # noqa: E402
    Profile as BaseProfile,
    Target,
    Version,
    learn_hashes,
    main,
    package_version,
    select_release,
    set_named_hash,
    set_package_version,
    set_source_hash,
    source_hash,
)


class Profile(BaseProfile):
    name = "Gemini CLI"
    files = ("package.nix",)
    binary = "gemini"
    repository = "google-gemini/gemini-cli"

    def current_version(self, root: Path) -> Version:
        return package_version(root)

    def discover(self, ctx, requested: Version | None) -> Target:
        return Target(select_release(ctx, self.repository, requested))

    def prepare(self, ctx, target: Target) -> None:
        set_package_version(ctx, target.version)
        set_source_hash(ctx, source_hash(ctx, self.repository, target.version))
        learn_hashes(
            ctx,
            {
                "npmDepsHash": (
                    f"gemini-cli-{target.version}-npm-deps",
                    lambda value: set_named_hash(ctx, "npmDepsHash", value),
                )
            },
        )

    def commit_subject(self, target: Target) -> str:
        return f"Update Gemini CLI to v{target.version}"


if __name__ == "__main__":
    raise SystemExit(main(Profile()))
