# Deadline 清单

一个管理 deadline 的小网页：项目 → task → 子项，每一条都能设截止时间（不填时间默认 23:59）。

- 点圆圈切换：○ 未开始 → ◐ 进行中 → ● 完成
- 半圈时可以写进度说明和预计完成时间
- 数据保存在当前浏览器（localStorage）

直接用浏览器打开 `index.html` 就能用，也可以用 GitHub Pages 发布。

## 云端同步（Supabase）

1. 在 supabase.com 新建项目
2. SQL Editor 里运行 `supabase.sql`
3. Authentication → Sign In / Providers → Email：关掉 Confirm email（或者保留，注册后去邮箱点确认）
4. 把 Project URL 和 publishable key 填到 `index.html` 里的 `SUPA_URL` / `SUPA_KEY`
