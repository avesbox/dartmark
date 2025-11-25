<script setup lang="ts">
defineProps<{
  message: string
}>()
</script>


<template>
	<button class="warning-button">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v4m-1.637-9.409L2.257 17.125a1.914 1.914 0 0 0 1.636 2.871h16.214a1.914 1.914 0 0 0 1.636-2.87L13.637 3.59a1.914 1.914 0 0 0-3.274 0zM12 16h.01"/></svg>
		<p>{{ message }}</p>
	</button>
</template>

<style scoped>
.warning-button {
  width: 16px;
  height: 16px;
  background-color: transparent;
  border: none;
  position: relative;
  cursor: pointer;
}
.warning-button p {
  content: attr(message);
  position: absolute;
  bottom: 100%;
  left: 50%;
  opacity: 0;
  display: inline-block;
  max-width: 300px;
  width: max-content;
  background: var(--vp-c-bg);
  padding: 8px;
  border: 1px solid var(--vp-c-border);
  transform: translate(-50%, 0);
  color: white;
  font-weight: bold;
  font-family: monospace;
  font-size: 12px;
  transition: opacity 0.3s;
  z-index: 10;
}
.warning-button:hover p {
  opacity: 1;
}
</style>