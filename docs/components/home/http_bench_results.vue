<script setup lang="ts">
  import { motion } from 'motion-v';
  import { scrollVariants } from '../actions/scroll_variants';
  import { CodeFile, LightningIcon, PuzzleIcon, RadioIcon, SettingsIcon, ShieldIcon } from './icons';
  import { onMounted, ref } from 'vue';
  import { Mapper } from '../benchmarks/benchmarks';

  const benchmarks = ref(Mapper.instance.getBenchmarksForBackend() || []);
  const specs = ref<{ label: string, value: string }[]>([]);

  onMounted(() => {
    specs.value = [
      { label: 'DATE', value: new Date(Mapper.instance.validationBenchmarks?.date).toLocaleDateString() ?? 'N/A' },
      { label: 'CPU', value: Mapper.instance.validationBenchmarks?.cpu ?? 'N/A' },
      { label: 'MEMORY', value: Mapper.instance.validationBenchmarks?.memory ?? 'N/A' },
      { label: 'OS', value: Mapper.instance.validationBenchmarks?.system ?? 'N/A' },
      { label: 'Dart', value: (Mapper.instance.validationBenchmarks?.dart ?? 'N/A').split(' ')[0] },
    ]
  })
</script>

<template>
	<section class="py-32 relative grain">
      <div class="absolute top-20 left-10 text-[150px] font-display font-bold text-stroke opacity-5 select-none hidden lg:block">
        02
      </div>

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
            <span class="tag text-muted-foreground mb-4 block w-fit">{{ Mapper.instance.backendBenchmarks.packages.length }} packages</span>
            <div class="text-4xl md:text-5xl font-display font-bold leading-tight">
              Web Frameworks
            </div>
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
              This benchmark tests how fast a framework can perform concurrent HTTP requests and JSON serialization.
            </p>
          </motion.div>
        </div>

        <!-- Features Grid - Offset layout -->
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-px bg-border">
        	<motion.a
            :href="'/web/' + result.framework.toLowerCase()"  
        	  :key="result.framework"
        	  :variants="scrollVariants.scaleIn"
        	  initial="hidden"
        	  whileInView="visible"
        	  :inViewOptions="{ once: true, amount: 0.2 }"
        	  :transition="{ duration: 0.5, delay: index * 0.1 }"
        	  class="group bg-background p-8 hover:bg-card transition-colors relative"
			      v-for="(result, index) in benchmarks"
        	>
            <!-- Number -->
        	  <span 
              :class="[
                'absolute top-4 right-4 font-mono text-xs text-muted-foreground/50',
                index === 0 ? 'text-primary' : ''
              ]"
            >
        	    {{index + 1}}
        	  </span>
		  
        	  <div class="text-xl font-display font-semibold text-foreground mb-3">
        	    {{ result.framework }}	
        	  </div>
            <div class="flex flex-col gap-2">
              <div class="flex justify-between items-center">
                <span class="font-mono text-xs text-muted-foreground/50">
                  VERSION
                </span>
                <p class="text-xs font-mono text-muted-foreground leading-relaxed">
                  {{ result.version }}
                </p>
                </div>
              <span class="font-mono text-xs text-muted-foreground/50 flex justify-between items-center results">
                RPS
                <span class="ml-1">{{ result.rps.toFixed(2) }}</span>
              </span>
              <div class="w-full h-2 bg-border rounded-full overflow-hidden mt-1">
                <div class="h-full bg-primary rounded-full" :style="{ width: result.rpsPercentage + '%' }"></div>
              </div>
            </div>
        	</motion.a>
        </div>
		    <a href="/web" class="inline-flex items-center gap-2 text-sm text-muted-foreground! hover:text-primary! transition-colors group">
          <span>All benchmarks</span>
          <span class="group-hover:translate-x-1 transition-transform">→</span>
        </a>
        <div className="my-6 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-xs font-mono text-muted-foreground">
          <span v-for="spec in specs" :key="spec.label">
            <span className="text-foreground/60">{{ spec.label }}</span>
            {{ spec.value }}
          </span>
			  </div>
      </div>
    </section>
</template>

<style scoped>
p {
	margin: 0 !important;
}
.results{
	line-height: 1rem;
}
ol {
	padding: 0;
}
</style>