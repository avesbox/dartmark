<script setup lang="ts">
import { computed, ref } from 'vue'

export interface Column {
  key: string
  label: string
  align?: 'left' | 'center' | 'right'
  editable?: boolean
  sortable?: boolean
  sortDirection?: 'asc' | 'desc'
}

interface InitialSort {
  key: string
  direction?: 'asc' | 'desc'
}

const props = defineProps<{
  columns: Column[]
  records: Record<string, any>[]
  initialSort?: InitialSort
}>()

const emit = defineEmits<{
  (e: 'update:record', rowIndex: number, columnKey: string, value: any): void
}>()

const getDefaultDirection = (column: Column) => column.sortDirection ?? 'asc'

const toComparableNumber = (value: unknown): number | null => {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value
  }

  if (typeof value === 'string') {
    const trimmedValue = value.trim()

    if (!trimmedValue) {
      return null
    }

    const normalizedValue = trimmedValue.replace(/,/g, '')

    if (!/^-?\d+(\.\d+)?$/.test(normalizedValue)) {
      return null
    }

    const parsedValue = Number(normalizedValue)
    return Number.isFinite(parsedValue) ? parsedValue : null
  }

  return null
}

const resolveInitialSort = () => {
  if (!props.initialSort) {
    return { key: null, direction: 'asc' as const }
  }

  const column = props.columns.find((col) => col.key === props.initialSort?.key)

  if (!column || !column.sortable) {
    return { key: null, direction: 'asc' as const }
  }

  return {
    key: column.key,
    direction: props.initialSort.direction ?? getDefaultDirection(column),
  }
}

const initialSort = resolveInitialSort()
const activeSortKey = ref<string | null>(initialSort.key)
const activeSortDirection = ref<'asc' | 'desc'>(initialSort.direction)

const sortRecords = (a: any, b: any, direction: 'asc' | 'desc') => {
  if (a == null && b == null) return 0
  if (a == null) return direction === 'asc' ? 1 : -1
  if (b == null) return direction === 'asc' ? -1 : 1

  const numericA = toComparableNumber(a)
  const numericB = toComparableNumber(b)

  if (numericA !== null && numericB !== null) {
    return direction === 'asc' ? numericA - numericB : numericB - numericA
  }

  const normalizedA = String(a)
  const normalizedB = String(b)
  const compare = normalizedA.localeCompare(normalizedB, undefined, {
    numeric: true,
    sensitivity: 'base',
  })

  return direction === 'asc' ? compare : -compare
}

const sortedRecords = computed(() => {
  if (!activeSortKey.value) {
    return props.records
  }

  const sortKey = activeSortKey.value
  const direction = activeSortDirection.value

  return [...props.records].sort((recordA, recordB) =>
    sortRecords(recordA[sortKey], recordB[sortKey], direction),
  )
})

const handleSort = (column: Column) => {
  if (!column.sortable) {
    return
  }

  if (activeSortKey.value === column.key) {
    activeSortDirection.value = activeSortDirection.value === 'asc' ? 'desc' : 'asc'
    return
  }

  activeSortKey.value = column.key
  activeSortDirection.value = getDefaultDirection(column)
}

const getAriaSort = (column: Column) => {
  if (!column.sortable) {
    return 'none'
  }

  if (activeSortKey.value !== column.key) {
    return 'none'
  }

  return activeSortDirection.value === 'asc' ? 'ascending' : 'descending'
}

const handleInput = (rowIndex: number, columnKey: string, event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:record', rowIndex, columnKey, target.value)
}
</script>

<template>
  <div class="border border-border rounded-lg overflow-hidden w-full overflow-x-auto">
    <table class="w-full text-sm text-left">
      <thead class="text-xs text-muted-foreground uppercase bg-muted/50 border-b border-border">
        <tr>
          <th 
            v-for="col in columns" 
            :key="col.key"
            class="px-4 py-3 font-display whitespace-nowrap"
            :class="{
              'text-left': col.align === 'left' || !col.align,
              'text-center': col.align === 'center',
              'text-right': col.align === 'right'
            }"
            :aria-sort="getAriaSort(col)"
          >
            <button
              v-if="col.sortable"
              type="button"
              class="inline-flex items-center gap-1 hover:text-foreground transition-colors"
              @click="handleSort(col)"
            >
              <slot :name="`header-${col.key}`" :column="col">
                {{ col.label }}
              </slot>
              <span v-if="activeSortKey === col.key" aria-hidden="true">
                {{ activeSortDirection === 'asc' ? '↑' : '↓' }}
              </span>
            </button>
            <template v-else>
              <slot :name="`header-${col.key}`" :column="col">
                {{ col.label }}
              </slot>
            </template>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr 
          v-for="(record, rowIndex) in sortedRecords" 
          :key="rowIndex"
          class="border-b border-border transition-colors hover:bg-muted/50 last:border-0"
        >
          <td 
            v-for="col in columns" 
            :key="col.key"
            class="px-4 py-3"
            :class="{
              'text-left': col.align === 'left' || !col.align,
              'text-center': col.align === 'center',
              'text-right': col.align === 'right'
            }"
          >
            <slot :name="`cell-${col.key}`" :value="record[col.key]" :record="record" :index="rowIndex">
              <template v-if="col.editable">
                <input
                  type="text"
                  :value="record[col.key]"
                  @input="handleInput(rowIndex, col.key, $event)"
                  class="w-full bg-transparent border-b border-transparent hover:border-border focus:border-primary focus:outline-none transition-colors px-1 py-0.5"
                  :class="{
                    'text-left': col.align === 'left' || !col.align,
                    'text-center': col.align === 'center',
                    'text-right': col.align === 'right'
                  }"
                />
              </template>
              <template v-else>
                {{ record[col.key] }}
              </template>
            </slot>
          </td>
        </tr>
        <tr v-if="!sortedRecords || sortedRecords.length === 0">
          <td :colspan="columns.length" class="px-4 py-8 text-center text-muted-foreground">
            No data available
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<style scoped>
.border-border {
	border-color: hsl(var(--border))
}
</style>