<div align="center">

# Phoenix + Elm _Starter_

A **starter kit** 
for adding 
an **`Elm` frontend**
to a **`Phoenix` Web App**lication. 

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/dwyl/phoenix-elm-starter/ci.yml?label=build&style=flat-square&branch=main)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/phoenix-elm-starter/main.svg?style=flat-square)](http://codecov.io/github/dwyl/phoenix-elm-starter?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/phoenix?color=brightgreen&style=flat-square)](https://hex.pm/packages/phoenix)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat-square)](https://github.com/dwyl/phoenix-elm-starter/issues)
[![HitCount](https://hits.dwyl.com/dwyl/phoenix-elm-starter.svg)](https://github.com/dwyl/phoenix-elm-starter)


</div>

## _Why?_

To build a more **advanced UI/UX**,
there is **_nothing_ better than `Elm`**.

<!--
For _browser-based_ apps
requiring quick iteration speed,
excellent long-term maintainability
and pixel-perfect UI,
you've come to the right place!
-->

<!--
Both the "user" and developer 
experience are unrivaled.
The promise of 
["no runtime exceptions"](https://softwareengineering.stackexchange.com/questions/337295/benefit-of-having-no-runtime-errors),
_real_ Type safety 
and an incredible 
["friendly" compiler](https://elm-lang.org/news/compilers-as-assistants)
are no-brainer from an engineering 
perspective. 
We've searched a long time
and nothing else comes close.
--> 

<br />

## What?

A step-by-step guide to getting `Elm` 
working in a `Phoenix` app
with live reloading.

By the end of this guide you will understand
how all the pieces fit together.

Latest `Phoenix`, 
latest `Elm` 
and `esbuild`; 
the fastest build system available.

<br />

## How?

### Prerequisites

_Before_ you start,
make sure you have the following installed:

1. `Elixir`: https://elixir-lang.org/install.html <br />
   New to `Elixir`, see: https://github.com/dwyl/learn-elixir
2. `Phoenix`: https://hexdocs.pm/phoenix/installation.html <br />
   New to `Phoenix` see: 
   https://github.com/dwyl/learn-phoenix-framework
3. `Node.js`: https://nodejs.org/en 
4. `Elm`: https://guide.elm-lang.org/install/elm.html
e.g: `npm install -g elm@elm0.19.1`


Once you have `Elm` installed, 
run the following command in your terminal 
to confirm:

```sh
elm --version
```
you should see:
```sh
0.19.1
```

<br />

### Create the Phoenix App

For this example, we are creating a basic **`Phoenix`** App
without the live dashboard or mailer (email)
but with `Ecto` (Postgres database)
so that we can simulate a real-world app.


```sh
mix phx.new app --no-dashboard --no-mailer
```

```sh
cd app
```

```sh
mix ecto.setup
```

```sh
mix phx.server
```

Open your web browser to the URL: http://localhost:4000

You should see the default **`Phoenix`** home page:

<img width="828" alt="image" src="https://user-images.githubusercontent.com/194400/165493125-0e714185-e268-411f-bb7d-99f7cd0eb8ba.png">

So far so good. 👌 <br />
Let's add **`Elm`**! 

## Add `Elm` to the `Phoenix` App


Change directory in `/assets`,
and create a directory called `elm`.
Inside the `/assets/elm` directory,
run the following command:

```sh
elm init
```
See: https://elm-lang.org/0.19.1/init

You will see the following prompt:

```sh
Hello! Elm projects always start with an elm.json file. I can create them!

Now you may be wondering, what will be in this file? How do I add Elm files to
my project? How do I see it in the browser? How will my code grow? Do I need
more directories? What about tests? Etc.

Check out <https://elm-lang.org/0.19.1/init> for all the answers!

Knowing all that, would you like me to create an elm.json file now? [Y/n]: y
```

Type `y` and `Enter` to continue:
```sh
Okay, I created it. Now read that link!
```

That will have created a new directory at `/assets/elm/src`
and an `elm.json` file.

### Create a `Main.elm` file

Create a new file with the path: 
`/assets/src/Main.elm`
and add the following contents to it:

```elm
module Main exposing (..)
import Html exposing (text)

name = "Alex" -- set name to your name!

main =
  text ("Hello " ++ name ++ "!")
```

### _Manually_ Compile the `Elm` Code

```sh
elm make elm/src/Main.elm --output=../priv/static/assets/elm.js
```
That results in an un-optimized **`elm.js`** file that is **488kb**
For development/testing purposes this is fine;
we can optimize/minify it for production later. (see below)

Let's include this file in our `Phoenix` template just to show that it works.

<br />

### _Temporarily_ add `elm.js` to `root.html.heex` template

> **Note**: this will not work in production,
> it's just for basic illustration as a "_quick win_".

Open the 
`lib/app_web/templates/layout/root.html.heex` 
file
and add the following lines just before the `</body>` element:

```html
<script type="text/javascript" src={Routes.static_path(@conn, "/assets/elm.js")}></script>
<script>
    const $root = document.createElement('div');
    document.body.appendChild($root);

    Elm.Main.init({
        node: $root
    });
</script>
```

With those lines added to the `root.html.heex` file.

Run `mix phx.server` again and refresh your browser: 
http://localhost:4000/

You should see something similar to the following:

![phoenix-elm-hello-alex](https://user-images.githubusercontent.com/194400/165504628-17975e87-447a-4523-8f7c-a4501bf52621.png)

That **`Hello Alex!`** was rendered by `Elm`. 

Now that we know it _can_ work the _hard_ way,
let's do it properly!

**`undo`** those changes made in `root.html.heex`
and save the file.

<br />

## Compile `Elm` via `esbuild`

Next we will include the `elm` app 
into the `esbuild` pipeline
so that: 
1. We can have a watcher and hot reloader.
2. `Phoenix` 
can handle asset compilation 
during deployment.

### 1. Install `esbuild-plugin-elm`

In the `/assets/elm` directory,
run the following command
to install 
[`esbuild-plugin-elm`](https://github.com/phenax/esbuild-plugin-elm)

```sh
npm install -D esbuild-plugin-elm
```

### 2. Create the "initialization" `index.js` file

Create a file with the path
`assets/elm/src/index.js`
and add the the following code: 

```js
import { Elm } from './Main.elm';

const $root = document.createElement('div');
document.body.appendChild($root);

Elm.Main.init({
  node: $root
});
```

Ref: 
[phenax/esbuild-plugin-elm/example/src/index.js](https://github.com/phenax/esbuild-plugin-elm/blob/main/example/src/index.js)


### 3. Create `build.js` file

Create a new file with the path:
`assets/elm/build.js`
and add the following code to it:

```js
const esbuild = require('esbuild');
const ElmPlugin = require('esbuild-plugin-elm');

esbuild.build({
  entryPoints: ['src/index.js'],
  bundle: true,
  outdir: '../js',
  watch: process.argv.includes('--watch'),
  plugins: [
    ElmPlugin({
      debug: true,
      clearOnWatch: true,
    }),
  ],
}).catch(_e => process.exit(1))
```

Ref: 
[phenax/esbuild-plugin-elm/example/build.js](https://github.com/phenax/esbuild-plugin-elm/blob/main/example/build.js)


### 4. Add the Build Command / Watcher to `dev.exs`

Open the `config/dev.exs` file
and locate the `watchers:` section.
Add the following line the list:

```
node: ["./build.js", "--watch", cd: Path.expand("../assets/elm", __DIR__)]
```


### 5. Import the compiled Elm (JS) Code in `app.js`

Open the `assets/js/app.js`
file and add the following lines
near the top of the file:

```js
// import the compiled Elm app:
import './index.js';
```

e.g: 
[app.js#L28](https://github.com/dwyl/phoenix-elm-starter/blob/ee107537c92c1dfd9153710a0d75a5c3936f694f/assets/js/app.js#L28)


<br />

With all 3 files saved,
run the `Phoenix` server:

```sh
mix phx.server
```

You should see output similar to this:

```sh
[info] Running AppWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
[info] Access AppWeb.Endpoint at http://localhost:4000
[watch] build finished, watching for changes...
Success!

    Main ───> /var/folders/f2/3ptgvnsd4kg6v04dt7j1y5dc0000gp/T/2022327-49759-ua0u9f.iqdp.js

[watch] build started (change: "js/index.js")
[watch] build finished
```

That confirms that the `Elm` build + watchers are working. 🚀

### 6. Test Live Reloading!

With the `Phoenix` server running, 
and a browser window open 
pointing to the `Phoenix` App: http://localhost:4000

![elm-hello-alex](https://user-images.githubusercontent.com/194400/165526427-d3d56650-ab6e-4d3b-8990-317b59a0b436.png)

Open the `assets/elm/src/Main.elm` file and
change the line:

```elm
name = "Alex"
```

to:

```elm
name = "World"
```

When you save the file it will automatically reload 
in your web browser and will update the `name` accordingly:

![elm-hello-world](https://user-images.githubusercontent.com/194400/165526558-e6d068c9-42fe-4ba1-aa63-39edfb39d4ac.png)

So the watcher and live reloading is working!

<br />

This is still _very_ far from being a "real world" App.
But the "starter" is here! 

<br />

# Todo

1. "Productionize" the asset compilation:
https://hexdocs.pm/phoenix/asset_management.html#esbuild-plugins

**`@SimonLab`** if you have time to help extend, please go for it! 🙏

2. Add `Elm` Test!

<br />

# _Next_

Create a `Phoenix` Endpoint that returns `json`
that can invoked from `Elm`. <br />
e.g: Return an 
[**inspiring `quote`**](https://github.com/dwyl/quotes)  <br />
Borrow from: https://github.com/dwyl/phoenix-content-negotiation-tutorial

<br />

## Recommended / Relevant Reading

+ `esbuild-plugin-elm`:
https://github.com/phenax/esbuild-plugin-elm
+ Adding a custom watcher to Phoenix:
https://dev.to/contact-stack/adding-a-custom-watcher-to-phoenix-1e10
thanks to [`@michaeljones`](https://github.com/michaeljones) 



<br />

<!--
## Troubleshooting

```sh
[info] Running AppWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
[info] Access AppWeb.Endpoint at http://localhost:4000
[watch] build finished, watching for changes...
/Users/n/code/phoenix-elm-starter
-- NO elm.json FILE ------------------------------------------------------------

It looks like you are starting a new Elm project. Very exciting! Try running:

    elm init

It will help you get set up. It is really simple!

✘ [ERROR] [plugin elm]

    assets/src/index.js:1:20:
      1 │ import { Elm } from './Main.elm';
        ╵                     ~~~~~~~~~~~~

[error] Task #PID<0.525.0> started from AppWeb.Endpoint terminating
** (stop) :watcher_command_error
    (phoenix 1.6.7) lib/phoenix/endpoint/watcher.ex:55: Phoenix.Endpoint.Watcher.watch/2
    (elixir 1.13.3) lib/task/supervised.ex:89: Task.Supervised.invoke_mfa/2
    (stdlib 3.17.1) proc_lib.erl:226: :proc_lib.init_p_do_apply/3
Function: &Phoenix.Endpoint.Watcher.watch/2
    Args: ["node", ["./assets/build.js", "--watch"]]
```



# Below this point is Work-in-Progress!

<br />


### Minify

Following the instructions in:
https://guide.elm-lang.org/optimization/asset_size.html

```
elm make src/Main.elm --optimize --output=elm.js
```

> Install https://www.npmjs.com/package/uglify-js
```
npm install uglify-js -g
```

Compress:
```
uglifyjs elm.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=elm.min.js
```

Optimized and compressed (minimised) version `elm.min.js` is **107kb**


#### GZip

Gzipping the file will result in _much_ faster (down)load times on mobile.

Following these instructions:
https://superuser.com/questions/161706/command-to-gzip

```
gzip elm.min.js
```

> The `gzip` utility is available on Mac/Linux by default.
> Windows: https://stackoverflow.com/questions/36733176/gzip-command-windows

Now it's **33kb**.
(488-33)/488 = **93%** bandwidth saving. 
-->