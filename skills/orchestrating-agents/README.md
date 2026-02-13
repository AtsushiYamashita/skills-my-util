# orchestrating-agents

Supervisor/Worker パターンでタスクを分解・委任するスキル。

## 概要

メインエージェントを監督役（Supervisor）に専念させ、フェーズごとに専門ペルソナに切り替えてタスクを遂行します。設計完了後には3人の専門家によるレビューボードを開催し、品質を担保してからユーザーに提出します。

## フェーズ

```
Hearing → Architecture → Review Board (3視点) → Revision → User Approval → Implementation → Verification
```

| フェーズ       | ペルソナ          | 目的                                         |
| -------------- | ----------------- | -------------------------------------------- |
| Hearing        | 🎤 要件アナリスト | 問題の理解・受容基準の定義                   |
| Architecture   | 📐 アーキテクト   | 設計・技術選定                               |
| Review Board   | 🔧🏢🔒 3専門家    | 工学・ドメイン・セキュリティの多視点レビュー |
| Revision       | 📐 アーキテクト   | レビュー指摘の修正                           |
| User Approval  | 🎯 Supervisor     | ユーザーへの設計提出・承認取得               |
| Implementation | 🔨 ワーカー       | 承認された設計に基づく実装                   |
| Verification   | 🔍 レビュアー     | 受容基準の検証                               |

## 構成

```
orchestrating-agents/
├── SKILL.md                              # Supervisor フロー定義
└── references/
    ├── personas/
    │   ├── hearing.md                    # 要件ヒアリング担当
    │   ├── architect.md                  # 設計担当
    │   ├── worker.md                     # 実装担当
    │   └── reviewer.md                   # 検証担当
    ├── review-board.md                   # 3専門家レビュープロトコル
    └── handoff-format.md                 # フェーズ間引き渡しテンプレート
```

## 起動条件

- 複数の関心事にまたがる非自明なタスクが依頼されたとき
- 品質と正確性がスピードより重要なとき
