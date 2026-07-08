# agents

このディレクトリは、LLM に読ませる運用知識をまとめる場所です。
`codex/` のような runtime state ではなく、共有したいルールやメモだけを置きます。
macOS / Windows / WSL / Ubuntu のどこから使っても、同じ知識ソースになるように保ちます。

## 使い方

基本は 3 層です。

1. `agents/base.md`
   - すべての LLM に共通なルール
   - 変更方針、確認のしかた、作業上の注意
2. `agents/projects/<project>/AGENTS.md`
   - その repo やプロジェクト固有のメモ
   - 目的、前提、よく使うコマンド、リスク
3. `agents/services/<tool>.md`
   - Codex / Claude Code / 将来の別 LLM だけの補足
   - 共通化しない差分だけを書く

## 入口ファイル

- `AGENTS.md`
  - Codex 向けの入口
- `CLAUDE.md`
  - Claude Code 向けの入口
- `codex/AGENTS.md`
  - Codex の動作や状態を含む補助設定の入口

## 書き方

- 共通で意味が変わらない内容は `base.md` に書く
- repo 固有の内容は `projects/<project>/AGENTS.md` に書く
- サービス固有の前提だけ `services/<tool>.md` に書く
- runtime state, cache, logs はここに置かない

## 互換ファイル

古い名前の `AGENTS_BASE.md` や `AGENTS_PROJECT.md` は、移行途中の互換入口として残している。
新しい内容は `base.md` と `projects/<project>/AGENTS.md` を優先する。
