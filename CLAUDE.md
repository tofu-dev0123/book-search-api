# CLAUDE.md

## リポジトリ概要

書籍検索 API の単体サービス。書誌データを PostgreSQL に投入し、
検索の実装を既製品から自前実装へ段階的に深めていく。

**目的は検索機能を提供することではなく、各段階のレイテンシを実測して比較すること。**

## 現在の状態

- **実装コードはまだ存在しない。** ビルド・テスト・リントのコマンドも無い
- **Go が未インストール**（`go` も `gofmt` も無い）。実装着手時にインストールが必要
- PostgreSQL は psql 17.5 が利用可能。DB の実行環境（Docker 等）は未整備
- 決定済み: ADR-001（実装言語 = Go）
- 未決: ADR-002（データソース）、ADR-003（検索方式 / ADR-002 に依存）

## 技術スタック

Go / PostgreSQL。**Web フレームワークは採用しない**（`net/http` + pgx、ADR-001）。

## ディレクトリ構成

```
cmd/api/main.go        # HTTP サーバ
cmd/loader/main.go     # 書誌データ投入バッチ
internal/store/        # 接続・スキーマ・投入・読み出し + Book 型
internal/search/       # Searcher と段階ごとの実装 + ベンチマーク
testdata/              # 評価用の固定クエリセット
docs/adr/              # ADR
```

**現状は `docs/adr/` のみ存在する。** 残りは実装着手時に作る。

### 方針

- **依存の向きは `cmd → search → store` の一方通行。** 逆流させない
- **`cmd/*/main.go` にロジックを書かない。** 設定の読み込み・部品の組み立て・起動のみ
- **設定は `main` で読んで引数として渡す。** パッケージ内で環境変数を読まない
- **迷ったらディレクトリではなくファイルを増やす**
- `pkg/` は作らない。レイヤード / クリーンアーキテクチャは採用しない
- スキーマは `internal/store/schema.sql` に置き `//go:embed` で取り込む

## ADR

- `docs/adr/NNN-slug.md`。**日本語**で書く
- ヘッダに 状態 / 日付 / 関連 Issue。
  本文は Context / Decision / 選ばなかった選択肢 / Consequences
- **書式は `docs/adr/001-implementation-language.md` を参照元とする**
- 決定は Issue と 1 対 1。完了条件は「ADR が書かれてコミットされていること」

## ブランチと PR

- `develop` がベース、`main` はリリース先
- 作業ブランチは `feature/issue#<番号>`。
  **`#` を含むためコマンドではダブルクォートで囲む**
- **`develop` はまだリモートに存在しない。** 初回の push が必要

## コミット

- **日本語**で書く。`docs:` `chore:` などの prefix を付ける
- **`Co-Authored-By: Claude` を付けない。**
  PR 本文に `Generated with [Claude Code]` フッターを付けない
- 上記は `.claude/hooks/no-coauthor.sh` がブロックする（規約ではなく強制）
