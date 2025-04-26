import fs from 'node:fs'

export default {
  watch: ['../../data/*.json'],
  load(watchedFiles: any) {
    // watchedFiles will be an array of absolute paths of the matched files.
    // generate an array of blog post metadata that can be used to render
    // a list in the theme layout
    return watchedFiles.map((file) => {
      const content = fs.readFileSync(file, 'utf-8');
      return JSON.parse(content.length === 0 ? '{}' : content);
    })
  }
}