<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { motion } from 'motion-v'
import { scrollVariants } from '../actions/scroll_variants'
import Table, { Column } from '../table.vue'
import { Mapper } from '../benchmarks/benchmarks'

const myColumns: Column[] = [
  { key: 'name', label: 'Package' },
  { key: 'rps', label: 'RPS', align: 'right', sortable: true, sortDirection: 'desc' },
  { key: 'stability', label: 'STABILITY', align: 'right', sortable: true, sortDirection: 'asc', },
  { key: 'latency', label: 'LATENCY', align: 'right', sortable: true, sortDirection: 'asc' }
]

const data = ref<any>([])
const specs = ref<any>([])

onMounted(() => {
	const records = Mapper.instance.backendBenchmarks?.results || []
	for (const record of records) {
		data.value.push({
			'name': record.framework,
			'rps': Number(record.rps).toFixed(2),
			'rps_unit': 'req/s',
			'latency': Number(record.latency).toFixed(2),
			'latency_unit': 'ms',
			'stability_unit': '%',
			'stability': (100 - Number(record.stability)).toFixed(2),
			'nameUrl': '/web/' + record.framework
		})
	}
	specs.value = [
		{ label: 'DATE', value: new Date(Mapper.instance.validationBenchmarks?.date ?? new Date()).toLocaleDateString() ?? 'N/A' },
		{ label: 'CPU', value: Mapper.instance.validationBenchmarks?.cpu ?? 'N/A' },
		{ label: 'MEMORY', value: Mapper.instance.validationBenchmarks?.memory ?? 'N/A' },
		{ label: 'OS', value: Mapper.instance.validationBenchmarks?.system ?? 'N/A' },
		{ label: 'Dart', value: (Mapper.instance.validationBenchmarks?.dart ?? 'N/A').split(' ')[0] },
	]
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
				<template #cell-name="{ record, value }">
					<a
						:href="record.nameUrl"
						target="_blank"
						rel="noopener noreferrer"
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
			</Table>
			<div className="mt-6 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-xs font-mono text-muted-foreground">
				<span v-for="spec in specs" :key="spec.label">
					<span className="text-foreground/60">{{ spec.label }}</span>
					{{ spec.value }}
				</span>
			</div>
    	</div>
    </section>
</template>