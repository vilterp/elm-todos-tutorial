module Todos where

import Signal exposing (Signal)
import Task exposing (Task)
import Time exposing (Time)
import Debug

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (..)
import StartApp as StartApp
import Effects exposing (Effects)

import Model exposing (..)
import Save

-- controller

type Action
  = UpdateText String
  | AddTodo
  | MarkDone TodoId Bool
  | Delete TodoId
  | Undo
  | Redo
  --| Save
  --| SaveFailed
  --| SaveSucceeded
  --| ClearFlashMessage FlashMessageId
  | NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    AddTodo ->
      let
        newTodo =
          { text = model.currentText
          , id = model.latestId
          , done = False
          }
      in
        { model
            | todos = updateList (\todos -> newTodo :: todos) model.todos
            , currentText = ""
            , latestId = model.latestId + 1
        }

    MarkDone id done ->
      { model | todos = updateList (\todos -> markDone id done todos) model.todos }

    Delete id ->
      { model | todos = updateList (\todos -> delete id todos) model.todos }

    UpdateText newText ->
      { model | currentText = newText }

    Undo ->
      { model | todos = undo model.todos |> getOrCrash "couldn't undo" }

    Redo ->
      { model | todos = redo model.todos |> getOrCrash "couldn't redo" }


clearAfterTimeout : FlashMessageId -> Task x Action
clearAfterTimeout id =
  Debug.crash "TODO"


-- view

view : Signal.Address Action -> Model -> Html
view addr model =
  div
    []
    [ input
        [ type' "text"
        , placeholder "What needs to be done?"
        , onInput addr (\text -> UpdateText text)
        , onKeyUp addr (\keyCode ->
            if keyCode == 13 then AddTodo else NoOp)
        , value model.currentText
        ]
        []
    , ul
        []
        (List.map (viewTodo addr) model.todos.currentState)
    , div
        []
        [ button
            [ onClick addr Undo
            , disabled (not <| canUndo model.todos)
            ]
            [ text "Undo" ]
        , button
            [ onClick addr Redo
            , disabled (not <| canRedo model.todos)
            ]
            [ text "Redo" ]
        ]
    ]


viewTodo : Signal.Address Action -> Todo -> Html
viewTodo addr todo =
  li
    []
    ( [ input
        [ type' "checkbox"
        , checked todo.done
        , on
            "change"
            targetChecked
            (\checked -> Signal.message addr (MarkDone todo.id checked))
        ]
        []
      , span
          [ style
              [ ("text-decoration", if todo.done then "line-through" else "none") ]
          ]
          [ text todo.text ]
      ] ++
      if todo.done then
        [ text " "
        , a
          [ onClick addr (Delete todo.id) ]
          [ text "delete" ]
        ]
      else
        []
    )


-- wiring

config : StartApp.Config Model Action
config =
  { init = (initialModel initialTodos, Effects.none)
  , view = view
  , update = update
  , inputs = []
  }


app : StartApp.App Model
app =
  StartApp.start config


port initialTodos : List { text : String, done : Bool }


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


main : Signal Html
main =
  app.html
