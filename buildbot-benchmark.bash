#!/bin/bash
set -e

# Basic definitions.
BENCHVER=20240318
LLVMVER=18.1.1
LLVMURL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVMVER/llvm-project-$LLVMVER.src.tar.xz"
LLVMDIR="$(basename $LLVMURL | rev | cut -f3- -d'.' | rev)"
DEPENDENCIES="devel-base"
BUILDLOGFILE="$(pwd)/benchmark.log"

# LLVM configuration options.
CONFIG_OPTS=(
    '-DCMAKE_BUILD_TYPE:STRING=Release'
    '-DBENCHMARK_BUILD_32_BITS:BOOL=OFF'
    '-DBENCHMARK_DOWNLOAD_DEPENDENCIES:BOOL=OFF'
    '-DBENCHMARK_ENABLE_ASSEMBLY_TESTS:BOOL=OFF'
    '-DBENCHMARK_ENABLE_DOXYGEN:BOOL=OFF'
    '-DBENCHMARK_ENABLE_EXCEPTIONS:BOOL=OFF'
    '-DBENCHMARK_ENABLE_GTEST_TESTS:BOOL=OFF'
    '-DBENCHMARK_ENABLE_INSTALL:BOOL=OFF'
    '-DBENCHMARK_ENABLE_LIBPFM:BOOL=OFF'
    '-DBENCHMARK_ENABLE_LTO:BOOL=OFF'
    '-DBENCHMARK_ENABLE_TESTING:BOOL=OFF'
    '-DBENCHMARK_ENABLE_WERROR:BOOL=OFF'
    '-DBENCHMARK_FORCE_WERROR:BOOL=OFF'
    '-DBENCHMARK_INSTALL_DOCS:BOOL=OFF'
    '-DBENCHMARK_USE_BUNDLED_GTEST:BOOL=OFF'
    '-DBENCHMARK_USE_LIBCXX:BOOL=OFF'
    '-DBUILD_SHARED_LIBS:BOOL=OFF'
    '-DHAVE_STD_REGEX:BOOL=ON'
    '-DLLVM_ADDITIONAL_BUILD_TYPES:BOOL=OFF'
    '-DLLVM_ALLOW_PROBLEMATIC_CONFIGURATIONS:BOOL=OFF'
    '-DLLVM_APPEND_VC_REV:BOOL=OFF'
    '-DLLVM_BUILD_32_BITS:BOOL=OFF'
    '-DLLVM_BUILD_BENCHMARKS:BOOL=OFF'
    '-DLLVM_BUILD_DOCS:BOOL=OFF'
    '-DLLVM_BUILD_EXAMPLES:BOOL=OFF'
    '-DLLVM_BUILD_EXTERNAL_COMPILER_RT:BOOL=OFF'
    '-DLLVM_BUILD_LLVM_C_DYLIB:BOOL=OFF'
    '-DLLVM_BUILD_LLVM_DYLIB:BOOL=OFF'
    '-DLLVM_BUILD_RUNTIME:BOOL=ON'
    '-DLLVM_BUILD_RUNTIMES:BOOL=ON'
    '-DLLVM_BUILD_TESTS:BOOL=OFF'
    '-DLLVM_BUILD_TOOLS:BOOL=OFF'
    '-DLLVM_BUILD_UTILS:BOOL=OFF'
    '-DLLVM_BYE_LINK_INTO_TOOLS:BOOL=OFF'
    '-DLLVM_CCACHE_BUILD:BOOL=OFF'
    '-DLLVM_DEPENDENCY_DEBUGGING:BOOL=OFF'
    '-DLLVM_ENABLE_ASSERTIONS:BOOL=OFF'
    '-DLLVM_ENABLE_BACKTRACES:BOOL=OFF'
    '-DLLVM_ENABLE_BINDINGS:BOOL=OFF'
    '-DLLVM_ENABLE_CRASH_DUMPS:BOOL=OFF'
    '-DLLVM_ENABLE_CRASH_OVERRIDES:BOOL=OFF'
    '-DLLVM_ENABLE_DAGISEL_COV:BOOL=OFF'
    '-DLLVM_ENABLE_DOXYGEN:BOOL=OFF'
    '-DLLVM_ENABLE_DUMP:BOOL=OFF'
    '-DLLVM_ENABLE_EH:BOOL=OFF'
    '-DLLVM_ENABLE_EXPENSIVE_CHECKS:BOOL=OFF'
    '-DLLVM_ENABLE_FFI:BOOL=OFF'
    '-DLLVM_ENABLE_GISEL_COV:BOOL=OFF'
    '-DLLVM_ENABLE_IDE:BOOL=OFF'
    '-DLLVM_ENABLE_LIBCXX:BOOL=OFF'
    '-DLLVM_ENABLE_LIBEDIT:BOOL=OFF'
    '-DLLVM_ENABLE_LIBPFM:BOOL=OFF'
    '-DLLVM_ENABLE_LLD:BOOL=OFF'
    '-DLLVM_ENABLE_LLVM_LIBC:BOOL=OFF'
    '-DLLVM_ENABLE_LOCAL_SUBMODULE_VISIBILITY:BOOL=ON'
    '-DLLVM_ENABLE_MODULES:BOOL=OFF'
    '-DLLVM_ENABLE_MODULE_DEBUGGING:BOOL=OFF'
    '-DLLVM_ENABLE_NEW_PASS_MANAGER:BOOL=TRUE'
    '-DLLVM_ENABLE_OCAMLDOC:BOOL=OFF'
    '-DLLVM_ENABLE_PEDANTIC:BOOL=OFF'
    '-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR:BOOL=ON'
    '-DLLVM_ENABLE_PIC:BOOL=ON'
    '-DLLVM_ENABLE_PLUGINS:BOOL=OFF'
    '-DLLVM_ENABLE_RTTI:BOOL=OFF'
    '-DLLVM_ENABLE_SPHINX:BOOL=OFF'
    '-DLLVM_ENABLE_STRICT_FIXED_SIZE_VECTORS:BOOL=OFF'
    '-DLLVM_ENABLE_TERMINFO:BOOL=OFF'
    '-DLLVM_ENABLE_THREADS:BOOL=ON'
    '-DLLVM_ENABLE_UNWIND_TABLES:BOOL=OFF'
    '-DLLVM_ENABLE_WARNINGS:BOOL=ON'
    '-DLLVM_ENABLE_WERROR:BOOL=OFF'
    '-DLLVM_ENABLE_Z3_SOLVER:BOOL=OFF'
    '-DLLVM_EXPERIMENTAL_DEBUGINFO_ITERATORS:BOOL=OFF'
    '-DLLVM_EXPORT_SYMBOLS_FOR_PLUGINS:BOOL=OFF'
    '-DLLVM_EXTERNALIZE_DEBUGINFO:BOOL=OFF'
    '-DLLVM_FORCE_ENABLE_STATS:BOOL=OFF'
    '-DLLVM_FORCE_USE_OLD_TOOLCHAIN:BOOL=OFF'
    '-DLLVM_HAVE_TFLITE:BOOL='
    '-DLLVM_INCLUDE_BENCHMARKS:BOOL=OFF'
    '-DLLVM_INCLUDE_DOCS:BOOL=OFF'
    '-DLLVM_INCLUDE_EXAMPLES:BOOL=OFF'
    '-DLLVM_INCLUDE_GO_TESTS:BOOL=OFF'
    '-DLLVM_INCLUDE_RUNTIMES:BOOL=ON'
    '-DLLVM_INCLUDE_TESTS:BOOL=OFF'
    '-DLLVM_INCLUDE_TOOLS:BOOL=OFF'
    '-DLLVM_INCLUDE_UTILS:BOOL=OFF'
    '-DLLVM_INDIVIDUAL_TEST_COVERAGE:BOOL=OFF'
    '-DLLVM_INSTALL_BINUTILS_SYMLINKS:BOOL=OFF'
    '-DLLVM_INSTALL_CCTOOLS_SYMLINKS:BOOL=OFF'
    '-DLLVM_INSTALL_GTEST:BOOL=OFF'
    '-DLLVM_INSTALL_MODULEMAPS:BOOL=OFF'
    '-DLLVM_INSTALL_TOOLCHAIN_ONLY:BOOL=OFF'
    '-DLLVM_INSTALL_UTILS:BOOL=OFF'
    '-DLLVM_LINK_LLVM_DYLIB:BOOL=OFF'
    '-DLLVM_OMIT_DAGISEL_COMMENTS:BOOL=OFF'
    '-DLLVM_OPTIMIZED_TABLEGEN:BOOL=OFF'
    '-DLLVM_OPTIMIZE_SANITIZED_BUILDS:BOOL=ON'
    '-DLLVM_STATIC_LINK_CXX_STDLIB:BOOL=OFF'
    '-DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN:BOOL=OFF'
    '-DLLVM_TOOL_BOLT_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_CLANG_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_COMPILER_RT_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_CROSS_PROJECT_TESTS_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_DRAGONEGG_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_FLANG_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_LIBCXXABI_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_LIBCXX_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_LIBC_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_LIBUNWIND_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_LLDB_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_LLD_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_LLVM_DRIVER_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_MLIR_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_OPENMP_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_POLLY_BUILD:BOOL=OFF'
    '-DLLVM_TOOL_PSTL_BUILD:BOOL=OFF'
    '-DLLVM_UNREACHABLE_OPTIMIZE:BOOL=ON'
    '-DLLVM_USE_FOLDERS:BOOL=ON'
    '-DLLVM_USE_INTEL_JITEVENTS:BOOL=OFF'
    '-DLLVM_USE_OPROFILE:BOOL=OFF'
    '-DLLVM_USE_PERF:BOOL=OFF'
    '-DLLVM_USE_RELATIVE_PATHS_IN_DEBUG_INFO:BOOL=OFF'
    '-DLLVM_USE_RELATIVE_PATHS_IN_FILES:BOOL=OFF'
    '-DLLVM_USE_SPLIT_DWARF:BOOL=OFF'
    '-DLLVM_USE_STATIC_ZSTD:BOOL=FALSE'
    '-DLLVM_USE_SYMLINKS:BOOL=ON'
    '-DLLVM_VERSION_PRINTER_SHOW_HOST_TARGET_INFO:BOOL=ON'
    '-DLLVM_WINDOWS_PREFER_FORWARD_SLASH:BOOL=OFF'
    '-DPY_PYGMENTS_FOUND:BOOL=OFF'
    '-DPY_PYGMENTS_LEXERS_C_CPP_FOUND:BOOL=OFF'
    '-DPY_YAML_FOUND:BOOL=OFF'
    '-DLLVM_ENABLE_LTO:BOOL=ON'
)

# Autobuild output formatter functions.
abwarn() { echo -e "[\e[33mWARN\e[0m]: \e[1m$*\e[0m"; }
aberr()  { echo -e "[\e[31mERROR\e[0m]: \e[1m$*\e[0m"; exit 1; }
abinfo() { echo -e "[\e[96mINFO\e[0m]: \e[1m$*\e[0m"; }

# Autobuild dpkg handler functions.
pm_exists(){
    for p in "$@"; do
        dpkg $PM_ROOTPARAM -l "$p" | grep ^ii >/dev/null 2>&1 || return 1
    done
}
pm_repoupdate(){
    apt-get update
}
pm_repoinstall(){
    apt-get install "$@" --yes
}

# System detection logic.
sys_detect() {
    . /etc/os-release
    export $ID
}

echo -e "
******************************************************************************
----------------    BUILDBOT BENCHMARK (version $BENCHVER)    -----------------
******************************************************************************

Benchmark: Building LLVM runtime (version $LLVMVER), using Ninja, LTO enabled.

System architecture: $(uname -m)
System processors: $(nproc)
System memory: $(( $(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }') / 1024 / 1024 )) GiB
"

abinfo "(1/6) Preparing to benchmark Buildbot: Fetching dependencies ..."
sys_detect
if [[ "$ID" = "aosc" ]]; then
    if ! pm_exists $DEPENDENCIES; then
        abinfo "Build or runtime dependencies not satisfied, now fetching needed packages."
        pm_repoupdate || \
            aberr "Failed to refresh repository: $?"
        pm_repoinstall $DEPENDENCIES || \
            aberr "Failed to install needed dependencies: $?"
    fi
else
    abwarn "Non-AOSC OS host detected, you are on your own!

    Usually, you would want to install a meta package for basic development
    tools, such as ninja, and build-essential for Debian/Ubuntu, or base-devel for
    Arch Linux.\n"
fi

abinfo "(2/6) Preparing to benchmark Buildbot: Downloading LLVM (version $LLVMVER) ..."
wget -c $LLVMURL 2> $BUILDLOGFILE || \
    aberr "Failed to download LLVM: $?."

abinfo "(3/6) Preparing to benchmark Buildbot: Unpacking LLVM (version $LLVMVER) ..."
rm -rf "$LLVMDIR"
tar xf $(basename $LLVMURL) || \
    aberr "Failed to unpack LLVM: $?."

abinfo "(4/6) Preparing to benchmark Buildbot: Setting up build environment ..."
mkdir -p "$LLVMDIR"/llvm/build || \
    aberr "Failed to create build directory: $?."
cd "$LLVMDIR"/llvm/build || \
    aberr "Failed to swtich to build directory: $?."
# Set LANG to C to make gcc faster (a little bit)
export LC_ALL=C
export LANG=C

abinfo "(5/6) Preparing to benchmark Buildbot: Configuring LLVM (version $LLVMVER) ..."
cmake .. \
    "${CONFIG_OPTS[@]}" \
    -GNinja >> $BUILDLOGFILE 2>&1 || \
        aberr "Failed to configure LLVM: $?."

abinfo "(6/6) Benchmarking Buildbot: Building LLVM ..."
time ninja 2>> $BUILDLOGFILE || \
    aberr "Failed to build LLVM: $?."

unset LC_ALL LANG
