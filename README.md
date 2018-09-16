# 勤怠管理アプリケーション

インターンA あ

社員の勤怠管理ができるアプリケーションです。　　

## 使い方

このアプリケーションを動かす場合は、まずはリポジトリを手元にクローンしてください。  
その後、次のコマンドで必要になる RubyGems をインストールします。

```
$ bundle install --without production
```

その後、データベースへのマイグレーションを実行します。

```
$ rails db:migrate
```

サンプルユーザーを作成します。

```
$ rails db:seed
```

Railsサーバーを立ち上げる準備が整っているはずです。

```
$ rails server
```
# Attendance-system-A
