<script setup lang="ts">
import { data as charts } from '../../components/benchmarks/charts.data'
import { onMounted, ref } from 'vue'
import { Mapper } from '../../components/utils/mapper'
import { useData, useRoute, useRouter } from 'vitepress'

const { page, frontmatter } = useData()
const data = ref<Record<string, any>[]>([])
onMounted(() => {
  const isPageValid = frontmatter && frontmatter.value.title && frontmatter.value.title.length > 0 && frontmatter.value.publisher && frontmatter.value.publisher.length > 0 && frontmatter.value.description && frontmatter.value.description.length > 0 && frontmatter.value.pubdev && frontmatter.value.pubdev.length > 0
  if (!isPageValid) {
    useRouter().go('/404')
  }
  const mapper = new Mapper(charts[0]?.['results'])
  console.log(route.path.split('/')[2].replace('.html', ''))
  console.log(mapper.getDatasetsFor(route.path.split('/')[2].replace('.html', '')))
  data.value = mapper.getDatasetsFor(route.path.split('/')[2].replace('.html', ''))
})
const route = useRoute()
console.log(page.value.frontmatter, route.data)

</script>

<template>
  <div class="package">
    <div class="package__header">
      <div class="package__basic__info">
        <img v-if="page.frontmatter.logo" :src="page.frontmatter.logo" alt="Package Logo" style="height: 64px"/>
        <div class="package__title">
          <h1 class="title">{{ page.frontmatter.title }} <span class="version">{{ data?.[0]?.version }}</span></h1>
          <p class="description">{{ page.frontmatter.description }}</p>
        </div>
      </div>
      <div class="row">
        <div class="column">
          <h2>Publisher</h2>
          <a target="_blank" :href="page.frontmatter.publisher_website">{{ page.frontmatter.publisher }}</a>
        </div>
        <div class="column">
          <h2>Links</h2>
          <div class="links">
            <a v-if="page.frontmatter.pubdev" :href="page.frontmatter.pubdev" target="_blank">Pub.dev</a>
            <a v-if="page.frontmatter.repository" :href="page.frontmatter.repository" target="_blank">Repository</a>
            <a v-if="page.frontmatter.homepage" :href="page.frontmatter.homepage" target="_blank">Homepage</a>
          </div>
        </div>
      </div>
    </div>
    <table class="results-table">
      <thead>
        <tr>
          <th>Type</th>
          <th>Flat Object</th>
          <th>Nested Object</th>
          <th>Deeply Nested Object</th>
          <th>Flat Array</th>
          <th>Nested Array</th>
          <th>Deeply Nested Array</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in data" :key="index">
          <td>
            <p style="text-transform: uppercase; letter-spacing: 1px;">{{ item.type }}</p>
          </td>
          <td>
            <p :class="item.type">{{ item.flat_object }}</p>
          </td>
          <td>
            <p :class="item.type">{{ item.nested_object }}</p>
          </td>
          <td >
            <p :class="item.type">{{ item.deeply_nested_object }}</p>
          </td>
          <td>
            <p :class="item.type">{{ item.flat_array }}</p>
          </td>
          <td>
            <p :class="item.type">{{ item.nested_array }}</p>
          </td>
          <td>
            <p :class="item.type">{{ item.deeply_nested_array }}</p>
          </td>
        </tr>
      </tbody>
    </table> 
    <div v-if="frontmatter.features" class="features">
      <h2 class="title">Features</h2>
      <div v-for="(item, index) in frontmatter.features" :key="index" class="column">
        <h2>{{ item.title }}</h2>
        <p v-if="item.description">{{ item.description }}</p>
        <p v-if="item.value">{{ item.value }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.package {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  max-width: calc(var(--vp-layout-max-width) - 64px);
  margin: 0 auto;
  gap: 16px;
}
.package__header {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
  gap: 16px;
}
.package__basic__info {
  display: flex;
  gap: 16px;
}
.package__title {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.title {
  font-size: 24px;
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-family: monospace;
}
.row {
  display: flex;
  width: 100%;
  justify-content: space-between;
  align-items: center;
  gap: 16px
}
.column {
  display: flex;
  flex-direction: column;
  max-width: calc(var(--vp-layout-max-width) / 2 - 32px);
  flex-grow: 1;
  border: 1px solid var(--vp-c-divider);
  padding: 8px 16px;
  border-radius: 4px;
}
.description {
  font-size: 16px;
  font-weight: 400;
  color: var(--vp-c-text-2);
  font-family: monospace;
  letter-spacing: 1px;
}
.column h2 {
  font-size: 12px;
  font-weight: 600;
  color: var(--vp-c-text-2);
  font-family: monospace;
  text-transform: uppercase;
  letter-spacing: 1px;
}
.column p {
  font-size: 14px;
  font-weight: 400;
  color: var(--vp-c-text-1);
  font-family: monospace;
  letter-spacing: 1px;
}
.column a {
  font-size: 14px;
  font-weight: 400;
  color: var(--vp-c-text-1);
  font-family: monospace;
  letter-spacing: 1px;
  text-decoration: underline;
  transition: all 0.2s ease-in-out;
}
.column a:hover {
  text-decoration: none;
}
.links {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.results-table {
  width: 100%;
  border-collapse: collapse;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid var(--vp-c-divider);
}
.results-table th {
  background-color: var(--vp-c-bg-soft);
  color: white;
  text-align: left;
  font-size: 14px;
  font-weight: 600;
  border: 1px solid var(--vp-c-divider);
  padding: 8px 16px;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-family: monospace;
}
.results-table td {
  padding: 16px;
  border: 1px solid var(--vp-c-divider);
  font-size: 14px;
  font-weight: 400;
  font-family: monospace;
  position: relative;
}
.results-table td:first-child a::after {
  content: attr(data-version);
  font-size: 10px;
  font-weight: 400;
  font-family: monospace;
  color: var(--vp-c-text-2);
  margin-left: 8px;
}
.results-table td p {
  font-size: 14px;
  font-weight: 400;
  font-family: monospace;
  position: relative;
}
.results-table td:not(:first-child) p::after {
  font-size: 10px;
  font-weight: 400;
  font-family: monospace;
  color: var(--vp-c-text-2);
  margin-left: 8px;
}
.results-table td .difference {
  font-size: 10px;
  font-weight: 400;
  font-family: monospace;
  text-transform: uppercase;
  letter-spacing: 1px;
  text-align: center;
}
.results-table td:not(:first-child) p.time::after {
  content: 'ns/iter';
}
.results-table td:not(:first-child) p.score::after {
  content: 'ops/s';
}
.version {
  font-size: 12px;
  font-weight: 400;
  color: var(--vp-c-text-2);
  font-family: monospace;
  letter-spacing: 1px;
}
.features {
  display: grid;
  grid-template-columns: 50% 50%;
  width: 100%;
  gap: 16px;
}
.features .title {
  grid-column: 1 / -1;
}
</style>