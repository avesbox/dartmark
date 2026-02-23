import fs from 'node:fs'

export default {
	watch: ['../data/*.json'],
	paths(watchedFiles) {
		if (watchedFiles.length === 0) {
			return [];
		}
		const contents = watchedFiles.map((file) => {
			const content = fs.readFileSync(file, 'utf-8');
			return JSON.parse(content.length === 0 ? '{}' : content);
		})
		return contents.filter((content) => content.id === 'validation')[0]?.['packages'].map((pkg) => {
			return {
				params: {
					pkg: pkg.name,
				}
			}
		})
  	}
}