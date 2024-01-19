## Description

This is a little utility program to check if a window visible or not using XCB lib.

## Requirements
This project needs:
`zig version >=0.12.0-dev (zig nightly)`
`libxcb`

## How to build

First, install dependencies into your system, you need `libxcb`.
```sudo apt install libxcb1-dev```

then run:
```zig build -DOptimize=ReleaseFast```

## How to run

run:
```zig build run -- the_window_class_you_need_to_check```

or run:
```./zig-out/bin/xcb_is_window_visible the_window_class_you_need_to_check```

then it will return string `true` or `false`, which you can pipe to other bash command.
for example:
``` [[ $(./zig-out/bin/xcb_is_window_visible Polybar) == "true" ]] && echo "hide" || echo "show"```

