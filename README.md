# 极简 Hexo 博客

纯白极简风格的 Hexo 博客，使用 Butterfly 主题，已预设为部署到 `blog.sumimi.site`。

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

## 服务器部署（推荐）

本博客的部署配置位于 [`deploy/README.md`](deploy/README.md)。推荐流程：Cloudflare DNS 将 `blog.sumimi.site` 指向服务器 → Nginx 提供静态文件 → GitHub Actions 通过 SSH 自动同步每次提交的构建结果。

根域名 `sumimi.site` 不受影响；子域名 `blog.sumimi.site` 是独立 DNS 记录。

## GitHub Pages + Cloudflare（备选）

1. 把仓库推送到 GitHub。
2. 在 GitHub 仓库的 **Settings → Pages → Build and deployment** 中选择 **GitHub Actions**。
3. 在 Cloudflare DNS 添加 `CNAME`：主机名（例如 `blog`）指向 `你的用户名.github.io`，先设为 **DNS only**。
4. 在 GitHub Pages 填写同一个自定义域名，等待证书生效并开启 HTTPS。
5. 确认访问正常后可将 Cloudflare 代理改为 **Proxied**；SSL/TLS 模式使用 **Full (strict)**。

## 直接部署到自己的服务器

也可以把 `npm run build` 生成的 `public/` 上传到服务器，再由 Nginx 托管。建议目录 `/var/www/blog`，Nginx 站点根目录指向它，并为域名签发 HTTPS 证书。若需要我直接部署，请提供：

- 服务器公网 IP 或 SSH 主机名
- SSH 端口与用户名
- 域名和希望使用的子域名
- 服务器系统与 Web 服务（Nginx/Caddy/其他）
- 通过 SSH 公钥授权（不要在聊天中发送密码或私钥）

如果选择 GitHub Pages 托管，自己的服务器并非必需。
