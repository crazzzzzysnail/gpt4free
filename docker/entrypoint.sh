#!/bin/bash
set -e

# 从环境变量定义目标用户和组，如果未设置则提供默认值
TARGET_UID=${SEL_UID:-1000}
TARGET_GID=${SEL_GID:-1000}

# 使用 gosu 以目标用户身份执行一个内联脚本块
# "$@" 会将 Docker CMD 的命令作为参数传递给这个脚本块
exec gosu "$TARGET_UID:$TARGET_GID" bash -c '
  # 如果设置了 G4F_STORAGE_PATH，则确保必要的子目录存在
  # -p 标志确保父目录被创建，并且如果目录已存在也不会报错
  if [ -n "$G4F_STORAGE_PATH" ] && [ -d "$G4F_STORAGE_PATH" ]; then
    echo "Ensuring data directories exist with correct permissions..."
    mkdir -p "$G4F_STORAGE_PATH/har_and_cookies"
    mkdir -p "$G4F_STORAGE_PATH/generated_images"
    mkdir -p "$G4F_STORAGE_PATH/generated_media"
    echo "Data directories are ready."
  fi
  
  echo "Starting application as user $UID:$GID..."
  # 执行传递给 entrypoint 的原始命令 (即 Docker CMD)
  exec "$@"
' bash "$@"