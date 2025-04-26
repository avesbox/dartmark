import DefaultTheme from 'vitepress/theme'
import './style.css'
import Package from './package.vue'

export default {
    extends: DefaultTheme,
    enhanceApp({ app, router, siteData }) {
        // register global components
        app.component('package', Package)
    },
}