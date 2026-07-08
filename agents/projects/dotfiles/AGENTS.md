# AGENTS.md

このファイルは dotfiles リポジトリ固有の AI agent 向け運用メモです。
共通ルールは `agents/base.md` に集約します。

## Goal
- dotfiles, shell helper, editor, tmux, terminal settings を壊さずに更新する。
- 変更は最小限にし、既存の配置と生成フローを優先する。
- AGENTS 関連の実体と参照を中央管理する。

## Context
- このリポジトリはローカル環境の設定と補助スクリプトをまとめて管理する。
- 参照先は `agents/` 配下に集約し、各プロジェクトの `AGENTS.md` から参照する。
- 既存の `templates/` は雛形用途として残す。

## Commands
- `rtk git status`: 変更確認。
- `rtk rg AGENTS`: AGENTS 関連の参照確認。
- `rtk zsh -n zsh/func.zsh`: shell function の構文確認。

## Conventions
- 既存の dotfiles の書き方に合わせる。
- 生成物より中央の実体を優先する。
- 参照パスの変更は一緒に更新する。

## Risks
- 絶対パス参照なので、dotfiles の配置先を変えると再生成が必要。
- `agents/` と `templates/` の役割を取り違えると古い経路が残る。
