# Codex

このファイルは Codex 用の補足メモです。
共通ルールは `agents/base.md`、プロジェクト固有ルールは `agents/projects/<project>/AGENTS.md` を使います。
`codex/AGENTS.md` は Codex の実行環境や状態を含む入口です。

## Notes
- Codex で `rtk` を優先する前提や、コマンド実行の補足だけを書く。
- `codex/` 配下の sqlite, log, session, cache は runtime state として扱う。
- `codex/AGENTS.md` にはこの repo で Codex を使うときの薄い入口だけを置く。
- ここには Claude Code や他 LLM にも共通な内容を書かない。
