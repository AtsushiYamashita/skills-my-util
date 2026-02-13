---
name: debugging-systematic
description: Systematic debugging methodology. Activates when encountering bugs, unexpected behavior, test failures, or production errors. Replaces trial-and-error with hypothesis-driven investigation.
license: MIT
metadata:
  author: "AtsushiYamashita"
  version: "1.0"
---

# Systematic Debugging

Hypothesis-driven bug investigation. No guessing.

## Activation

Activate when:

1. Tests fail unexpectedly
2. Runtime errors or unexpected behavior
3. Production incidents or error reports
4. "It works on my machine" situations

## Workflow

1. **Reproduce** — 再現する
2. **Isolate** — 範囲を絞る
3. **Hypothesize** — 仮説を立てる
4. **Test** — 仮説を検証する
5. **Fix** — 修正する
6. **Prevent** — 再発を防ぐ

### Step 1: Reproduce

再現できないバグは修正できない。

- エラーメッセージ、スタックトレース、ログを**完全に**収集する
- 最小限の再現手順を確立する
- 再現できない場合 → 環境差異（OS、バージョン、設定）を調査

### Step 2: Isolate

問題の範囲を狭める。

- **二分探索** — 最後に動いた時点と壊れた時点の間を `git bisect` で特定
- **入力の最小化** — 問題を引き起こす最小の入力を見つける
- **依存関係の切り離し** — 外部サービスをモックに差し替えて内部/外部のどちらが原因か切り分ける

### Step 3: Hypothesize

根拠に基づく仮説を立てる。

- 仮説は**検証可能**でなければならない（「〇〇が原因なら、△△すると□□になるはず」）
- 最大3つの仮説を優先度順に並べる
- 優先基準: 最もありそうなもの → 最も影響が大きいもの → 最も検証しやすいもの

### Step 4: Test

仮説を1つずつ検証する。

- 1回に1つの変数だけ変える
- 検証結果を記録する（仮説 → 予測 → 実際の結果）
- 仮説が外れたら**元に戻して**次の仮説へ（修正を積み重ねない）

### Step 5: Fix

根本原因を修正する。

- 症状ではなく**原因**を修正する
- 修正が他の箇所に影響しないことを確認する
- 修正のコミットメッセージに**根本原因**を記載する

### Step 6: Prevent

同じバグを二度と起こさない。

- 修正したバグの**回帰テスト**を書く
- 同種のバグが他にもないかコードベースを検索する
- 根本的な設計問題がある場合は Issue を作成する

## Anti-Patterns

- ❌ 「とりあえず直してみる」— 原因を理解せずに変更しない
- ❌ 複数の変更を同時に試す — 何が効いたかわからなくなる
- ❌ print デバッグだけに頼る — デバッガ、ログ、トレースを活用する
- ❌ 修正して回帰テストを書かない — 同じバグが戻ってくる
