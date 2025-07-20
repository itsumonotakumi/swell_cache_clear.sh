#!/bin/bash

# ログファイル設定
LOG_FILE="/home/howtobuy/logs/swell_cache.log"
mkdir -p "$(dirname "$LOG_FILE")"

# ログ関数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

cd /home/howtobuy/itsutaku.com/public_html/cheapest

log_message "=== 直接DB操作によるキャッシュクリア開始 ==="

# 実行前の詳細確認
log_message "=== 実行前の状況 ==="
TOTAL_BEFORE=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_%'" --allow-root --skip-column-names 2>/dev/null | head -1)
log_message "総Transient数: $TOTAL_BEFORE"

# 各種キャッシュ数を個別確認
SWL_COUNT=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root --skip-column-names 2>/dev/null | head -1)
TIMEOUT_COUNT=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_timeout_%'" --allow-root --skip-column-names 2>/dev/null | head -1)
EXPIRED_COUNT=$(wp db query "SELECT COUNT(*) as count FROM wp_options a, wp_options b WHERE a.option_name LIKE '_transient_%' AND a.option_name NOT LIKE '_transient_timeout_%' AND b.option_name = CONCAT('_transient_timeout_', SUBSTRING(a.option_name, 12)) AND b.option_value < UNIX_TIMESTAMP()" --allow-root --skip-column-names 2>/dev/null | head -1)

log_message "SWL系キャッシュ数: $SWL_COUNT"
log_message "Timeoutキャッシュ数: $TIMEOUT_COUNT"
log_message "期限切れキャッシュ数: $EXPIRED_COUNT"

log_message "=== キャッシュクリア実行 ==="

# 1. 期限切れTransientを削除（最も安全）
log_message "1. 期限切れTransient削除実行..."
EXPIRED_DELETED=$(wp db query "DELETE a, b FROM wp_options a, wp_options b WHERE a.option_name LIKE '_transient_%' AND a.option_name NOT LIKE '_transient_timeout_%' AND b.option_name = CONCAT('_transient_timeout_', SUBSTRING(a.option_name, 12)) AND b.option_value < UNIX_TIMESTAMP()" --allow-root 2>/dev/null && echo "OK" || echo "FAILED")
log_message "期限切れTransient削除: $EXPIRED_DELETED"

# 2. SWELL特化削除
log_message "2. SWELL(swl)系キャッシュ削除実行..."
SWL_DELETED1=$(wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root 2>/dev/null && echo "OK" || echo "FAILED")
SWL_DELETED2=$(wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_timeout_swl%'" --allow-root 2>/dev/null && echo "OK" || echo "FAILED")
log_message "SWELL本体削除: $SWL_DELETED1, SWELLタイムアウト削除: $SWL_DELETED2"

# 3. 特定プラグインキャッシュ削除（Pochipp等）
log_message "3. 特定プラグインキャッシュ削除実行..."
POCHIPP_DELETED=$(wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_pochipp%'" --allow-root 2>/dev/null && echo "OK" || echo "FAILED")
REBLEX_DELETED=$(wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_reblex%'" --allow-root 2>/dev/null && echo "OK" || echo "FAILED")
log_message "Pochipp削除: $POCHIPP_DELETED, Reblex削除: $REBLEX_DELETED"

# 4. 手動で全Transient削除（最後の手段）
log_message "4. 手動全Transient削除実行..."
ALL_TRANSIENT_DELETED=$(wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_%'" --allow-root 2>/dev/null && echo "OK" || echo "FAILED")
log_message "全Transient削除: $ALL_TRANSIENT_DELETED"

# 5. オブジェクトキャッシュフラッシュ
log_message "5. オブジェクトキャッシュフラッシュ実行..."
CACHE_FLUSH=$(wp cache flush --allow-root --quiet 2>/dev/null && echo "OK" || echo "FAILED")
log_message "オブジェクトキャッシュフラッシュ: $CACHE_FLUSH"

log_message "=== 実行後の状況 ==="

# 実行後の確認
TOTAL_AFTER=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_%'" --allow-root --skip-column-names 2>/dev/null | head -1)
SWL_AFTER=$(wp db query "SELECT COUNT(*) as count FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root --skip-column-names 2>/dev/null | head -1)

# 削除数計算
TOTAL_DELETED=$((TOTAL_BEFORE - TOTAL_AFTER))
SWL_DELETED_COUNT=$((SWL_COUNT - SWL_AFTER))

log_message "総Transient数: $TOTAL_BEFORE → $TOTAL_AFTER (削除数: $TOTAL_DELETED)"
log_message "SWELL系キャッシュ: $SWL_COUNT → $SWL_AFTER (削除数: $SWL_DELETED_COUNT)"

# 残存キャッシュの詳細
if [ "$TOTAL_AFTER" -gt 0 ]; then
    log_message "=== 残存キャッシュ詳細 ==="
    REMAINING=$(wp db query "SELECT option_name FROM wp_options WHERE option_name LIKE '_transient_%' AND option_name NOT LIKE '_transient_timeout_%'" --allow-root --skip-column-names 2>/dev/null | head -10)
    log_message "残存キャッシュ（最大10件）: $REMAINING"
fi

log_message "=== 直接DB操作キャッシュクリア完了 ==="