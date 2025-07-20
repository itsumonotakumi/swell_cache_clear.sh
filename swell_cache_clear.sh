#!/bin/bash

# ログファイル設定
LOG_FILE="/home/USERNAME/logs/swell_cache.log"
mkdir -p "$(dirname "$LOG_FILE")"

# ログ関数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

cd /home/USERNAME/WP-SITENAME/public_html/cheapest

log_message "=== SWELLキャッシュクリア開始 ==="

# 実行前の状況確認
TOTAL_BEFORE=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_%'" --allow-root --skip-column-names 2>/dev/null | head -1)
SWL_BEFORE=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root --skip-column-names 2>/dev/null | head -1)

log_message "実行前 - 総Transient数: $TOTAL_BEFORE, SWELL(swl)キャッシュ数: $SWL_BEFORE"

# SWELL特化キャッシュクリア
log_message "SWELLキャッシュクリア実行中..."

# 1. SWL系キャッシュクリア（SWELLの実際のプレフィックス）
wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root 2>/dev/null
wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_timeout_swl%'" --allow-root 2>/dev/null

# 2. SWLR系キャッシュクリア
wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_swlr%'" --allow-root 2>/dev/null
wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_timeout_swlr%'" --allow-root 2>/dev/null

# 3. 期限切れTransientも削除
wp db query "DELETE a, b FROM wp_options a, wp_options b WHERE a.option_name LIKE '_transient_%' AND a.option_name NOT LIKE '_transient_timeout_%' AND b.option_name = CONCAT('_transient_timeout_', SUBSTRING(a.option_name, 12)) AND b.option_value < UNIX_TIMESTAMP()" --allow-root 2>/dev/null

# 4. オブジェクトキャッシュフラッシュ
wp cache flush --allow-root --quiet 2>/dev/null

# 実行後の状況確認
TOTAL_AFTER=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_%'" --allow-root --skip-column-names 2>/dev/null | head -1)
SWL_AFTER=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root --skip-column-names 2>/dev/null | head -1)

# 削除数計算
TOTAL_DELETED=$((TOTAL_BEFORE - TOTAL_AFTER))
SWL_DELETED=$((SWL_BEFORE - SWL_AFTER))

log_message "実行後 - 総Transient数: $TOTAL_AFTER, SWELL(swl)キャッシュ数: $SWL_AFTER"
log_message "削除実績 - 総削除数: $TOTAL_DELETED, SWELL削除数: $SWL_DELETED"

# 現在残っているキャッシュの詳細ログ
REMAINING_CACHES=$(wp db query "SELECT option_name FROM wp_options WHERE option_name LIKE '_transient_%' AND option_name NOT LIKE '_transient_timeout_%'" --allow-root --skip-column-names 2>/dev/null | tr '\n' ', ')
log_message "残存キャッシュ: $REMAINING_CACHES"

log_message "=== SWELLキャッシュクリア完了 ==="
