# Elm Todos Tutorial

Multiple stages of a todo list, for learning Elm. In `master` the juicy bits have been deleted to be filled in during a workshop; check the `solved` branch for working versions.

## Prereqs

- Install Elm 0.16, using the [binary installer](http://elm-lang.org/install) or `npm install -g elm`
- Clone this repo
- Node and NPM

## Part 1: Counter

Intro to basic interactivity.

```
cd part1-counter
elm package install
elm reactor # serves on localhost:8000
```

## Part 2: Todo List

```
cd part2-todos
elm package install
elm reactor # serves on localhost:8000
```

## Part 3: Todo List + Undo

```
cd part3-undo-todos
elm package install
elm reactor # serves on localhost:8000
```

## Part 4: Todo List + Undo + Save

```
cd part4-save-undo-todos
elm package install
npm install
node server.js # serves on localhost:8088
```

See [ThomasWeiser/todomvc-elmfire](https://github.com/ThomasWeiser/todomvc-elmfire) for a more built-out example, with collaborative editing powered by Firebase.

## Part 5 (bonus): Chipotle order editor

```
cd part5-chipotle
elm package install
elm reactor # serves on localhost:8000
```
