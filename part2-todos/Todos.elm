module Todos where

import Signal exposing (Signal)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (..)
import StartApp.Simple as StartApp

-- model

type alias Model =
  { todos : List Todo
  , currentText : String
  , latestId : TodoId
  }


type alias Todo =
  { id : TodoId
  , text : String
  , done : Bool
  }


type alias TodoId =
  Int


initialModel : Model
initialModel =
  { currentText = ""
  , todos = []
  , latestId = 0
  }


{-| Has no effect if the given todo id is not found -}
markDone : TodoId -> Bool -> Model -> Model
markDone id done model =
  let
    update todo =
      if todo.id == id then
        { todo | done = done }
      else
        todo
  in
    { model | todos = List.map update model.todos }


delete : TodoId -> Model -> Model
delete id model =
  { model | todos = List.filter (\todo -> todo.id /= id) model.todos }


-- controller

type Action
  = UpdateText String
  | AddTodo
  | MarkDone TodoId Bool
  | Delete TodoId
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
            | todos = newTodo :: model.todos
            , currentText = ""
            , latestId = model.latestId + 1
        }

    MarkDone id done ->
      markDone id done model

    Delete id ->
      delete id model

    UpdateText newText ->
      { model | currentText = newText }

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
        (List.map (viewTodo addr) model.todos)
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

app : StartApp.Config Model Action
app =
  { model = initialModel
  , view = view
  , update = update
  }


main : Signal Html
main =
  StartApp.start app