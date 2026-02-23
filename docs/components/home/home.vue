<script setup lang="ts">
import { motion } from 'motion-v';
import { scrollVariants } from '../actions/scroll_variants';
import CommunitySection from './community_section.vue';
import HttpBenchResults from './http_bench_results.vue';
import ValidationBenchResults from './validation_bench_results.vue';

</script>

<template>
  	<div class="flex flex-col">
		<CommunitySection />
		<HttpBenchResults />
		<ValidationBenchResults />
	</div>
</template>

<style scoped>
a.star:hover {
	color: hsl(var(--background)) !important;
}
</style>