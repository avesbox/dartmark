<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { motion } from 'motion-v'
import { scrollVariants } from '../actions/scroll_variants'
import Table, { Column } from '../table.vue'
import { Mapper } from '../benchmarks/benchmarks'
import { QuestionIcon } from '../home/icons'

const myColumns: Column[] = [
  { key: 'name', label: 'Package' },
  { key: 'rps', label: 'RPS', align: 'right', sortable: true, sortDirection: 'desc' },
  { key: 'stability', label: 'STABILITY', align: 'right', sortable: true, sortDirection: 'desc', },
  { key: 'latency', label: 'LATENCY', align: 'right', sortable: true, sortDirection: 'asc' },
  { key: 'coldStart', label: 'COLD START', align: 'right', sortable: true, sortDirection: 'asc' }
]

const data = ref<any>([])
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

	const records = Mapper.instance.backendBenchmarks?.results || []
	for (const record of records) {
		data.value.push({
			'name': record.framework,
			'coldStart': record.coldStartMs,
			'coldStart_unit': 'ms',
			'rps': Number(record.rps).toFixed(2),
			'rps_unit': 'req/s',
			'latency': Number(record.latency).toFixed(2),
			'latency_unit': 'ms',
			'stability_unit': 'x Jitter',
			'stability': Number(record.stability).toFixed(2),
			'nameUrl': '/web/' + record.framework
		})
	}
	specs.value = [
		{ label: 'DATE', value: new Date(Mapper.instance.validationBenchmarks?.date ?? new Date()).toLocaleDateString() ?? 'N/A' },
		{ label: 'CPU', value: Mapper.instance.validationBenchmarks?.cpu ?? 'N/A' },
		{ label: 'MEMORY', value: Mapper.instance.validationBenchmarks?.memory ?? 'N/A' },
		{ label: 'OS', value: Mapper.instance.validationBenchmarks?.system ?? 'N/A' },
		{ label: 'Dart', value: (Mapper.instance.validationBenchmarks?.dart ?? 'N/A').split(' ')[0] },
		{ label: 'Testing Tool', value: 'OHA 1.13.0' }
	]
})

onBeforeUnmount(() => {
	window.removeEventListener('scroll', syncTooltipPosition, true)
	window.removeEventListener('resize', syncTooltipPosition)
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
				<template #cell-coldStart="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.coldStart_unit }}</span>
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