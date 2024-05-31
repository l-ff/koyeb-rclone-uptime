#!/bin/sh

# 定义变量
RCLONE_CONFIG=/app/data/rclone.conf
DB_PATH=/app/data/kuma.db
BACKUP_PATH=/app/data/kuma_backup.db
REMOTE_PATH=r2:/$BUCKET/kuma/kuma_backup.db

# 检查是否存在备份
if rclone --config $RCLONE_CONFIG ls $REMOTE_PATH; then
    # 如果存在备份，则恢复
    echo "Restoring database from backup..."
    rclone --config $RCLONE_CONFIG copyto $REMOTE_PATH $DB_PATH
fi

# 等待数据还原完成
# sleep 30

# 运行 Uptime Kuma
echo "Starting Uptime Kuma..."
npm start &

# 等待 Uptime Kuma 启动
sleep 60

# 每隔15分钟备份数据库
while true; do
    echo "Attempting to backup database..."
    # 创建数据库的备份
    sqlite3 $DB_PATH ".backup \"$BACKUP_PATH\""
    # 同步备份文件到远程存储
    echo "Backing up database..."
    rclone --config $RCLONE_CONFIG copyto $BACKUP_PATH $REMOTE_PATH
    echo "backup finish"
    sleep 900
done