# Practical Elm Log

Code examples from following Practical Elm Book

Ensure you have Node.js installed


Install elm: https://guide.elm-lang.org/install/elm.html

```
elm --version
0.19.1
```

Install `elm-format`:
```
npm install -g elm-format
```

Ran the command:
```
elm init
```
See: https://elm-lang.org/0.19.1/init



```
npm install -g elm@elm0.19.0
elm make src/Main.elm --output=elm.js
```
That results in an un-optimised `elm.js` file that is **488kb**


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


#### GZip

Following https://superuser.com/questions/161706/command-to-gzip

```
gzip elm.min.js
```

Now it's **33kb**.
(488-33)/488 = 93% bandwidth saving.
