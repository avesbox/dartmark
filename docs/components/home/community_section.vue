<script setup lang="ts">
import { motion } from 'motion-v';
import { scrollVariants } from '../actions/scroll_variants';
import { type Sponsor, data } from '../data/sponsors.data';
import { HeartIcon } from './icons';
</script>

<template>
    <section class="py-32 relative overflow-hidden grain">
      <div class="container mx-auto px-6 relative z-10">
        <div class="grid lg:grid-cols-12 gap-12 items-center">
          <motion.div
            :variants="scrollVariants.slideLeft"
            initial="hidden"
            whileInView="visible"
            :viewport="{ once: true, amount: 0.3 }"
            :transition="{ duration: 0.7 }"
            class="lg:col-span-6"
          >
            <div class="text-4xl md:text-5xl lg:text-6xl font-display font-bold leading-tight mb-6">
              We benchmark & compare the best
              <span class="text-primary">Dart & Flutter</span>
              packages
            </div>
            <p class="text-lg text-muted-foreground max-w-md mb-10! leading-relaxed">
              Dartmark provides benchmarks for popular Dart and Flutter packages, helping developers make informed decisions about which packages to use in their projects. 
            </p>

            <div class="flex flex-col sm:flex-row gap-4">
              <a
                href="https://discord.gg/zydgnJ3ksJ"
                target="_blank"
                rel="noopener noreferrer"
                class="group inline-flex items-center gap-3 px-6 py-4 bg-[#5865F2] text-white! font-display font-semibold hover:gap-5 transition-all"
              >
                Join Discord
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14m-6 6l6-6m-6-6l6 6"/></svg>
              </a>
            </div>
          </motion.div>

          <motion.div
            :variants="scrollVariants.scaleIn"
            initial="hidden"
            whileInView="visible"
            :viewport="{ once: true, amount: 0.3 }"
            :transition="{ delay: 0.2, duration: 0.7 }"
            class="lg:col-span-6 relative"
          >
            <div class="relative w-full aspect-square max-w-md mx-auto">
              <motion.div
                class="absolute inset-0 border-2 border-dashed border-primary/30"
                :animate="{ rotate: 360 }"
                :transition="{ duration: 30, repeat: Infinity, ease: 'linear' }"
              />
              
              <div class="absolute inset-8 border-2 border-border bg-card/50 flex items-center justify-center">
                <motion.img
                  src="/logo.png"
                  alt="Avesbox"
                  class="w-32 h-32"
                  :animate="{ y: [0, -10, 0] }"
                  :transition="{ duration: 3, repeat: Infinity, ease: 'easeInOut' }"
                />
              </div>
              
              <div class="absolute -top-3 -left-3 bg-primary text-primary-foreground px-3 py-1 font-mono text-xs uppercase">
                Open Source
              </div>
              <div class="absolute -bottom-3 -right-3 bg-foreground text-background px-3 py-1 font-mono text-xs uppercase">
                Reliable
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
</template>

<style scoped>
a.star:hover {
	color: hsl(var(--background)) !important;
}
.border-border {
  border-color: hsl(var(--border)) !important;
}
</style>