<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { motion } from 'motion-v'
import { scrollVariants } from '../actions/scroll_variants'
import StatCard, { StatItem } from '../stat-card.vue'
import { HttpPackage, Mapper } from '../benchmarks/benchmarks'
import { useData } from 'vitepress'
import { QuestionIcon } from '../home/icons'

const props = defineProps<{
	pkg?: string
}>()

// params is a Vue ref
const { params } = useData()

const pkg = ref<HttpPackage | undefined>(undefined)

const stats = ref<StatItem[]>([])
const availableConcurrencies = ref<number[]>([])
const selectedConcurrency = ref<number | null>(null)
const concurrencyDropdownOpen = ref(false)
const concurrencyDropdownRef = ref<HTMLElement | null>(null)

const iconTrigger = ref<HTMLElement | null>(null)
const tooltipVisible = ref(false)
const tooltipPosition = ref({ top: 0, left: 0 })
const tooltipId = 'stability-tooltip-package'

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

const updateStats = () => {
	const records = Mapper.instance.backendBenchmarks?.results || []
	const targetFramework = props?.pkg ?? params.value?.pkg
	const rec = records.find(
		(v) => v.framework === targetFramework && v.concurrency === selectedConcurrency.value,
	)

	if (!rec) {
		stats.value = []
		return
	}

	stats.value = [
		{ key: 'rps', label: 'Requests/sec', value: Number(rec.rps).toFixed(2), unit: 'req/s' },
		{ key: 'coldStart', label: 'Cold Start', value: rec.coldStartMs.toFixed(2), unit: 'ms' },
		{ key: 'stability', label: 'Stability', value: Number(rec.stability ?? 0).toFixed(2), unit: 'x Jitter', description: `Normalized under concurrency ${selectedConcurrency.value}. Stability is the ratio of P95 latency to P99 latency. A value closer to 1 indicates more consistent performance under load.` },
		{ key: 'latency', label: 'Average', value: Number(rec.latency).toFixed(2), unit: 'ms' },
		{ key: 'p50', label: 'P50', value: Number(rec.p50).toFixed(2), unit: 'ms' },
		{ key: 'p95', label: 'P95', value: Number(rec.p95).toFixed(2), unit: 'ms' },
		{ key: 'p99', label: 'P99', value: Number(rec.p99).toFixed(2), unit: 'ms' },
		{ key: 'memory', label: 'Memory', value: rec.memoryUsedBytes ? (rec.memoryUsedBytes / (1024 * 1024)).toFixed(2) : 'N/A', unit: 'MB' },
		{ key: 'size', label: 'Binary Size', value: rec.size ? (rec.size / (1024 * 1024)).toFixed(2) : 'N/A', unit: 'MB' },
		{ key: 'throughput', label: 'Throughput', value: rec.throughput ? (rec.throughput / (1024 * 1024)).toFixed(2) : 'N/A', unit: 'MB/s' },
		{ key: 'cpuUtilization', label: 'CPU Utilization', value: Number(rec.cpuUtilization ?? 0).toFixed(2), unit: '%', description: `Share of total host CPU capacity used by the server process during the benchmark. 100% means all ${rec.logicalProcessors ?? 'available'} logical CPUs were fully saturated.` },
	]
}

const handleClickOutside = (event: MouseEvent) => {
	if (concurrencyDropdownRef.value && !concurrencyDropdownRef.value.contains(event.target as Node)) {
		concurrencyDropdownOpen.value = false
	}
}

onMounted(() => {
	window.addEventListener('scroll', syncTooltipPosition, true)
	window.addEventListener('resize', syncTooltipPosition)
	document.addEventListener('click', handleClickOutside)

	const records = Mapper.instance.backendBenchmarks?.results || []
	pkg.value = Mapper.instance.backendBenchmarks?.packages.find((p) => p.framework === (props?.pkg ?? params.value?.pkg))
	availableConcurrencies.value = [...new Set(
		records
			.filter((v) => v.framework === (props?.pkg ?? params.value?.pkg))
			.map((v) => v.concurrency),
	)].sort((a, b) => a - b)
	selectedConcurrency.value = availableConcurrencies.value[0] ?? null
	updateStats()
})

onBeforeUnmount(() => {
	window.removeEventListener('scroll', syncTooltipPosition, true)
	window.removeEventListener('resize', syncTooltipPosition)
	document.removeEventListener('click', handleClickOutside)
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
			<div class="flex flex-col gap-4">
				<div class="flex justify-end">
					<div ref="concurrencyDropdownRef" class="relative">
						<button
							@click="concurrencyDropdownOpen = !concurrencyDropdownOpen"
							class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium border border-border rounded-md bg-background text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors"
						>
							Concurrency: {{ selectedConcurrency ?? 'N/A' }}
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
								@click="selectedConcurrency = concurrency; concurrencyDropdownOpen = false; updateStats()"
							>
								<span>Concurrency {{ concurrency }}</span>
								<span v-if="selectedConcurrency === concurrency">✓</span>
							</button>
						</div>
					</div>
				</div>
				<div class="grid md:grid-cols-3 gap-4">
					<StatCard
						v-for="stat in stats"
						:key="stat.key"
						:label="stat.label"
						:value="stat.value"
						:unit="stat.unit"
						:description="stat.description"
					/>
				</div>
			</div>
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
	.text-foreground a {
		color: hsl(var(--foreground)) !important;
		text-decoration: underline;
	}
	.border-border {
		border-color: hsl(var(--border));
	}
</style>