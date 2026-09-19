"""Where the published binaries are, and what they hash to.

One entry per Verilator version this module has released. The URL is a
release asset of this repository; the checksum is what the release
workflow measured. `bazel run //package:record -- <version>` writes an
entry here after a release, so the numbers come from the artifact
rather than from anybody's memory.
"""

# The version served when a consumer names none.
DEFAULT_VERILATOR_VERSION = "5.046"

VERILATOR_BINARIES = {
    "5.046": {
        "linux_x86_64": struct(
            url = "https://github.com/filmil/bazel_toolchains_verilator/releases/download/verilator-5.046/verilator-5.046-linux-amd64.tar.gz",
            sha256 = "2234af808104af6f1c43d774966815d43bf131f946fd868d0e01045e9b626ca8",
        ),
    },
}
