#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["src/"])
sources = [Glob("src/RefCounted/Netcode/*.cpp"), Glob("src/Refcounted/Math/*.cpp")]
source_lib_names = ["libnetcode", "libmath"]
target_dir = ["RollbackAuthClient", "RollbackAuthServer", "D:\Godot\Projects\gdextension_cpp_example\GDExtensionCpp"]

libraries = []

for directory in target_dir:
    index = 0
    print("Building for {}".format(directory))
    for src in sources:
        lib_name = source_lib_names[index]
        if env["platform"] == "macos":
            library = env.SharedLibrary(
                "{}}/bin/{}.{}.{}.framework/{}}.{}.{}".format(
                    directory, lib_name, env["platform"], env["target"], lib_name, env["platform"], env["target"]
                ),
                source=src,
            )
        else:
            library = env.SharedLibrary(
                "{}/bin/{}{}{}".format(directory, lib_name, env["suffix"], env["SHLIBSUFFIX"]),
                source=src,
            )
            print("Library should have been created: {}/bin/{}{}{}".format(directory, lib_name, env["suffix"], env["SHLIBSUFFIX"]))
        index += 1
        libraries.append(library)

Default(libraries)
