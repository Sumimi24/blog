# `blog.sumimi.site` 服务器部署

此目录提供 Nginx 配置和 GitHub Actions 自动部署工作流。博客公开地址已设置为 `https://blog.sumimi.site`；`sumimi.site` 根域名不会被占用。

## 一次性配置服务器（Ubuntu / Debian + Nginx）

以下命令在服务器中执行。将 `DEPLOY_USER` 替换为用于部署的普通 SSH 用户名；不要使用 `root`。

```bash
sudo apt update
sudo apt install -y nginx rsync certbot python3-certbot-nginx
sudo mkdir -p /var/www/blog
sudo chown DEPLOY_USER:www-data /var/www/blog
sudo chmod 775 /var/www/blog
sudo cp nginx-blog.sumimi.site.conf /etc/nginx/sites-available/blog.sumimi.site
sudo ln -s /etc/nginx/sites-available/blog.sumimi.site /etc/nginx/sites-enabled/blog.sumimi.site
sudo nginx -t
sudo systemctl reload nginx
```

在 Cloudflare DNS 生效、且橙色云代理暂时关闭（**DNS only**）后，签发证书：

```bash
sudo certbot --nginx -d blog.sumimi.site
```

证书成功后，可在 Cloudflare 将该记录改为 **Proxied**；Cloudflare SSL/TLS 加密模式选 **Full (strict)**。

## Cloudflare DNS

在 `sumimi.site` 的 DNS 中新增记录：

| 类型 | 名称 | 内容 | 代理状态 |
| --- | --- | --- | --- |
| A | `blog` | 你的服务器公网 IPv4 | DNS only（签证书前） |
| AAAA | `blog` | 你的服务器 IPv6（如有） | DNS only（签证书前） |

不要改动 `@` 记录，因此 `sumimi.site` 仍可以指向其他服务。

## 创建 GitHub 部署密钥

在本机 PowerShell 执行（会生成独立于个人登录密钥的一对密钥）：

```powershell
ssh-keygen -t ed25519 -C "github-deploy-blog" -f "$env:USERPROFILE\.ssh\github_deploy_blog"
```

将公钥追加到服务器部署用户的 `~/.ssh/authorized_keys`：

```powershell
Get-Content "$env:USERPROFILE\.ssh\github_deploy_blog.pub"
```

将私钥内容复制到 GitHub 仓库：**Settings → Secrets and variables → Actions → New repository secret**，并创建：

| Secret | 值 |
| --- | --- |
| `SERVER_HOST` | 服务器 IP 或主机名 |
| `SERVER_PORT` | SSH 端口（通常 `22`） |
| `SERVER_USER` | 部署用户，不用 root |
| `SERVER_SSH_KEY` | `github_deploy_blog` 私钥的完整内容 |
| `SERVER_KNOWN_HOSTS` | `ssh-keyscan -p 22 服务器IP` 的输出 |

不要把任意密码、私钥或 GitHub Token 提交到仓库或发送到聊天。

## 发布

推送到 GitHub 的 `main` 或 `master` 分支即可自动发布。首次部署前，请确认 `npm run build` 成功，并在 GitHub Actions 页面观察 `Deploy blog to personal server` 工作流。
