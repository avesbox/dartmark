<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { motion } from 'motion-v'
import { scrollVariants } from '../actions/scroll_variants'
import Table, { Column } from '../table.vue'
import { Mapper } from '../benchmarks/benchmarks'
import { QuestionIcon } from '../home/icons'

interface ToggleableColumn extends Column {
  default?: boolean
}

const allColumns: ToggleableColumn[] = [
  { key: 'name', label: 'Package', default: true },
  { key: 'rps', label: 'RPS', align: 'right', sortable: true, sortDirection: 'desc', default: true },
  { key: 'stability', label: 'STABILITY', align: 'right', sortable: true, sortDirection: 'desc', default: true },
  { key: 'latency', label: 'LATENCY', align: 'right', sortable: true, sortDirection: 'asc', default: true },
  { key: 'tailLatency', label: 'P99', align: 'right', sortable: true, sortDirection: 'asc' },
	{ key: 'cpuUtilization', label: 'CPU', align: 'right', sortable: true, sortDirection: 'desc' },
  { key: 'throughput', label: 'THROUGHPUT', align: 'right', sortable: true, sortDirection: 'desc' },
  { key: 'coldStart', label: 'COLD START', align: 'right', sortable: true, sortDirection: 'asc', default: true },
  { key: 'memory', label: 'MEMORY', align: 'right', sortable: true, sortDirection: 'asc', default: true },
  { key: 'size', label: 'BINARY SIZE', align: 'right', sortable: true, sortDirection: 'asc', default: true },
]

const visibleKeys = ref<Set<string>>(new Set(allColumns.filter(c => c.default).map(c => c.key)))
const selectedConcurrency = ref<number | null>(null)
const concurrencyDropdownOpen = ref(false)
const columnDropdownOpen = ref(false)
const columnDropdownRef = ref<HTMLElement | null>(null)
const concurrencyDropdownRef = ref<HTMLElement | null>(null)

const allData = ref<any[]>([])

const myColumns = computed<Column[]>(() =>
  allColumns.filter(c => visibleKeys.value.has(c.key))
)

const availableConcurrencies = computed<number[]>(() => {
	const values = [...new Set(allData.value.map((record) => record.concurrency).filter((value) => value != null))]
	return values.sort((a, b) => a - b)
})

const data = computed(() => {
	if (selectedConcurrency.value == null) {
		return allData.value
	}

	return allData.value.filter((record) => record.concurrency === selectedConcurrency.value)
})

const optionalColumns = computed(() =>
  allColumns.filter(c => c.key !== 'name')
)

const toggleColumn = (key: string) => {
  const next = new Set(visibleKeys.value)
  if (next.has(key)) {
    next.delete(key)
  } else {
    next.add(key)
  }
  visibleKeys.value = next
}

const handleClickOutside = (event: MouseEvent) => {
  if (columnDropdownRef.value && !columnDropdownRef.value.contains(event.target as Node)) {
    columnDropdownOpen.value = false
  }

	if (concurrencyDropdownRef.value && !concurrencyDropdownRef.value.contains(event.target as Node)) {
	concurrencyDropdownOpen.value = false
	}
}

const specs = ref<any>([])
const iconTrigger = ref<HTMLElement | null>(null)
const tooltipVisible = ref(false)
const tooltipPosition = ref({ top: 0, left: 0 })
const tooltipId = 'stability-tooltip'

const updateTooltipPosition = (target?: EventTarget | null) => {
	const element = (target as HTMLElement | null) ?? iconTrigger.value
	if (!element) {
		return
	}

	const rect = element.getBoundingClientRect()
	tooltipPosition.value = {
		top: rect.bottom + 8,
		left: rect.left,
	}
}

const showTooltip = (event?: MouseEvent | FocusEvent) => {
	updateTooltipPosition(event?.currentTarget)
	tooltipVisible.value = true
}

const hideTooltip = () => {
	tooltipVisible.value = false
}

const syncTooltipPosition = () => {
	if (!tooltipVisible.value) {
		return
	}

	updateTooltipPosition()
}

onMounted(() => {
	window.addEventListener('scroll', syncTooltipPosition, true)
	window.addEventListener('resize', syncTooltipPosition)
	document.addEventListener('click', handleClickOutside)

	const records = Mapper.instance.backendBenchmarks?.results || []
	for (const record of records) {
		allData.value.push({
			'name': record.framework,
			'coldStart': record.coldStartMs,
			'coldStart_unit': 'ms',
			'rps': Number(record.rps).toFixed(2),
			'rps_unit': 'req/s',
			'latency': Number(record.latency).toFixed(2),
			'latency_unit': 'ms',
			'p50': Number(record.p50).toFixed(2),
			'p50_unit': 'ms',
			'p95': Number(record.p95).toFixed(2),
			'p95_unit': 'ms',
			'tailLatency': Number(record.p99).toFixed(2),
			'tailLatency_unit': 'ms',
			'stability_unit': 'x Jitter',
			'stability': Number(record.stability).toFixed(2),
			'nameUrl': '/web/' + record.framework,
			'memory': record.memoryUsedBytes ? (record.memoryUsedBytes / (1024 * 1024)).toFixed(2) : 'N/A',
			'memory_unit': 'MB',
			'size': record.size ? (record.size / (1024 * 1024)).toFixed(2) : 'N/A',
			'size_unit': 'MB',
			'errors': record.errors ?? 0,
			'concurrency': record.concurrency ?? 'N/A',
			'cpuUtilization': record.cpuUtilization != null ? Number(record.cpuUtilization).toFixed(2) : 'N/A',
			'cpuUtilization_unit': '%',
			'throughput': record.throughput != null ? (record.throughput / (1024 * 1024)).toFixed(2) : 'N/A',
			'throughput_unit': 'MB/s',
		})
	}

	selectedConcurrency.value = availableConcurrencies.value[0] ?? null

	specs.value = [
		{ label: 'DATE', value: new Date(Mapper.instance.validationBenchmarks?.date ?? new Date()).toLocaleDateString() ?? 'N/A' },
		{ label: 'CPU', value: Mapper.instance.validationBenchmarks?.cpu ?? 'N/A' },
		{ label: 'MEMORY', value: Mapper.instance.validationBenchmarks?.memory ?? 'N/A' },
		{ label: 'OS', value: Mapper.instance.validationBenchmarks?.system ?? 'N/A' },
		{ label: 'Dart', value: (Mapper.instance.validationBenchmarks?.dart ?? 'N/A').split(' ')[0] },
		{ label: 'CPU Metric', value: 'Normalized host CPU %' },
		{ label: 'Testing Tool', value: 'OHA 1.13.0' }
	]
})

onBeforeUnmount(() => {
	window.removeEventListener('scroll', syncTooltipPosition, true)
	window.removeEventListener('resize', syncTooltipPosition)
	document.removeEventListener('click', handleClickOutside)
})
</script>

<template>
  <section class="py-32 relative grain">

      <div class="container mx-auto px-6">
			<div class="grid lg:grid-cols-12 gap-8 mb-20">
				<motion.div
					:variants="scrollVariants.slideLeft"
					initial="hidden"
					whileInView="visible"
					:inViewOptions="{ once: true, amount: 0.3 }"
					:transition="{ duration: 0.6 }"
					class="lg:col-span-4"
				>
					<div class="text-4xl md:text-5xl font-display font-bold leading-tight">Web Frameworks</div>
				</motion.div>
				<motion.div
					:variants="scrollVariants.slideRight"
					initial="hidden"
					whileInView="visible"
					:inViewOptions="{ once: true, amount: 0.3 }"
					:transition="{ duration: 0.6, delay: 0.2 }"
					class="lg:col-span-5 lg:col-start-7 flex items-end"
				>
					<p class="text-lg text-muted-foreground leading-relaxed">
						This benchmark tests how fast a framework can perform concurrent HTTP requests and JSON serialization.
					</p>
				</motion.div>
			</div>
			<div class="flex flex-wrap justify-end gap-3 mb-4">
				<div ref="concurrencyDropdownRef" class="relative">
					<button
						@click="concurrencyDropdownOpen = !concurrencyDropdownOpen"
						class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium border border-border rounded-md bg-background text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors"
					>
						Concurrency: {{ selectedConcurrency ?? 'All' }}
						<svg
							:class="['h-3.5 w-3.5 transition-transform', concurrencyDropdownOpen ? 'rotate-180' : '']"
							xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor"
						>
							<path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 11.584l3.71-4.354a.75.75 0 111.14.976l-4.25 5a.75.75 0 01-1.14 0l-4.25-5a.75.75 0 01.02-1.06z" clip-rule="evenodd" />
						</svg>
					</button>
					<div
						v-if="concurrencyDropdownOpen"
						class="absolute flex flex-col gap-2 right-0 mt-1.5 p-2 w-48 overflow-hidden rounded-md border border-border bg-background shadow-lg z-30"
					>
						<button
							v-for="concurrency in availableConcurrencies"
							:key="concurrency"
							type="button"
							class="flex w-full items-center justify-between px-3 py-2 text-xs hover:bg-muted/50 transition-colors"
							@click="selectedConcurrency = concurrency; concurrencyDropdownOpen = false"
						>
							<span>Concurrency {{ concurrency }}</span>
							<span v-if="selectedConcurrency === concurrency">✓</span>
						</button>
					</div>
				</div>
				<div ref="columnDropdownRef" class="relative">
					<button
						@click="columnDropdownOpen = !columnDropdownOpen"
						class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium border border-border rounded-md bg-background text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors"
					>
						<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>
						Columns
						<svg
							:class="['h-3.5 w-3.5 transition-transform', columnDropdownOpen ? 'rotate-180' : '']"
							xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor"
						>
							<path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 011.06.02L10 11.584l3.71-4.354a.75.75 0 111.14.976l-4.25 5a.75.75 0 01-1.14 0l-4.25-5a.75.75 0 01.02-1.06z" clip-rule="evenodd" />
						</svg>
					</button>
					<div
						v-if="columnDropdownOpen"
						class="absolute right-0 mt-1.5 w-48 max-h-64 overflow-y-auto rounded-md border border-border bg-background shadow-lg z-30"
					>
						<label
							v-for="col in optionalColumns"
							:key="col.key"
							class="flex items-center gap-2 px-3 py-2 text-xs cursor-pointer hover:bg-muted/50 transition-colors"
						>
							<input
								type="checkbox"
								:checked="visibleKeys.has(col.key)"
								@change="toggleColumn(col.key)"
								class="rounded border-border accent-primary"
							/>
							<span class="text-foreground">{{ col.label }}</span>
						</label>
					</div>
				</div>
			</div>
			<Table 
				:columns="myColumns" 
				:records="data" 
				:initial-sort="{ key: 'rps', direction: 'desc' }"
			>
				<template #header-stability="{ column }">
					<div class="relative flex items-center gap-1">
						{{ column.label }} 
						<span
							ref="iconTrigger"
							class="text-xs text-muted-foreground cursor-help"
							tabindex="0"
							aria-label="What does stability mean?"
							:aria-describedby="tooltipVisible ? tooltipId : undefined"
							@mouseenter="showTooltip"
							@mouseleave="hideTooltip"
							@focus="showTooltip"
							@blur="hideTooltip"
						>
							<QuestionIcon />
						</span>
					</div>
				</template>
				<template #cell-name="{ record, value }">
					<a
						:href="record.nameUrl"
						class="text-primary hover:underline"
					>
						{{ value }}
					</a>
				</template>
				<template #cell-rps="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.rps_unit }}</span>
					</span>
				</template>
				<template #cell-stability="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.stability_unit }}</span>
					</span>
				</template>
				<template #cell-latency="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.latency_unit }}</span>
					</span>
				</template>
				<template #cell-p50="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.p50_unit }}</span>
					</span>
				</template>
				<template #cell-p95="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.p95_unit }}</span>
					</span>
				</template>
				<template #cell-tailLatency="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.tailLatency_unit }}</span>
					</span>
				</template>
				<template #cell-coldStart="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.coldStart_unit }}</span>
					</span>
				</template>
				<template #cell-throughput="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.throughput_unit }}</span>
					</span>
				</template>
				<template #cell-cpuUtilization="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.cpuUtilization_unit }}</span>
					</span>
				</template>
				<template #cell-memory="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.memory_unit }}</span>
					</span>
				</template>
				<template #cell-size="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.size_unit }}</span>
					</span>
				</template>
			</Table>
			<div class="mt-6 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-xs font-mono text-muted-foreground">
				<span v-for="spec in specs" :key="spec.label">
					<span class="text-foreground/60">{{ spec.label }}</span>
					{{ spec.value }}
				</span>
			</div>
			<teleport to="body">
				<div
					v-if="tooltipVisible"
					:id="tooltipId"
					class="pointer-events-none fixed z-[70] w-max max-w-[min(22rem,calc(100vw-2rem))] rounded-md border border-border bg-background px-3 py-2 text-left text-xs leading-relaxed text-muted-foreground whitespace-normal break-words shadow-lg"
					:style="{ top: `${tooltipPosition.top}px`, left: `${tooltipPosition.left}px` }"
					role="tooltip"
				>
					The stability score is calculated as the ratio of the 50th percentile latency to the 99th percentile latency. The closer this value is to 1, the more stable the framework is under load, indicating consistent performance across requests.
				</div>
			</teleport>
    	</div>
    </section>
</template>
<style scoped>
.border-border {
	border-color: hsl(var(--border));
}
</style>