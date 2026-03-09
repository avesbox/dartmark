<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { QuestionIcon } from './home/icons'

export interface StatItem {
  key: string
  unit: string
  label: string
  value: string | number
  description?: string
}

const props = defineProps<StatItem>()

const iconTrigger = ref<HTMLElement | null>(null)
const tooltipVisible = ref(false)
const tooltipPosition = ref({ top: 0, left: 0 })
const tooltipId = computed(() => `stat-tooltip-${props.key}`)
const hasTooltip = computed(() => Boolean(props.description?.trim()))
const tooltipLabel = computed(() => `More information about ${props.label}`)

const updateTooltipPosition = (target?: EventTarget | null) => {
	const element = (target as HTMLElement | null) ?? iconTrigger.value
	if (!element) {
		return
	}

	const rect = element.getBoundingClientRect()
	const maxLeft = Math.max(16, window.innerWidth - 352)
	tooltipPosition.value = {
		top: rect.bottom + 8,
		left: Math.min(rect.left, maxLeft),
	}
}

const showTooltip = (event?: MouseEvent | FocusEvent) => {
	if (!hasTooltip.value) {
		return
	}

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
})

onBeforeUnmount(() => {
	window.removeEventListener('scroll', syncTooltipPosition, true)
	window.removeEventListener('resize', syncTooltipPosition)
})

</script>
<template>
	<div class="border border-border rounded-lg overflow-hidden w-full overflow-x-auto">
		<div class="text-xs relic text-muted-foreground uppercase bg-muted/50 flex flex-col">
			<div class="justify-between items-center flex">
				<div class="px-4 py-2 font-display font-semibold flex items-center gap-2">
					{{ props.label }}
					<span
						v-if="hasTooltip"
							ref="iconTrigger"
							class="text-xs text-muted-foreground cursor-help"
							tabindex="0"
							:aria-label="tooltipLabel"
							:aria-describedby="tooltipVisible ? tooltipId : undefined"
							@mouseenter="showTooltip"
							@mouseleave="hideTooltip"
							@focus="showTooltip"
							@blur="hideTooltip"
						>
							<QuestionIcon class="w-4! h-4!"/>
						</span>
				</div>
				<div class="px-4 py-2 font-display font-bold">{{ props.value }} <span class="font-normal">{{ props.unit }}</span></div>
			</div>
			<teleport to="body">
				<div
					v-if="tooltipVisible && hasTooltip"
					:id="tooltipId"
					class="pointer-events-none fixed z-[70] w-max max-w-[min(22rem,calc(100vw-2rem))] rounded-md border border-border bg-background px-3 py-2 text-left text-xs leading-relaxed text-muted-foreground whitespace-normal break-words shadow-lg"
					:style="{ top: `${tooltipPosition.top}px`, left: `${tooltipPosition.left}px` }"
					role="tooltip"
				>
					{{ props.description }}
				</div>
			</teleport>
    	</div>
	</div>
</template>
<style scoped>
.border-border {
	border-color: hsl(var(--border))
}
</style>