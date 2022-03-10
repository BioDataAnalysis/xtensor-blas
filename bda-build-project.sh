#!/usr/bin/env bash
#
# Developed for BioDataAnalysis GmbH <info@biodataanalysis.de>
#               Balanstrasse 43, 81669 Munich
#               https://www.biodataanalysis.de/
#
# Copyright (c) BioDataAnalysis GmbH. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are not permitted. All information contained herein
# is, and remains the property of BioDataAnalysis GmbH.
# Dissemination of this information or reproduction of this material
# is strictly forbidden unless prior written permission is obtained
# from BioDataAnalysis GmbH.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#

source "${BDASOFTBUILD}/scripts/etc/bda-build-global-macros.sh" || exit 1
source "${BDASOFTBUILD}/scripts/etc/bda-build-global-variables.sh" || exit 1


# Set up the shell environment:
bda_build_environment_setup || exit 1

# Parse the default command line arguments:
bda_build_project_default_parse_arguments "$@" || exit 1

# Check if --debug or --release are given, otherwise recurse and set them:
bda_build_recursion_for_debug_release_builds "$0" "$@" || exit 1

# This requires the command line arguments:
bda_build_define_essential_variables || exit 1

# Ensure the essential build environment variables are defined:
bda_test_environment_or_exit || exit 1

PROJECT="xtensor-blas"
PROJECT_SRCDIR="${PWD}"
PROJECT_BUILDDIR="${BDABUILDDIR}/${PROJECT}"
BDA_BUILD_USE_PEDANTIC_BUILD_SETTINGS="false"
PREREQUISITE_TARGETS=(
    "${BDATOOLTARGETDIR}/install/cmake.install"
    "${BDATOOLTARGETDIR}/install/ninja.install"
    "${BDAEXTRASTARGETDIR}/install/mkl.install"
    "${BDATARGETDIR}/install/googletest.install"
    "${BDATARGETDIR}/install/benchmark.install"
    "${BDATARGETDIR}/install/xtl.install"
    "${BDATARGETDIR}/install/xsimd.install"
    "${BDATARGETDIR}/install/xtensor.install"
)
CLEAN_TARGETS=("${PROJECT_BUILDDIR}")
DISTCLEAN_TARGETS=("${PROJECT_BUILDDIR}")
PROJECT_OPTIONS=(
    "-DBUILD_SHARED_LIBS="$(test "${BDA_BUILD_TYPE}" == "Shared" && echo "ON" || echo "OFF")
    "-DBUILD_TESTS="$(test "${BDA_RELEASE_TYPE}" == "Debug" && echo "ON" || echo "OFF")
    "-DBUILD_BENCHMARK="$(test "${BDA_RELEASE_TYPE}" == "Release" && echo "ON" || echo "OFF")
    # Configure BLAS libraries for CMake:
    "-DBLA_VENDOR=${BDA_BUILD_OPTION_CMAKE_BLAS_VENDOR}"
    "-DBLA_STATIC=${BDA_BUILD_OPTION_CMAKE_BLAS_STATIC}"
    # Configure the use of OpenBLAS or "any" BLAS in tests and benchmarks:
    "-DUSE_OPENBLAS="$(test "${BDATARGETPLATFORMNAME}" == "Android" && echo "ON" || echo "OFF")
    # Configure the use of an external BLAS or the shipped FLENS BLAS in tests and benchmarks:
    "-DHAVE_CBLAS=ON"
    "-DCPP17=ON"
    "-DCXXBLAS_DEBUG=OFF"
    "-DXTENSOR_USE_FLENS_BLAS=OFF"
    "-DDOWNLOAD_GTEST=OFF"
    "-DDOWNLOAD_GBENCHMARK=OFF"
)
EXPECTED_INSTALL_FILES=("${BDATARGETDIR}/include/xtensor/xtensor.hpp")
PROJECT_SOURCE_FILES=(*)
PROJECT_RECONFIGURE_FILES=(*)
CTEST_INCLUDE_REGEX=".*";
BDA_BUILD_GITLAB_CI_YML_STAGES=("clean" "build" "test" "doc" "trigger")
BDA_BUILD_GITLAB_CI_YML_DOCKER_IMAGE="bda_cppdev"



# Call the build task:
bda_build_tasks || exit 1
