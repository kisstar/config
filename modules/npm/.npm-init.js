const name = process.cwd().split('/').pop()
const args = process.argv.slice(1)
let retConf = {}

const defaultConf = {
  name,
  version: '1.0.0',
  description: '',
  main: 'index.js',
  test: 'echo "Error: no test specified" && exit 1',
  keywords: [],
  author: 'kisstar <dwh.chn@foxmail.com>',
  repository: 'git@github.com:kisstar/resume.git',
  license: 'MIT',
}

const getUserConf = () => {
  return {
    name: prompt('package name?', defaultConf.name),
    version: prompt('version?', defaultConf.version),
    description: prompt('description?', defaultConf.description),
    main: prompt('entry point?', defaultConf.main),
    scripts: prompt('test command?', defaultConf.test),
    keywords: prompt('keywords?', defaultConf.keywords),
    author: prompt('author?', defaultConf.author),
    repository: prompt('git repository?', defaultConf.repository),
    license: prompt('license?', defaultConf.license),
  }
}

if (args.includes('-y')) {
  retConf = defaultConf
} else {
  retConf = getUserConf()
}

module.exports = retConf
