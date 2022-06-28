# CompareToLastRun.cmake #

This project contains a CMake function for detecting cache variable changes
compared to the previous CMake run.

## Usage ##

In your cmake project, do the following:

```cmake
include(FetchContent)

FetchContent_Declare(
    CompareToLastRun
    GIT_REPOSITORY "https://github.com/lepus2589/CompareToLastRun.git"
    GIT_TAG v1.1
)
FetchContent_MakeAvailable(CompareToLastRun)
FetchContent_GetProperties(
  CompareToLastRun
  SOURCE_DIR CompareToLastRun_SOURCE_DIR
  POPULATED CompareToLastRun_POPULATED
)

include("${CompareToLastRun_SOURCE_DIR}/src/cmake/CompareToLastRun.cmake")

compare_to_last_run(BUILD_SHARED_LIBS_CHANGED BUILD_SHARED_LIBS)

if (BUILD_SHARED_LIBS_CHANGED)
    # rediscover libraries
endif ()
```

You can do this for any cache variable. Each variable you call this function
for will be tracked individually. Multiple calls to the function for the same
variable (e. g. in different places of your CMake script) return the same value.

## Use cases ##

When running CMake on my library projects and generating the build directory, I
like to reuse the same build directory for shared and static builds, one after
the other. This causes problems with the cached discovered libraries my project
depends on. As the cache entries for the library paths already exist, they won't
be rediscovered by the various CMake find modules and I end up with broken
builds (e. g. shared libraries linked into a static build).

Of course, I could always use different build directories for the static and
shared variants, or manually delete the cache. But I believe, CMake should
correctly react to any configuration change and generate a valid build on
subsequent runs in the same build directory. As libraries are not automatically
rediscovered, when the relevant variable changes and also do not provide a force
rediscovery switch, this requires being able to detect a change in the relevant
variable compared to the previous run and clean up the cache as needed, so that
the libraries are rediscovered cleanly. This basically tricks the find modules
into rerunning.

This is the main use case for me, I'm sure there are others.
