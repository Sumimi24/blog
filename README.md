# 极简 Hexo 博客

纯白极简风格的 Hexo 博客，使用 Butterfly 主题，发布到 GitHub Pages，并使用 `blog.sumimi.site` 作为自定义域名。

## 本地预览

```bash
npm install
npm run dev
```

访问 <http://localhost:4000>。构建静态文件使用 `npm run build`。

## 发布前必须修改

1. 编辑 `_config.yml` 中的 `title`、`subtitle` 和 `author`。
2. 编辑 `_config.butterfly.yml` 中的社交链接和作者简介。
3. 用自己的头像替换 `source/img/avatar.png`。
4. 如果使用自定义域名，新建 `source/CNAME`，内容只写域名，例如 `blog.example.com`。

## 发布到 GitHub Pages

每次推送到 `main`，GitHub Actions 会构建并发布博客。首次推送后，前往 GitHub 仓库 **Settings → Pages**，确认 Source 为 **GitHub Actions**。

在腾讯云 DNSPod 中，把 `blog` 记录从 A 记录改为以下 CNAME：

| 选项 | 内容 |
| --- | --- |
| 主机记录 | `blog` |
| 记录类型 | `CNAME` |
| 记录值 | `Sumimi24.github.io` |
| TTL | `600` |

然后在 GitHub 仓库 **Settings → Pages → Custom domain** 填入 `blog.sumimi.site` 并保存。证书签发完成后，勾选 **Enforce HTTPS**。

`sumimi.site` 根域名不需要修改，也不会被占用。
