# Part 4: Saving to a Server

To demonstrate saving to a server, this stage contains a super-dumb server: it

- stores todos as a JSON file (`./todos.json`)
- serves the compiled elm code at `/app.js`
- serves the single-page app at `/`
  - injects the current todos, providing them to the Elm module at startup
- is written in Node / Express.js (pretty soon will be easy to do in Elm!)

## Install & Run

1. `$ elm-package install`
2. `$ npm install`
3. `$ make` (compiles the Elm by invoking `elm-make`)
4. `node server.js`
