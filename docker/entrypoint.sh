#!/bin/bash
set -e

# 1. 从环境变量定义目标用户和组，如果未设置则提供默认值
TARGET_UID=${SEL_UID:-1000}
TARGET_GID=${SEL_GID:-1000}
USERNAME=seluser

echo "Starting container with UID: $TARGET_UID, GID: $TARGET_GID"

# 2. 动态创建用户和组，以解决 gosu 切换失败的问题
# 检查目标组是否存在，不存在则创建
if ! getent group "$TARGET_GID" >/dev/null 2>&1; then
    echo "Creating group '$USERNAME' with GID $TARGET_GID..."
    groupadd -g "$TARGET_GID" "$USERNAME"
fi

# 检查目标用户是否存在，不存在则创建
if ! getent passwd "$TARGET_UID" >/dev/null 2>&1; then
    echo "Creating user '$USERNAME' with UID $TARGET_UID and GID $TARGET_GID..."
    useradd --shell /bin/bash -u "$TARGET_UID" -g "$TARGET_GID" -o -c "" -m "$USERNAME"
fi

# 3. 使用 gosu 以目标用户身份执行一个内联脚本块
exec gosu "$TARGET_UID:$TARGET_GID" bash -c '
  # 如果设置了 G4F_STORAGE_PATH，则确保必要的子目录存在
  if [ -n "$G4F_STORAGE_PATH" ] && [ -d "$G4F_STORAGE_PATH" ]; then
    echo "Ensuring data directories exist..."
    mkdir -p "$G4F_STORAGE_PATH/har_and_cookies"
    mkdir -p "$G4F_STORAGE_PATH/generated_images"
    mkdir -p "$G4F_STORAGE_PATH/generated_media"
    echo "Data directories are ready."
  fi
  
  echo "Starting application..."
  # 执行传递给 entrypoint 的原始命令 (即 Docker CMD)
  exec "$@"
' bash "$@"