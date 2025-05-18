#!/bin/bash

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> backup.log
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "开始清理过期备份文件"

# 获取当前日期
CURRENT_DATE=$(date +%Y%m%d)

# 计算5天前的日期（作为删除的界限）
# linux
CUTOFF_DATE=$(date -d "5 days ago" +%Y%m%d)
# MacOS
# CUTOFF_DATE=$(date -v-5d +%Y%m%d)

log "当前日期: $CURRENT_DATE, 保留界限日期: $CUTOFF_DATE"

# 遍历所有子目录（VPS名称目录）
for VPS_DIR in */; do
    # 排除非目录和特殊目录
    if [ ! -d "$VPS_DIR" ] || [[ "$VPS_DIR" == "." || "$VPS_DIR" == ".." ]]; then
        continue
    fi
    
    log "处理 $VPS_DIR 目录中的备份"
    
    # 遍历目录中的所有备份文件
    for BACKUP_FILE in "$VPS_DIR"backup_*.tar.gz; do
        if [ ! -f "$BACKUP_FILE" ]; then
            continue
        fi
        
        # 从文件名中提取日期部分 (YYYYMMDD)
        FILE_DATE=$(echo "$BACKUP_FILE" | grep -o "backup_[0-9]\{8\}" | cut -d'_' -f2)
        
        # 检查是否成功提取到日期
        if [ -z "$FILE_DATE" ]; then
            log "警告: 无法从 $BACKUP_FILE 中提取日期"
            continue
        fi
        
        # 比较日期，如果文件日期早于截止日期，则删除
        if [ "$FILE_DATE" -lt "$CUTOFF_DATE" ]; then
            log "删除过期备份文件: $BACKUP_FILE (日期: $FILE_DATE)"
            rm "$BACKUP_FILE"
        else
            log "保留备份文件: $BACKUP_FILE (日期: $FILE_DATE)"
        fi
    done
done

log "备份清理完成"
