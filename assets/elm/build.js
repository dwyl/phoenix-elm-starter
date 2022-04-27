const esbuild = require('esbuild');
const ElmPlugin = require('esbuild-plugin-elm');

console.log('process.env.PWD', process.env.PWD)

esbuild.build({
  entryPoints: ['assets/elm/src/index.js'],
  bundle: true,
  outdir: 'js',
  watch: process.argv.includes('--watch'),
  plugins: [
    ElmPlugin({
      debug: true,
      clearOnWatch: true,
    }),
  ],
}).catch(_e => process.exit(1))
