# SWELL Cache Auto Clear Scripts

WordPressテーマ「SWELL」のキャッシュを自動で定期削除するためのシェルスクリプト集です。

## 📝 概要

SWELLはTransients APIを使用してキャッシュをデータベースに保存しますが、標準では自動削除機能がありません。これらのスクリプトを使用することで、サーバーのCronでSWELLキャッシュを定期的に自動削除できます。

## 🚀 特徴

- ✅ SWELLキャッシュの確実な削除
- ✅ 期限切れTransientの自動削除
- ✅ 詳細なログ出力
- ✅ エラーハンドリング
- ✅ 削除前後の状況確認
- ✅ アフィリエイトサイトに最適化

## 📦 含まれるスクリプト

### 1. `swell_cache_clear.sh`
**推奨版** - SWELL特化の効率的なキャッシュクリア

- SWL系キャッシュ（`_transient_swl*`）の削除
- SWLR系キャッシュ（`_transient_swlr*`）の削除
- 期限切れTransientの削除
- オブジェクトキャッシュのフラッシュ

### 2. `direct_swell_cache_clear.sh`
**包括版** - より詳細な操作とログ出力

- 段階的なキャッシュクリア処理
- 各処理の成功/失敗ログ
- プラグイン別キャッシュ削除
- 残存キャッシュの詳細確認

## 🛠️ 必要な環境

- **WordPress** + **SWELLテーマ**
- **WP-CLI** がインストール済み
- **SSH** アクセス権限
- **Cron** 設定権限

## 📥 インストール

### 1. ファイルのダウンロード

```bash
# binディレクトリの作成
mkdir -p ~/bin

# スクリプトのダウンロード
cd ~/bin
wget https://raw.githubusercontent.com/itsumonotakumi/swell-cache-clear/main/swell_cache_clear.sh
wget https://raw.githubusercontent.com/itsumonotakumi/swell-cache-clear/main/direct_swell_cache_clear.sh

# 実行権限の付与
chmod +x swell_cache_clear.sh
chmod +x direct_swell_cache_clear.sh
```

### 2. 設定の編集

各スクリプト内の以下のパスを実際の環境に合わせて編集してください：

```bash
# WordPressのパス（例）
cd /home/USERNAME/example.com/public_html

# ログファイルのパス（例）
LOG_FILE="/home/USERNAME/logs/swell_cache.log"
```

## 🔧 使用方法

### 手動実行

```bash
# 推奨版の実行
~/bin/swell_cache_clear.sh

# 包括版の実行
~/bin/direct_swell_cache_clear.sh
```

### Cron自動実行設定

```bash
crontab -e
```

以下の設定例を追加：

```bash
# 毎日午前3時にSWELLキャッシュクリア
0 3 * * * /home/USERNAME/bin/swell_cache_clear.sh

# WordPressのcron処理（15分毎）
*/15 * * * * cd /path/to/wordpress && wp cron event run --due-now --allow-root --quiet

# ログローテーション（週1回）
0 2 * * 0 find /home/USERNAME/logs -name "swell_cache.log" -size +10M -exec truncate -s 0 {} \;
```

## 📊 ログ確認

```bash
# リアルタイムログ監視
tail -f ~/logs/swell_cache.log

# 当日のログ確認
grep "$(date '+%Y-%m-%d')" ~/logs/swell_cache.log

# キャッシュ削除実績確認
grep "削除実績" ~/logs/swell_cache.log
```

## 🎯 アフィリエイトサイト最適化設定

トラフィックの多い時間帯に合わせた設定例：

```bash
# 平日の主要時間帯前にクリア
0 8,11,14,17,20 * * 1-5 /home/USERNAME/bin/swell_cache_clear.sh

# 週末は頻度を下げる
0 3 * * 6,0 /home/USERNAME/bin/swell_cache_clear.sh
```

## 🔍 トラブルシューティング

### よくある問題

#### 1. 権限エラー
```bash
# WP-CLIの権限確認
wp --info --allow-root

# ファイル権限確認
ls -la ~/bin/swell_cache_clear.sh
```

#### 2. パスエラー
```bash
# WordPressディレクトリの確認
ls -la /path/to/wordpress/wp-config.php

# WP-CLIのパス確認
which wp
```

#### 3. キャッシュが削除されない
```bash
# 現在のTransient確認
wp db query "SELECT option_name FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root

# 手動削除テスト
wp db query "DELETE FROM wp_options WHERE option_name LIKE '_transient_swl%'" --allow-root
```

## 📈 期待効果

- **ページ読み込み速度向上**
- **SEO評価の改善**
- **ユーザー体験の向上**
- **サーバーリソースの最適化**
- **データベースの軽量化**

## ⚠️ 注意事項

1. **バックアップ推奨**: 初回実行前にデータベースのバックアップを取得
2. **テスト環境での確認**: 本番環境適用前にテスト環境で動作確認
3. **ログ監視**: 初期運用時は定期的にログを確認
4. **WordPress更新時**: WordPress本体やSWELLテーマ更新後は動作確認

## 🤝 貢献

バグ報告や改善提案は [Issues](https://github.com/itsumonotakumi/swell-cache-clear/issues) にお願いします。

プルリクエストも歓迎です！

## 📄 ライセンス

このプロジェクトは [GPL-3.0 License](LICENSE) の下で公開されています。

### 🔍 GPL-3.0の特徴

- ✅ **自由な利用・改変・再配布**が可能
- ⚠️ **商用利用時はソースコード公開が必須**
- 🔗 **派生作品も同じライセンスで公開必須**
- 🛡️ **WordPress/SWELLエコシステムとの親和性**

### 💼 商用利用について

商用環境での利用は可能ですが、以下の条件があります：

1. **ソースコードの公開義務**：改変した場合は必ず公開
2. **同ライセンス継承**：派生作品もGPL-3.0で公開
3. **著作権表示**：オリジナル作者のクレジット表示

これらの条件により、**オープンソースの精神を維持**しつつ商用利用を制限しています。