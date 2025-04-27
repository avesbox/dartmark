import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Dartmark",
  head: [
    ['link', { rel: "icon", type: "image/png", sizes: "32x32", href: "/logo-32x32.png"}],
    ['link', { rel: "icon", type: "image/png", sizes: "16x16", href: "/logo-16x16.png"}],
    ['meta', { property: 'og:title', content: 'Dartmark'}],
    ['meta', { name: 'description', content: 'Benchmarking validation libraries for Dart & Flutter'}],
    ['meta', { property: 'og:description', content: 'Benchmarking validation libraries for Dart & Flutter'}],
  ],
  appearance: 'force-dark',
  themeConfig: {
    footer: {
      copyright: 'Copyright © 2025 Avesbox',
      message: 'Built with 💙 by <a href="https://github.com/avesbox">Avesbox</a>'
    },
    nav: [
      { text: 'Avesbox', link: 'https://avesbox.com' },

    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/avesbox/dartmark' },
      { icon: 'x', link: 'https://x.com/avesboxx' },
      { icon: 'discord', link: 'https://discord.gg/zydgnJ3ksJ' },
      { icon: 'youtube', link: 'https://www.youtube.com/@avesbox' }
    ],
    logo: '/logo.png',
  },
  sitemap: {
    hostname: 'https://dartmark.dev',
    lastmodDateOnly: false
  }
})
