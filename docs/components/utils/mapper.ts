import { data as charts } from '../benchmarks/charts.data'


export class Mapper {

	private results: Result[]

	constructor() {
		this.results = charts[0]?.['results'] ?? [];;
	}

	getBenchmarks(): Benchmarks[] {
		return [...new Set(this.results.map((result) => result.name))];
	}

	getGroups(): string[] {
		return [...new Set(this.results.map((result) => result.group))];
	}

	getResultsBy(type: 'score' | 'time',): Map<string, Record<Benchmarks & { version : string, globalPercentage: number }, number>> {
		const groups = this.getGroups()
		const resultsByBenchmark = new Map<string, Record<Benchmarks & { version : string }, number>>()
		for (const group of groups) {
			const groupBenchs = this.results.filter((result) => result.group === group)
			const groupResults: Record<Benchmarks & { version : string }, number> = {
				flat_object: 0,
				flat_array: 0,
				nested_object: 0,
				nested_array: 0,
				deeply_nested_object: 0,
				deeply_nested_array: 0,
				version: '',
				warningMessages: {}
			}
			for (const bench of groupBenchs) {
				groupResults[bench.name] = type === 'score' ? bench.avgScore : Number(bench.avgTime.toFixed(2))
				groupResults['version'] = bench.version
				if (bench.warningMessage) {
					(groupResults as any).warningMessages[bench.name] = bench.warningMessage
				}
			}
			resultsByBenchmark.set(group, groupResults)
		}
		return resultsByBenchmark
	}

	/// Create a function that for each benchmark calculate the percentage difference from the maximum value the values must be all positive and the maximum value must be 100%
	/**
	 * Returns a map with the same shape as getResultsBy but where each benchmark
	 * value is expressed as a percentage of that benchmark's global maximum.
	 * The highest value per benchmark becomes 100, others are (value/max*100) rounded to 2 decimals.
	 * If max is 0, all values become 0 for that benchmark. Ensures all values are >= 0.
	 */
	getResultsPercentagesBy(type: 'score' | 'time'): Map<string, Record<Benchmarks & { version: string }, number>> {
		const raw = this.getResultsBy(type) as Map<string, Record<string, any>>
		const groups = [...raw.keys()]
		const percentages = new Map<string, Record<Benchmarks & { version: string }, number>>()
		if (groups.length === 0) return percentages

		// Determine benchmark keys (exclude 'version')
		const first = raw.get(groups[0])!
		const benchmarkKeys = Object.keys(first).filter(k => k !== 'version')

		// Compute global maxima per benchmark
		const maxima: Record<string, number> = {}
		for (const key of benchmarkKeys) {
			let max = 0
			for (const group of groups) {
				const value = Number(raw.get(group)![key]) || 0
				if (value > max) max = value
			}
			maxima[key] = max
		}

		for (const group of groups) {
			const source = raw.get(group)!
			const rec: Record<Benchmarks & { version: string }, number> = {
				flat_object: 0,
				flat_array: 0,
				nested_object: 0,
				nested_array: 0,
				deeply_nested_object: 0,
				deeply_nested_array: 0,
				version: source.version as unknown as number, // temp assign, fix below

			}
			for (const key of benchmarkKeys) {
				const max = maxima[key] || 0
				const value = Math.max(0, Number(source[key]) || 0)
				rec[key as keyof typeof rec] = max === 0 ? 0 : Number(((value / max) * 100).toFixed(2))
			}
			(rec as any).version = source.version
			percentages.set(group, rec)
		}

		return percentages
	}

	getDatasetsFor(library: string): Record<string, any>[] {
		const groups = this.getGroups()
		const resultsByScore = this.getResultsBy('score')
		const resultsByTime = this.getResultsBy('time')
		const datasets: Record<string, any>[] = []
		for (const group of groups) {
			if (library && group !== library) {
				continue
			}
			const groupResultsScore = resultsByScore.get(group)
			const groupResultsTime = resultsByTime.get(group)
			if (groupResultsScore && groupResultsTime) {
				const dataset: Record<string, any> = {
					group,
					...groupResultsScore,
					type: 'score',
				}
				datasets.push(dataset)
				const datasetTime: Record<string, any> = {
					group,
					...groupResultsTime,
					type: 'time',
				}
				datasets.push(datasetTime)
			}
		}
		return datasets

	}

	getDatasetsBy(type: 'score' | 'time'): Record<string, any>[] {
		const groups = this.getGroups()
		const resultsByType = this.getResultsBy(type)
		const datasets: Record<string, any>[] = []
		for (const group of groups) {
			const groupResults = resultsByType.get(group)
			if (groupResults) {
				const dataset: Record<string, any> = {
					group,
					...groupResults,

				}
				console.log('data', dataset)
				datasets.push(dataset)
			}
		}
		return datasets
	}

}