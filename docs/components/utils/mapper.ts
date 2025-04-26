export class Mapper {

	private results: Result[]

	constructor(results: Result[]) {
		this.results = results;
	}

	getBenchmarks(): Benchmarks[] {
		return [...new Set(this.results.map((result) => result.name))];
	}

	getGroups(): string[] {
		return [...new Set(this.results.map((result) => result.group))];
	}

	getResultsBy(type: 'score' | 'time',): Map<string, Record<Benchmarks & { version : string }, number>> {
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
				version: ''
			}
			for (const bench of groupBenchs) {
				groupResults[bench.name] = type === 'score' ? bench.avgScore : Number(bench.avgTime.toFixed(2))
				groupResults['version'] = bench.version
			}
			resultsByBenchmark.set(group, groupResults)
		}
		return resultsByBenchmark
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
					...groupResults
				}
				console.log('data', dataset)
				datasets.push(dataset)
			}
		}
		return datasets
	}

}