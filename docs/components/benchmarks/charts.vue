<script setup lang="ts">
import { data as charts } from '../benchmarks/charts.data'
import { ref } from 'vue'
import { Mapper } from '../utils/mapper'

const sort = ref<string>('flat_object')
const sortDirection = ref<number>(1)
const data = ref<Record<string, any>[]>([])
const baselines = ref<Record<string, any>>({})
const type = ref<'score' | 'time'>('score')
const resultsByPercentage = ref<Map<string, Record<string, any>>>()
const baseline = ref<string | null>(null)
const sortBy = (column: string, list: Record<string, any>[], changeSort: boolean = true) => {
  let direction = 1
  if (changeSort) {
    if(column === sort.value) {
      direction = sortDirection.value * -1
    } else {
      sort.value = column
    }
    sortDirection.value = direction
  } else {
    direction = sortDirection.value
  }
  const sortedResults = list.sort((a, b) => {
    if (a[sort.value] < b[sort.value]) return -1 * direction
    if (a[sort.value] > b[sort.value]) return 1 * direction
    return 0
  })
  return sortedResults
}

const getDatasets = (column: string) => {
  const mapper = new Mapper()
  const datasets = mapper.getDatasetsBy(type.value)
  data.value = [...sortBy(column, datasets)]
  resultsByPercentage.value = mapper.getResultsPercentagesBy(type.value)
  console.log('value', mapper.getResultsPercentagesBy(type.value).get('acanthis'), 'data')
};
getDatasets('flat_object')

</script>

<template>
    <div class="results">
      <div class="header">
        <h1>Benchmark Results</h1>
      </div>
      <div class="benchmark-info">
        <div class="row-info">
          <div class="system-info">
            <p><b>System:</b> {{ charts[0]?.['system'] }}</p>
            <p><b>Dart Version:</b> {{ charts[0]?.['dart'] }}</p>
            <p><b>CPU:</b> {{ charts[0]?.['cpu'] }}</p>
            <p><b>Memory:</b> {{ charts[0]?.['memory'] }}</p>
            <p><b>Last Execution Date:</b> {{ new Date(Date.parse(charts[0]?.['date'])).toLocaleString() }}</p>
          </div>
          <div class="about-info">
            <p>Results can be influenced by many factors outside the code itself, such as hardware differences, background processes, compiler optimizations, and even the specific data used. Benchmarks often measure only a narrow aspect of performance and may not reflect real-world usage or workloads. Therefore, while benchmarks can provide useful insights, they should not be the sole basis for choosing a tool or approach—context and broader testing are essential.</p>
          </div>
        </div>
        <div class="row-info">
          <div class="select-wrapper">
            <select v-model="type" @change="getDatasets(sort)">
              <option value="score">Score (Higher is better)</option>
              <option value="time">Time (Lower is better)</option>
            </select>
            <span class="chevron">↓</span>
          </div>
          <div class="results-info">
            <p>The results show the Average ops/sec for each case and the Average time/iter for each case</p>
          </div>
        </div>
      </div>
      <table class="results-table">
        <colgroup>
          <col style="width:20%">
          <col style="width:40%">
          <col style="width:40%">
        </colgroup>
        <thead>
          <tr>
            <th>Package</th>
            <th @click="getDatasets('flat_object')" :class="sort === 'flat_object' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Flat Object</th>
            <th @click="getDatasets('flat_array')" :class="sort === 'flat_array' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Flat Array</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in data" :key="index">
            <td style="text-transform: uppercase; letter-spacing: 1px;"><a :href="'packages/' + item.group" :data-version="item.version">{{ item.group }}</a></td>
            <td>
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.flat_object }}</p>
              <div class="bar">
                <div class="bar-background" :style="{ width: resultsByPercentage?.get(item.group)?.flat_object + '%' }"></div>
              </div>
            </td>
            <td>
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.flat_array }}</p>
              <div class="bar">
                <div class="bar-background" :style="{ width: resultsByPercentage?.get(item.group)?.flat_array + '%' }"></div>
              </div>
            </td>
          </tr>
        </tbody>
      </table> 
    </div>
</template>

<style scoped>
.results {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 16px;
  max-width: calc(var(--vp-layout-max-width) - 64px);
  margin: 0 auto;
}
.active::after {
  font-size: 10px;
  font-weight: 400;
  font-family: monospace;
  margin-left: 8px;
}
.active.desc::after {
  content: '\2191';
}
.active.asc::after {
  content: '\2193';
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
.results-table th:not(:first-child) {
  cursor: pointer;
  position: relative;
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
h1 {
  font-size: 24px;
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin: 0;
  font-family: monospace;
}
.header {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
}
.benchmark-info {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  justify-content: space-between;
  width: 100%;
  gap: 16px;
}
.row-info {
  flex: 1 1 0;
  min-width: 0;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.row-info {

}
.select-wrapper {
  position: relative;
  display: flex;
  flex: 1;
  align-items: flex-end;
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-family: monospace;
  font-size: 12px;
  color: var(--vp-c-text-1);
  font-weight: 400;
  border: 1px solid var(--vp-c-divider);
  padding: 8px 16px;
  border-radius: 4px;
  flex: 1;
}
.select-wrapper select {
  font-family: monospace;
  font-size: 1rem;
  appearance: none;
  -webkit-appearance: none;
  width: 100%;
  -moz-appearance: none;
  background: none;
  border-radius: 4px;
  outline: none;
  color: var(--vp-c-text-1);
  background-color: var(--vp-c-bg);
}
.select-wrapper .chevron {
  pointer-events: none;
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
}
.system-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-family: monospace;
  font-size: 12px;
  color: var(--vp-c-text-1);
  font-weight: 400;
  border: 1px solid var(--vp-c-divider);
  padding: 8px 16px;
  border-radius: 4px;
  flex: 1
}
.about-info {
  display: flex;
  flex-direction: column;
  font-family: monospace;
  font-size: 12px;
  color: var(--vp-c-text-1);
  font-weight: 400;
  border: 1px solid var(--vp-c-divider);
  padding: 8px 16px;
  border-radius: 4px;
  text-wrap: balance;
  line-height: 1.7rem;
  flex: 1;
  height: 100%;
}
.results-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-family: monospace;
  justify-content: center;
  font-size: 12px;
  color: var(--vp-c-text-1);
  font-weight: 400;
  border: 1px solid var(--vp-c-divider);
  padding: 8px 16px;
  border-radius: 4px;
  text-wrap: balance;
  line-height: 1rem;
  flex: 1;
  height: 100%;
}
.row, .row-info {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 16px;
}
.row p {
  font-family: monospace;
  font-size: 12px;
  color: var(--vp-c-text-1);
  font-weight: 400;
}
.bar {
  border: 1px solid var(--vp-c-divider);
  border-radius: 999px;
}
.bar-background {
  background-color: var(--vp-c-brand-1);
  height: 8px;
  border-radius: 999px;
}
</style>