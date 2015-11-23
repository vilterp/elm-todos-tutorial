module Todos where

import Signal exposing (Signal)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (..)
import StartApp.Simple as StartApp

import Model exposing (..)

-- controller

type Action
  = UpdateText String
  | AddTodo
  | MarkDone TodoId Bool
  | Delete TodoId
  | Undo
  | Redo
  | NoOp


update : Action -> Model -> Model
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

    NoOp ->
      model


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
  { model = initialModel
  , view = view
  , update = update
  }


main : Signal Html
main =
  StartApp.start config