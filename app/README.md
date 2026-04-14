# trip_planner_app

Flutter 版的桃園嘉義旅程規劃 App，已接上 Supabase 旅程同步。

## Supabase setup

此專案是 Flutter app，所以使用的是 `supabase_flutter`（Flutter 對應套件），不是 `@supabase/supabase-js`。

1. 先在 Supabase 專案套用 `/supabase/migrations/001_initial_schema.sql`
2. 用 Flutter 的 `--dart-define` 帶入連線資訊

```bash
cd app
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=你的_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=你的_supabase_anon_key
```

若未提供 Supabase 設定，App 會退回示範資料模式。

## Current capabilities

- 讀取 Supabase 上的 owner / guest 旅程
- 建立旅程並同步新增 `days`
- 編輯旅程名稱與日期
- 刪除 owner 旅程
- 透過邀請碼加入唯讀旅程
- 退出 shared trip
