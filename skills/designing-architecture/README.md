# designing-architecture

ドメイン駆動設計・オニオンアーキテクチャ・インターフェース設計・Spike Before Commit を案内するスキル。

## 概要

GEMINI.md Principle V-C (Architecture) から抽出。新規プロジェクトやモジュール設計時に適用される 4 つのアーキテクチャ原則を定義します。

## 原則

1. **Domain-First Design** — 技術ではなくドメインモデルから始める
2. **Onion Architecture** — Domain → Application → Infrastructure の依存方向
3. **Polymorphism via Interfaces** — 契約としてのインターフェース、合成 > 継承
4. **Spike Before Commit** — 外部依存は最小 PoC で検証してから統合

## 構成

```
designing-architecture/
└── SKILL.md    # スキル定義（4原則 + オニオン図）
```

## 起動条件

- 新しいプロジェクトやモジュールを作成するとき
- プロジェクト構造やレイヤリングを決めるとき
- 新しい外部依存を導入するとき
