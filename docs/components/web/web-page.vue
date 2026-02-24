<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { motion } from 'motion-v'
import { scrollVariants } from '../actions/scroll_variants'
import Table, { Column } from '../table.vue'
import { HttpPackage, Mapper } from '../benchmarks/benchmarks'
import { useData } from 'vitepress'

const props = defineProps<{
	pkg?: string
}>()

// params is a Vue ref
const { params } = useData()

const myColumns: Column[] = [
  { key: 'rps', label: 'RPS' },
  { key: 'latency', label: 'Latency' },
  { key: 'stability', label: 'Stability' },
]

const pkg = ref<HttpPackage | undefined>(undefined)

const data = ref<Record<string, any>[]>([])

onMounted(() => {
	const records = Mapper.instance.backendBenchmarks?.results || []
	pkg.value = Mapper.instance.backendBenchmarks?.packages.find((p) => p.framework === (props?.pkg ?? params.value?.pkg))
	const packageRecords = records.find((v) => v.framework === (props?.pkg ?? params.value?.pkg))
	if (packageRecords) {
		data.value.push(
			{ 'rps': Number(packageRecords.rps).toFixed(2), 'rps_unit': 'req/s', 'latency_unit': 'ms', 'stability_unit': '%',  'latency': Number(packageRecords.latency).toFixed(2), 'stability': (100 - Number(packageRecords.stability ?? 0)).toFixed(2) },
		)
	}
	// const objects: Record<string, any>[] = [
	// 	{ 'rps': packageRecords?.rps ?? 0, unit: 'req/s' },
	// 	{ 'latency': packageRecords?.latency ?? 0, unit: 'ms' },
	// 	{ 'stability': packageRecords?.stability ?? 0, unit: '%' },
	// ]
	// data.value = objects
})

</script>

<template>
  <section class="py-32 relative grain">

      <div class="container mx-auto px-6 flex flex-col gap-16">
			<div class="grid lg:grid-cols-12 gap-8">
				<motion.div
					:variants="scrollVariants.slideLeft"
					initial="hidden"
					whileInView="visible"
					:inViewOptions="{ once: true, amount: 0.3 }"
					:transition="{ duration: 0.6 }"
					class="lg:col-span-4"
				>
					<span class="tag text-muted-foreground mb-4 block w-fit">{{ pkg?.version }}</span>
					<div class="text-4xl md:text-5xl font-display font-bold leading-tight">{{ pkg?.framework}}</div>
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
						{{ pkg?.description }}
					</p>
				</motion.div>
			</div>
			<div class="flex flex-wrap items-center gap-3">
				<a
				  v-for="link in [
					{label: pkg?.publisher, href: pkg?.publisherUrl, external: true },
					{label: 'pub.dev', href: 'https://pub.dev/packages/' + pkg?.framework, external: true }, 
					{label: 'Repository', href: pkg?.repository, external: true }, 
					{label: 'Homepage', href: pkg?.homepage, external: true }
				  ]"
                  :key="link.label"
                  :href="link.href"
                  :target="link.external ? '_blank' : undefined"
                  :rel="link.external ? 'noopener noreferrer' : undefined"
                  class="px-4 py-2 text-sm font-medium text-muted-foreground border border-border rounded-full hover:text-primary hover:border-primary transition-colors"
                >
                  {{ link.label }} →
                </a>
			</div>
			<Table 
				:columns="myColumns" 
				:records="data" 
			>
				<template #cell-latency="{ record, value }">
					<span>
						{{ value }} <span class="text-xs text-muted-foreground">{{ record.latency_unit }}</span>
					</span>
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
			</Table>
			<div class="grid lg:grid-cols-12 gap-8" v-if="(pkg?.features?.length ?? 0) > 0">
				<motion.div
					:variants="scrollVariants.slideLeft"
					initial="hidden"
					whileInView="visible"
					:inViewOptions="{ once: true, amount: 0.3 }"
					:transition="{ duration: 0.6 }"
					class="lg:col-span-4"
				>					
					<div class="text-4xl md:text-5xl font-display font-bold leading-tight">Features</div>
				</motion.div>
			</div>
			<div class="grid md:grid-cols-2 lg:grid-cols-3 gap-px bg-border" v-if="(pkg?.features?.length ?? 0) > 0">
				<motion.div
					:key="result.title"
					:variants="scrollVariants.scaleIn"
					initial="hidden"
					whileInView="visible"
					:inViewOptions="{ once: true, amount: 0.2 }"
					:transition="{ duration: 0.5, delay: index * 0.1 }"
					class="group bg-background p-8 hover:bg-card transition-colors relative"
						v-for="(result, index) in pkg?.features.slice(0, 6)"
				>
					<span 
						:class="[
							'absolute top-4 right-4 font-mono text-xs text-muted-foreground/50',
						]"
					>
						{{ index + 1 }}
					</span>
					<div class="text-xl font-display font-semibold text-foreground mb-3">
						{{ result.title }}	
					</div>
					<div class="flex flex-col gap-2">
						<span class="font-mono text-xs text-muted-foreground/50 flex justify-between items-center results">
							{{ result.description }}
						</span>
					</div>
				</motion.div>
			</div>
    	</div>
    </section>
</template>
<style scoped>
	.text-foreground a {
		color: hsl(var(--foreground)) !important;
		text-decoration: underline;
	}
</style>