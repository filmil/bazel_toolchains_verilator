# bazel_toolchains_verilator

[![release](https://github.com/filmil/bazel_toolchains_verilator/actions/workflows/release.yml/badge.svg)](https://github.com/filmil/bazel_toolchains_verilator/actions/workflows/release.yml)
[![registry](https://github.com/filmil/bazel_toolchains_verilator/actions/workflows/publish.yml/badge.svg)](https://github.com/filmil/bazel_toolchains_verilator/actions/workflows/publish.yml)
[![latest](https://img.shields.io/github/v/release/filmil/bazel_toolchains_verilator?sort=semver&display_name=tag&label=latest)](https://github.com/filmil/bazel_toolchains_verilator/releases/latest)

A Verilator toolchain from a prebuilt binary, so that a build which
needs Verilator downloads one instead of compiling one.

The first badge is the build that produces the binary, and it is the
one to look at: if it is red, the binary this module serves is the one
from the release before. The second is the publication of the module
to the registry, which is a separate thing from the binary and fails
separately.

## Why

Verilator is a large C++ program. Building it from the registry module
on a machine that has not built it before takes about six minutes; on
this project's machine, measured, 370 seconds and 3,956 actions. The
binary is the same on every machine, so it is worth building once.

    build from source, cold          370 s
    download this binary               1.6 s

## Using it

```python
bazel_dep(name = "bazel_toolchains_verilator", version = "0.1.0")

verilator_binary = use_extension(
    "@bazel_toolchains_verilator//verilator:extension.bzl",
    "verilator_binary",
)
use_repo(verilator_binary, "verilator_prebuilt")

register_toolchains("@verilator_prebuilt//:toolchain")
```

Then drop the toolchain that builds from source:

```python
# register_toolchains("@rules_verilator//verilator:verilator_toolchain")
```

The rules are still `rules_verilator`'s; only where the binary comes
from changes. Nothing else in a build has to know.

The module registers no toolchain of its own, deliberately. Doing so
would make every build fetch the binary during toolchain resolution,
including this repository's own release build, which cannot fetch a
binary it has not made yet.

## What is in the release

One tarball per Verilator version and platform:

    bin/verilator        the driver, as `@verilator//:verilator` builds it
    include/             the tree Verilator's output includes, 53 files

Verilator looks for its include tree beside its binary, so the layout
in the tarball is the layout it is unpacked into, and the tree travels
with the binary as runfiles.

## How a release is made

The source is the Verilator module in the Bazel Central Registry, not a
checkout of Verilator's git. So what is published is what
`@verilator//:verilator` would have been on the machine that consumed
it, built by the same rules, rather than by a second recipe that could
drift from them.

    git tag verilator-5.046 && git push --tags

builds it and attaches the tarball to a release. The release notes
carry the checksum; put it in `verilator/versions.bzl` beside the URL,
so the number comes from the artifact rather than from a local build.

A module tag, `v0.1.0`, publishes the module itself to
[filmil/bazel-registry](https://github.com/filmil/bazel-registry). The
two kinds of tag are separate because they version separately: a new
Verilator does not need a new module, and a fix to the module does not
need a new Verilator.

## What this does not do

One platform, linux/amd64. A second is another key in
`verilator/versions.bzl` and another leg of the release matrix; the
lookup is already written for it.

It publishes a binary built from somebody else's source, which is why
it goes to a personal registry rather than to the central one.

## Checking it

`//integration` is a module that depends on this one the way a
consumer would, and asks Verilator what version it is. A binary that
runs and knows its own version is one that was packaged with its
include tree and marked executable, which are the two ways this can go
wrong. The registry runs it as a presubmit.
