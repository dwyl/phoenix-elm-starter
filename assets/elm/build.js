const esbuild = require('esbuild');
const ElmPlugin = require('esbuild-plugin-elm');

const isProduction = process.env.MIX_ENV === "prod"

async function watch() {
  const ctx = await esbuild.context({
    entryPoints: ['src/index.js'],
    bundle: true,
    outfile: '../js/elm.js',
    plugins: [
      ElmPlugin({
        debug: true
      }),
    ],
  }).catch(_e => process.exit(1))
  await ctx.watch()
}


async function build() {
  await esbuild.build({
    entryPoints: ['src/index.js'],
    bundle: true,
    minify: true,
    outfile: '../js/elm.js',
    plugins: [
      ElmPlugin(),
    ],
  }).catch(_e => process.exit(1))
}

if (isProduction)
  build()
else
  watch()
