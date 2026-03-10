// @ts-expect-error VitePress data loaders expose a generated `data` export at build time.
import { data as charts } from '../benchmarks/charts.data'

type HttpResult = {
	framework: string;
	endpoint: string;
	coldStartMs: number;
	rps: number;
	p50: number;
	p95: number;
	p99: number;
	errors: number;
	concurrency: number;
	durationSeconds: number;
	latency: number;
	requests: number;
	version: string;
	cpu: string;
	logicalProcessors: number;
	system: string;
	memoryUsedBytes: number;
	memory: string;
	rpsPercentage: number;
	stability: number;
	size: number;
	throughput: number;
	cpuUtilization: number;
}

type HttpBenchmarks = {
	id: string;
	results: HttpResult[];
	date: string;
	dart: string;
	packages: HttpPackage[]
}

export type ValidationPackage = {
	name: string
	version: string
	description: string
	publisher: string
	publisherUrl: string
	repository: string
	homepage: string
	features: {
		title: string
		description: string
	}[]
}

export type HttpPackage = {
	framework: string
	version: string
	description: string
	publisher: string
	publisherUrl: string
	repository: string
	homepage: string
	features: {
		title: string
		description: string
	}[]
}

type ValidationBenchmarks = {
	id: string;
	results: ValidationResult[];
	date: string;
	dart: string;
	cpu: string;
	system: string;
	memory: string;
	packages: ValidationPackage[]
}

type ValidationResult = {
	package: string;
	benchmarks: {
		name: string;
		warningMessage: string | null;
		avgScore: number;
		avgScorePerSecond: number;
		stdDevPercentage: number;
		stdDev: number;
		best: boolean;
		differenceFromBest: number;
		worst: boolean;
		avgTime: number;
		minTime: number;
		maxTime: number;
		p75Time: number;
		p95Time: number;
		p99Time: number;
		p999Time: number;
		avgScorePercentage: number;
	}[];
	version: string;
}

export class Mapper {
    static #instance: Mapper;

	readonly backendBenchmarks: HttpBenchmarks | undefined = charts.filter((benchmark: any) => benchmark.id === 'http')?.[0];
	readonly validationBenchmarks: ValidationBenchmarks | undefined = charts.filter((benchmark: any) => benchmark.id === 'validation')?.[0];

    private constructor() {}

    public static get instance(): Mapper {
        if (!Mapper.#instance) {
            Mapper.#instance = new Mapper();
        }

        return Mapper.#instance;
    }

	public getBenchmarksForValidation() {
		const results = this.validationBenchmarks?.results || [];
		const sortedResults = [...results].sort((a, b) => b.benchmarks[0].avgScore - a.benchmarks[0].avgScore);
		for (let i = 0; i < sortedResults.length; i++) {
			sortedResults[i].benchmarks[0].avgScorePercentage = (sortedResults[i].benchmarks[0].avgScore / sortedResults[0].benchmarks[0].avgScore) * 100;
		}
		return sortedResults.slice(0, 6);
	}

    /**
     * Finally, any singleton can define some business logic, which can be
     * executed on its instance.
     */
	public getAvailableHttpConcurrencies() {
		const results = this.backendBenchmarks?.results || [];
		return [...new Set(results.map((result) => result.concurrency))].sort((a, b) => a - b);
	}

	public getBenchmarksForBackend(concurrency?: number) {
		const allResults = this.backendBenchmarks?.results || [];
		const resolvedConcurrency = concurrency ?? this.getAvailableHttpConcurrencies()[0];
		const results = resolvedConcurrency == null
			? allResults
			: allResults.filter((result) => result.concurrency === resolvedConcurrency);
		const sortedResults = [...results].sort((a, b) => b.rps - a.rps);
		for (let i = 0; i < sortedResults.length; i++) {
			sortedResults[i].rpsPercentage = (sortedResults[i].rps / sortedResults[0].rps) * 100;
		}
		return sortedResults.slice(0, 6);
    }
}