# 博客与 Obsidian 使用说明

博客地址：<https://blog.sumimi.site>  
源码仓库：<https://github.com/Sumimi24/blog>

本博客使用 Hexo、Butterfly 和 GitHub Pages。文章采用 Markdown 编写，推送到 GitHub 后会自动构建和发布。

## 1. 推荐的 Obsidian 目录

当前使用的 Obsidian 博客仓库位于：

```text
C:\Users\10929\Desktop\Obsidian传送门\Blog写作库\
├─ 模板/
│  └─ 博客文章模板.md
├─ 附件/
└─ 上传MD文本库/
```

只有 `上传MD文本库` 中带有 `publish: true` 的笔记会被导入。“黑曜石小屋”私人仓库不会被读取或发布。

## 2. Obsidian 文章模板

在 Obsidian 新建模板：

```markdown
---
title: 文章标题
date: 2026-08-14 10:00:00
updated: 2026-08-14 10:00:00
categories:
  - 技术
tags:
  - Hexo
  - Obsidian
description: 用一两句话概括文章内容。
publish: true
---

这里开始写正文。

## 第一部分

支持普通 Markdown、代码块、表格、引用和图片。
```

字段说明：

- `title`：文章标题。
- `date`：首次发布日期。
- `updated`：最后修改日期，可省略。
- `categories`：文章分类，建议每篇只使用一个主要分类。
- `tags`：文章标签，可以有多个。
- `description`：首页显示的摘要，也用于搜索引擎描述。
- `publish: true`：允许导入和公开发布；删掉或改成 `false` 就不会导入。
- `draft: true`：Hexo 草稿标记。正式发布前应删除或设为 `false`。

如果缺少 `title`、`date`、`categories` 或 `tags`，导入工具会自动补充默认值。

## 3. 图片用法

导入工具支持 Obsidian 图片语法：

```markdown
![[示意图.png]]
![[示意图.png|图片说明]]
```

也支持相对路径 Markdown 图片：

```markdown
![图片说明](../Attachments/示意图.png)
```

导入时，图片会复制到：

```text
source/img/obsidian/文章文件名/
```

同时自动改写网页中的图片路径。建议图片文件名简短明确，不要在不同目录中保存多个同名图片。

普通网络图片不需要复制：

```markdown
![图片说明](https://example.com/image.png)
```

## 4. 从 Obsidian 导入

在博客项目目录打开 PowerShell：

```powershell
cd "C:\Users\10929\Documents\ChatGPT\服务器"
```

运行：

```powershell
npm.cmd run obsidian:import -- -VaultPath "C:\Users\10929\Desktop\Obsidian传送门\Blog写作库"
```

导入器默认读取 `上传MD文本库`。如果以后修改了目录名称，可以显式指定：

```powershell
npm.cmd run obsidian:import -- -VaultPath "C:\Users\10929\Desktop\Obsidian传送门\Blog写作库" -BlogFolder "新的目录名"
```

临时导入该目录中的所有 Markdown，不检查 `publish: true`：

```powershell
npm.cmd run obsidian:import -- -VaultPath "C:\Users\10929\Desktop\Obsidian传送门\Blog写作库" -PublishAll
```

导入后的文章位于：

```text
source/_posts/obsidian/
```

重复执行导入会更新同名文章，但不会删除已经导入的旧文章。若一篇文章不再发布，请同时手动删除 `source/_posts/obsidian` 中对应的文件。

## 5. 本地预览

第一次使用先安装依赖：

```powershell
npm.cmd install
```

启动本地博客：

```powershell
npm.cmd run dev
```

浏览器打开：

```text
http://localhost:4000
```

停止预览时，在 PowerShell 中按 `Ctrl + C`。

发布前建议完整构建一次：

```powershell
npm.cmd run clean
npm.cmd run build
```

## 6. 发布到线上

确认本地预览没有问题后执行：

```powershell
git add .
git commit -m "发布新的 Obsidian 笔记"
git push
```

GitHub Actions 会自动完成构建和发布。通常等待一到三分钟即可在以下地址看到更新：

<https://blog.sumimi.site>

可以在仓库的 Actions 页面查看发布状态：

<https://github.com/Sumimi24/blog/actions>

## 7. 不通过 Obsidian 写文章

直接创建文章：

```powershell
npx.cmd hexo new post "文章标题"
```

文件会出现在 `source/_posts`。编辑完成后，按“本地预览”和“发布到线上”的步骤操作。

## 8. 编辑博客信息

- 网站标题、作者、描述和网址：`_config.yml`
- 导航、侧栏、搜索和主题功能：`_config.butterfly.yml`
- 纯白极简样式：`source/css/minimal.css`
- 关于页面：`source/about/index.md`
- 友链数据：`source/_data/link.yml`
- 头像：`source/img/avatar.png`
- 图标：`source/favicon.ico`

## 9. Markdown 兼容注意事项

以下 Obsidian 专用功能不会直接变成标准网页功能：

- 普通双向链接 `[[另一篇笔记]]`
- 查询语法和 Dataview
- Canvas 文件
- 插件生成的动态内容
- Obsidian Callout 的部分高级样式

图片嵌入 `![[图片.png]]` 已由导入工具支持。普通双向链接建议改成标准 Markdown：

```markdown
[链接文字](https://blog.sumimi.site/目标地址/)
```

## 10. 常见问题

### 笔记没有被导入

检查笔记是否：

1. 位于 `上传MD文本库` 中；
2. 文件扩展名是 `.md`；
3. Front Matter 中包含 `publish: true`。

### 图片没有显示

检查图片是否存在于 Obsidian 仓库内、文件名是否正确，以及是否出现多个同名文件。重新导入后再运行 `npm.cmd run build`。

### 网站还是旧内容

进入 GitHub Actions 检查最新任务是否成功，并等待 GitHub Pages 缓存刷新。必要时强制刷新浏览器：`Ctrl + F5`。

### 文章公开后想撤回

删除 `source/_posts/obsidian` 中的对应文章，提交并推送。只把 Obsidian 中的 `publish` 改为 `false` 不会自动删除线上已经存在的文章。

### GitHub Actions 构建失败

先在本地运行：

```powershell
npm.cmd run clean
npm.cmd run build
```

本地构建通常会显示具体是哪篇文章、哪个 YAML 字段或哪条 Markdown 语法出错。
