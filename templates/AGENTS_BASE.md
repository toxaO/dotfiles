# AGENTS_BASE.md

このファイルは、各プロジェクト共通の AI agent 向け運用ルールです。
プロジェクト固有の Goal / Context / Commands / Risks は `AGENTS_PROJECT.md` に書いてください。

## Command Execution
**Shell commands must use `rtk` by default.**

- shell コマンドは原則すべて `rtk` 経由で実行する。
- 例: `rtk rg ...`, `rtk sed ...`, `rtk git status`, `rtk ls ...`
- パイプや複合コマンドが必要な場合は、可能なら `rtk proxy ...` または `rtk run ...` を使う。
- `rtk` が対応していない、または `rtk` 経由で失敗する場合のみ通常コマンドを使い、その理由を簡潔に説明する。

## External Notes
- 必要に応じて、Obsidian vault を知識整理先として使用してよい。
- Windows / WSL では `/mnt/c/Users/risin/Nextcloud/obsidian_note` を参照する。
- macOS では `~/Nextcloud/obsidian_note` を参照する。
- ユーザーから「要点をまとめて note を取ってほしい」と明示されたときのみ、Obsidian へのメモ化を行う。
- 実際の読み書きは、その場の sandbox 権限に従う。AGENTS.md は権限付与そのものではなく運用方針を示す。
- vault へ追記する前に `/mnt/c/Users/risin/Nextcloud/obsidian_note/Obsidian運用ポリシー.md` を読んでから、配置と粒度を判断する。

## Communication
- 基本のユーザー向け応答は日本語で行う。ユーザーが別言語を求めた場合のみ切り替える。
- 返答は簡潔にし、前提・不確実性・トレードオフを明示する。
- 判断に迷う場合は、黙って決め打ちせず確認する。

## Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**

実装前に以下を守る。
- 仮定は明示する。不確かな場合は確認する。
- 解釈が複数ある場合は、黙って 1 つに決めず候補を示す。
- より単純な方法があるなら、それを示す。必要なら押し返す。
- 不明点があるなら止まり、何が不明かを具体的に書いて確認する。

## Simplicity First
**Minimum code that solves the problem. Nothing speculative.**

- 要求されていない機能を足さない。
- 1 回しか使わないもののために抽象化しない。
- 求められていない設定性や拡張性を先回りで入れない。
- 実際には起きない想定のための過剰なエラーハンドリングを増やさない。
- 200 行必要だと思っても 50 行で済むなら書き直す。

判断基準: 「シニアエンジニアが見て過剰設計だと言うか」を常に考える。

## Surgical Changes
**Touch only what you must. Clean up only your own mess.**

既存コードを編集するときは以下を守る。
- 隣接するコード、コメント、フォーマットを勝手に改善しない。
- 壊れていない箇所をリファクタしない。
- 自分なら別の書き方をしても、既存スタイルに合わせる。
- 無関係な不要コードを見つけても、勝手に消さず必要なら指摘だけする。

自分の変更で不要になったものについてのみ以下を行う。
- 自分の変更で不要になった import、変数、関数は消す。
- 元から存在していた不要コードは、依頼がない限り消さない。

判断基準: 変更したすべての行が依頼内容に直接ひもづいていること。

## Goal-Driven Execution
**Define success criteria. Loop until verified.**

- タスクは、検証可能な成功条件に言い換えてから進める。
- 可能ならテスト、再現手順、ビルド、表示確認などで結果を検証する。
- 複数段階の作業では、短い手順と各段階の確認方法を書く。

例:
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]

弱い成功条件のまま進めず、「どう確認できれば完了か」を先に定義する。

## User Context
- 基本情報技術者資格は所持しているが、応用情報技術者は持っておらず、実務経験のない人間が使用しているので、それを前提にコメントを付記する。
