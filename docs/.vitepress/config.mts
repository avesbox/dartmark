import { defineConfig } from 'vitepress'
import Tailwind from '@tailwindcss/vite'
import { serinusNocturneTheme, serinusParchmentTheme } from './theme/serinus-parchment'
import llmstxt from 'vitepress-plugin-llms'

// https://vitepress.dev/reference/site-config

const description = "Dartmark is a benchmarking platform for Dart and Flutter packages, helping developers make informed decisions about which packages to use in their projects."
export default defineConfig({
  title: "Dartmark",
  titleTemplate: ':title',
  description,
  head: [
    [
        'link',
        {
            rel: 'icon',
            href: '/logo.png'
        }
    ],
    [
        'meta',
        {
            name: 'viewport',
            content: 'width=device-width,initial-scale=1,user-scalable=no'
        }
    ],
    [
        'meta',
        {
            property: 'og:title',
            content: 'Loxia'
        }
    ],
    [
        'meta',
        {
            property: 'og:description',
            content: description
        }
    ],
    [
        'meta',
        {
            property: 'keywords',
            content: 'dartmark, dart benchmarking, flutter benchmarking, dart packages, flutter packages, dart performance, flutter performance'
        }
    ],
  ],
  markdown: {
    image: {
      lazyLoading: true
    },
    theme: {
      light: {
        ...serinusParchmentTheme,
        type: "light"
      },
      dark: {
        ...serinusNocturneTheme,
        type: "dark"
      }
    },
  },
  sitemap: {
    hostname: 'https://dartmark.dev',
  },
  lastUpdated: true,
  appearance: {
    initialValue: undefined
  },
  ignoreDeadLinks: true,
  themeConfig: {
    // footer: {
    //   copyright: 'Copyright © 2025 Francesco Vallone',
    //   message: 'Built with 💙 and Dart 🎯 | One of the 🐤 of <a href="https://github.com/avesbox">Avesbox</a>',
    // },
    // https://vitepress.dev/reference/default-theme-config
    logo: '/logo.png',
    search: undefined,
    nav: [
      { text: 'Validation Benchmarks', link: '/validation/' },
      { text: 'Web Benchmarks', link: '/web/' },
    ],
    sidebar: [],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/avesbox' },
      { icon: 'twitter', link: 'https://twitter.com/avesboxx'},
      { icon: 'discord', link: 'https://discord.gg/zydgnJ3ksJ' }
    ],
  },
  vite: {
    plugins: [
      Tailwind(),
    ]
  }
})