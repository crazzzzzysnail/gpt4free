#!/bin/bash
set -e

# 如果设置了 G4F_STORAGE_PATH，则修复其权限
if [ -n "$G4F_STORAGE_PATH" ] && [ -d "$G4F_STORAGE_PATH" ]; then
  echo "G4F_STORAGE_PATH is set to $G4F_STORAGE_PATH. Checking permissions..."
  # 动态地从环境变量 $SEL_UID 和 $SEL_GID 获取用户和组ID
  # 如果变量未设置，则回退到 1000:1000
  TARGET_UID=${SEL_UID:-1000}
  TARGET_GID=${SEL_GID:-1000}
  
  echo "Updating ownership to UID: $TARGET_UID, GID: $TARGET_GID..."
  chown -R "$TARGET_UID:$TARGET_GID" "$G4F_STORAGE_PATH"
  echo "Permissions for $G4F_STORAGE_PATH have been updated."
fi

# 以动态获取的用户/组ID执行传递给此脚本的任何命令
# gosu 是一个轻量级的 sudo/su 替代品，通常在容器中用于降权
# exec "$@" 会将脚本的 PID 替换为所执行命令的 PID，这是容器 entrypoint 的最佳实践
exec gosu "$TARGET_UID:$TARGET_GID" "$@"