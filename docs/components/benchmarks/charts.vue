<script setup lang="ts">
import { data as charts } from './charts.data'
import { ref } from 'vue'
import { Mapper } from '../utils/mapper'

const results = charts[0]?.['results'] ?? [];
const sort = ref<string>('flat_object')
const sortDirection = ref<number>(1)
const data = ref<Record<string, any>[]>([])
const baselines = ref<Record<string, any>>({})
const type = ref<'score' | 'time'>('score')
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
  const mapper = new Mapper(results)
  const datasets = mapper.getDatasetsBy(type.value)
  data.value = [...sortBy(column, datasets)]
  console.log(data.value)
};
const getDifferences = () => {
  const mapper = new Mapper(results)
  const datasets = mapper.getDatasetsBy(type.value)
  const sorted = [...sortBy(sort.value, datasets, false)]
  if (baseline.value && baseline.value !== 'null') {
    console.log('baseline', baseline.value, typeof baseline.value)
    /// Calculate difference from the baseline and convert them in percentage
    const baselineData = sorted.find((item) => item.group === baseline.value)
    if (baselineData) {
      for (const item of sorted) {
        const key = item.group
        baselines.value[key] = {}
        for(const [key2, value] of Object.entries(item)) {
          if (key2 !== 'group') {
            const baselineValue = baselineData[key2]
            if (baselineValue !== 0) {
              if (type.value === 'score') {
                const res = ((baselineValue - value) / baselineValue) * 100;
                baselines.value[key][key2] = res > 0 ? '+' + res.toFixed(2) + '%' : res.toFixed(2) + '%'
              } else {
                const res = ((value - baselineValue) / baselineValue) * 100;
                baselines.value[key][key2] = res > 0 ? '+' + res.toFixed(2) + '%' : res.toFixed(2) + '%'
              }
            } else {
              baselines.value[key][key2] = '0%'
            }
          }
        }
      }
    } else {
      baseline.value = null
    }
  } else {
    for (const item of sorted) {
      const key = item.group
      baselines.value[key] = {}
      for(const [key2, value] of Object.entries(item)) {
        if (key2 !== 'group') {
          baselines.value[key][key2] = null
        }
      }
    }
  }
}
getDatasets('flat_object')

</script>

<template>
    <div class="results">
      <div class="header">
        <h1>Benchmark Results</h1>
        <div class="row">
          <div class="select-wrapper">
            <select v-model="type" @change="getDatasets(sort)">
              <option value="score">Score</option>
              <option value="time">Time</option>
            </select>
            <span class="chevron">↓</span>
          </div>
          <p>{{ type === 'score' ? 'Higher is better' : 'Lower is better' }}</p>
        </div>
      </div>
      <div class="benchmark-info">
        <div class="column">
          <div class="system-info">
            <p><b>System:</b> {{ charts[0]?.['system'] }}</p>
            <p><b>Dart Version:</b> {{ charts[0]?.['dart'] }}</p>
            <p><b>CPU:</b> {{ charts[0]?.['cpu'] }}</p>
            <p><b>Memory:</b> {{ charts[0]?.['memory'] }}</p>
            <p><b>Last Execution Date:</b> {{ new Date(Date.parse(charts[0]?.['date'])).toLocaleString() }}</p>
          </div>
          <div class="select-wrapper">
            <select v-model="baseline" @change="getDifferences()">
              <option value="null">Select Baseline</option>
              <option v-for="(item, index) in data" :key="index" :value="item['group']">{{ item['group'] }}</option>
            </select>
            <span class="chevron">↓</span>
          </div>
        </div>
        <div class="column">
          <div class="about-info">
            <p>Results can be influenced by many factors outside the code itself, such as hardware differences, background processes, compiler optimizations, and even the specific data used. Benchmarks often measure only a narrow aspect of performance and may not reflect real-world usage or workloads. Therefore, while benchmarks can provide useful insights, they should not be the sole basis for choosing a tool or approach—context and broader testing are essential.</p>
          </div>
          <div class="results-info">
            <p>The results show the Average ops/sec for each case and the Average time/iter for each case</p>
          </div>
        </div>
      </div>
      <table class="results-table">
        <thead>
          <tr>
            <th>Package</th>
            <th @click="getDatasets('flat_object')" :class="sort === 'flat_object' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Flat Object</th>
            <th @click="getDatasets('nested_object')" :class="sort === 'nested_object' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Nested Object</th>
            <th @click="getDatasets('deeply_nested_object')" :class="sort === 'deeply_nested_object' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Deeply Nested Object</th>
            <th @click="getDatasets('flat_array')" :class="sort === 'flat_array' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Flat Array</th>
            <th @click="getDatasets('nested_array')" :class="sort === 'nested_array' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Nested Array</th>
            <th @click="getDatasets('deeply_nested_array')" :class="sort === 'deeply_nested_array' && ['active', sortDirection === 1 ? 'desc' : 'asc']">Deeply Nested Array</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in data" :key="index">
            <td style="text-transform: uppercase; letter-spacing: 1px;"><a :href="'packages/' + item.group" :data-version="item.version">{{ item.group }}</a></td>
            <td>
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.flat_object }}</p>
              <span class="difference">{{ baselines[item.group]?.flat_object }}</span>
            </td>
            <td>
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.nested_object }}</p>
              <span class="difference">{{ baselines[item.group]?.nested_object }}</span>
            </td>
            <td >
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.deeply_nested_object }}</p>
              <span class="difference">{{ baselines[item.group]?.deeply_nested_object }}</span>
            </td>
            <td>
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.flat_array }}</p>
              <span class="difference">{{ baselines[item.group]?.flat_array }}</span>
            </td>
            <td>
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.nested_array }}</p>
              <span class="difference">{{ baselines[item.group]?.nested_array }}</span>
            </td>
            <td>
              <p :class="type === 'score' ? 'score' : 'time'">{{ item.deeply_nested_array }}</p>
              <span class="difference">{{ baselines[item.group]?.deeply_nested_array }}</span>
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
  flex-direction: row;
  align-items: stretch;
  justify-content: space-between;
  width: 100%;
  gap: 16px;
}
.column {
  flex: 1 1 0;
  min-width: 0;
  box-sizing: border-box;
}
.column {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.select-wrapper {
  position: relative;
  display: flex;
  align-items: flex-end;
}
.select-wrapper select {
  font-family: monospace;
  padding: 8px 32px 8px 12px;
  font-size: 1rem;
  appearance: none;
  -webkit-appearance: none;
  width: 100%;
  -moz-appearance: none;
  background: none;
  border: 1px solid var(--vp-c-divider);
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
  flex-grow: 1;
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
  flex-grow: 1;
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
  flex-grow: 1;
  height: 100%;
}
.row {
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
</style>