#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")
# Add C++20 standard flag
if env['CC'].startswith('cl'):
    # Microsoft compiler
    env.Append(CXXFLAGS=['/std:c++20'])
else:
    # Other compilers (like GCC and Clang)
    env.Append(CXXFLAGS=['-std=c++20'])

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["src/"])

sources = [
    Glob("src/RefCounted/Netcode/*.cpp") + Glob("src/RefCounted/Netcode/Compression/*.cpp"),
    Glob("src/Refcounted/Math/*.cpp"),
    Glob("src/Singletons/*.cpp")
    ]
linker = ["src/api/extension_interface.cpp"]
source_lib_names = ["libnetcode", "libmath", "libsingletons"]
target_dir = ["RollbackAuthClient", "RollbackAuthServer"]

libraries = []

all_sources = []
for paths in sources:
    all_sources += paths
all_sources += linker

master_lib_name = "libRollbackAuth"

def build_library(sources, lib_name, target_dir, libraries=[]):
    for dir in target_dir:
        if env["platform"] == "macos":
            library = env.SharedLibrary(
                "{}}/bin/{}.{}.{}.framework/{}}.{}.{}".format(
                    dir, lib_name, env["platform"], env["target"], lib_name, env["platform"], env["target"]
                ),
                source=sources,
            )
        else:
            library = env.SharedLibrary(
                "{}/bin/{}{}{}".format(dir, lib_name, env["suffix"], env["SHLIBSUFFIX"]),
                source=sources,
            )
        libraries.append(library)
    Default(libraries)


build_library(all_sources, master_lib_name, target_dir)

# for directory in target_dir:
#     index = 0
#     print("Building for {}".format(directory))
#     for src in sources:
#         lib_name = source_lib_names[index]
#         if env["platform"] == "macos":
#             library = env.SharedLibrary(
#                 "{}}/bin/{}.{}.{}.framework/{}}.{}.{}".format(
#                     directory, lib_name, env["platform"], env["target"], lib_name, env["platform"], env["target"]
#                 ),
#                 source=src,
#             )
#         else:
#             library = env.SharedLibrary(
#                 "{}/bin/{}{}{}".format(directory, lib_name, env["suffix"], env["SHLIBSUFFIX"]),
#                 source=src,
#             )
#             print("Library should have been created: {}/bin/{}{}{}".format(directory, lib_name, env["suffix"], env["SHLIBSUFFIX"]))
#         index += 1
#         libraries.append(library)

# Default(libraries)
