'use strict'

/**
 * Keep LaTeX intact while hexo-renderer-marked parses Markdown.
 * Butterfly later turns these math/tex script nodes into MathJax output.
 */
hexo.extend.filter.register('before_post_render', data => {
  if (!data.mathjax || typeof data.content !== 'string') return data

  const tokens = []
  const save = (tex, display) => {
    const index = tokens.push({ tex, display }) - 1
    return `<!--hexo-math-${index}-->`
  }

  // Protect display math first, so inline matching cannot consume it.
  data.content = data.content.replace(/\$\$([\s\S]*?)\$\$/g, (_, tex) => save(tex.trim(), true))

  // Protect single-dollar inline math. Escaped dollars and multiline text are ignored.
  data.content = data.content.replace(/(?<!\\)(?<!\$)\$([^\n$]+?)(?<!\\)\$(?!\$)/g, (_, tex) => save(tex.trim(), false))

  data.__protectedMath = tokens
  return data
}, 1)

hexo.extend.filter.register('after_post_render', data => {
  const tokens = data.__protectedMath
  if (!Array.isArray(tokens) || typeof data.content !== 'string') return data

  tokens.forEach(({ tex, display }, index) => {
    const marker = `<!--hexo-math-${index}-->`
    const type = display ? 'math/tex; mode=display' : 'math/tex'
    data.content = data.content.split(marker).join(`<script type="${type}">${tex}</script>`)
  })

  delete data.__protectedMath
  return data
}, 100)
