# Phoenix + Elm _Starter_

A starter kit for getting an `Elm` frontend
working in a `Phoenix` App. 

## Why?

To build a more advanced UI/UX,
there is _nothing_ better than `Elm`.
For _browser-based_ apps
requiring quick iteration speed,
excellent long-term maintainability
and pixel-perfect UI,
you've come to the right place!

Both the "user" and developer 
experience is unrivaled.
The promise of "no runtime exceptions",
_real_ Type safety 
and an incredible 
["friendly" compiler](https://elm-lang.org/news/compilers-as-assistants)
are no-brainer from an engineering 
perspective. 
We've searched a long time
and nothing else comes close.

<br />

## What?

A step-by-step guide to getting `Elm` 
working in a `Phoenix` app.

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

### Add `Elm` to the `Phoenix` App


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

### Create `Main.elm` file

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



### Compile the `Elm` Code

```sh
elm make elm/src/Main.elm --output=../priv/static/assets/elm.js
```
That results in an un-optimized **`elm.js`** file that is **488kb**
For development/testing purposes this is fine;
we can optimize/minify it for production later. (see below)

Let's include this file in our `Phoenix` template just to show that it works.

### _Temporarily_ add `elm.js` to `root.html.heex` template

> **Note**: this will not work in production,
> it's just for basic illustration as a "quick win".

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

### Compile `Elm` via `esbuild`

Next we will include the `elm` app 
into the `esbuild` pipeline
so that `Phoenix` 
can handle asset compilation 
during deployment.


Create a file with the path
`src/index.js`
and add the contents from: 

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

<br />

## Recommended / Relevant Reading

+ `esbuild-plugin-elm`:
https://github.com/phenax/esbuild-plugin-elm




<br />

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




<hr />

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