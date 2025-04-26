type Benchmarks = 'flat_object' | 'flat_array' | 'nested_object' | 'nested_array' | 'deeply_nested_object' | 'deeply_nested_array';

type Result = {
	group: string;
	name: Benchmarks;
	avgScore: number;
	avgTime: number;
	avgScorePerSecond: number;
	stdDevPercentage: number;
	stdDev: number;
	best: number;
	worst: number;
	differenceFromBest: number;
	p75Time: number;
	p95Time: number;
	p99Time: number;
	p999Time: number;
	version: string;
}