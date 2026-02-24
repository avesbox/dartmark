<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { motion } from 'motion-v'
import { scrollVariants } from '../actions/scroll_variants'
import Table, { Column } from '../table.vue'
import { Mapper } from '../benchmarks/benchmarks'

const myColumns: Column[] = [
  { key: 'name', label: 'Package' },
  { key: 'operations', label: 'SCORE', align: 'right', sortable: true, sortDirection: 'desc' },
  { key: 'time', label: 'TIME', align: 'right', sortable: true, sortDirection: 'asc' }
]

const data = ref<any>([])
const specs = ref<any>([])

onMounted(() => {
	const records = Mapper.instance.validationBenchmarks?.results || []
	for (const record of records) {
		data.value.push({
			'name': record.package,
			'operations': record.benchmarks[0].avgScore,
			'time': Number(record.benchmarks[0].avgTime.toFixed(2)),
			'time_unit': 'ms',
			'operations_unit': 'ops/s',
			'nameUrl': '/validation/' + record.package
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
					<div class="text-4xl md:text-5xl font-display font-bold leading-tight">Validation Libraries</div>
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
						This benchmark tests the performance of validation libraries in Dart. It includes various test cases to evaluate the efficiency of each library in handling different validation scenarios.					
					</p>
				</motion.div>
			</div>
			<Table 
				:columns="myColumns" 
				:records="data"
				:initial-sort="{ key: 'operations', direction: 'desc' }"
			>
				<template #cell-name="{ record, value }">
					<a
						:href="record.nameUrl"
						class="text-primary hover:underline"
					>
						{{ value }}
					</a>
				</template>
				<template #cell-operations="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.operations_unit }}</span>
					</span>
				</template>
				<template #cell-time="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.time_unit }}</span>
					</span>
				</template>
			</Table>
			<div class="my-6 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-xs font-mono text-muted-foreground">
				<span v-for="spec in specs" :key="spec.label">
					<span class="text-foreground/60">{{ spec.label }}</span>
					{{ spec.value }}
				</span>
			</div>
			<div class="inline-flex items-center gap-2 text-sm text-muted-foreground! group">
				<span>
					The current table show only the case <span class="text-primary">Flat Object</span>.
				</span>
			</div>
    	</div>
    </section>
</template>