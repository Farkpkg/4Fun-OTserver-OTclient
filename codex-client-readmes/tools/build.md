# Build Configuration and Setup

## Scope

This guide complements `tools/AGENTS.md` with practical build setup and troubleshooting notes.

## CMake + VCPKG

- Set `VCPKG_ROOT` or pass `-DCMAKE_TOOLCHAIN_FILE=.../vcpkg.cmake`.
- `VCPKG_DEFAULT_TRIPLET` defines target (e.g., x64-windows).
- `VCPKG_BUILD_TYPE=release` is enforced for deps.

## Common commands

Linux/macOS:
```
cmake -B build -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
cmake --build build --config Release
```

Windows:
```
cmake -B build -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake
cmake --build build --config Release
```

WASM:
```
emcmake cmake -B build -DWASM=ON \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
emmake cmake --build build
```

Android:
```
cmake -B build -DVCPKG_TARGET_ANDROID=ON \
  -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21 \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
cmake --build build
```

## Build options

- `OPTIONS_ENABLE_CCACHE=ON`
- `OPTIONS_ENABLE_SCCACHE=ON`
- `OPTIONS_ENABLE_IPO=OFF` (faster dev builds)
- `OTCLIENT_BUILD_TESTS=OFF`

## Runtime note

- The executable must run in a workdir that contains `init.lua`.

## Troubleshooting

- VCPKG not found: set `VCPKG_ROOT` or pass toolchain file.
- Missing deps: `vcpkg list` and install required packages.
- IPO not supported: disable `OPTIONS_ENABLE_IPO`.
