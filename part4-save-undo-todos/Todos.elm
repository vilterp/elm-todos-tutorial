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
  | Save
  | SaveFailed
  | SaveSucceeded
  | ClearFlashMessage FlashMessageId
  | NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of

    -- basics

    AddTodo ->
      let
        newTodo =
          { text = model.currentText
          , id = model.latestId
          , done = False
          }
      in
        ( { model
              | todos <- updateList (\todos -> newTodo :: todos) model.todos
              , currentText <- ""
              , latestId <- model.latestId + 1
          }
        , Effects.none
        )

    MarkDone id done ->
      ( { model | todos <- updateList (\todos -> markDone id done todos) model.todos }
      , Effects.none
      )

    Delete id ->
      ( { model | todos <- updateList (\todos -> delete id todos) model.todos }
      , Effects.none
      )

    UpdateText newText ->
      ( { model | currentText <- newText }
      , Effects.none
      )

    -- undo/redo

    Undo ->
      ( { model | todos <- undo model.todos |> getOrCrash "couldn't undo" }
      , Effects.none
      )

    Redo ->
      ( { model | todos <- redo model.todos |> getOrCrash "couldn't redo" }
      , Effects.none
      )

    -- saving

    Save ->
      ( { model | saveState <- Saving model.todos.currentState }
      , Effects.task
          ( Save.save model.todos.currentState
             |> Task.toResult
             |> Task.map (\result ->
                  case Debug.log "result" result of
                    Ok _ ->
                      SaveSucceeded

                    Err _ ->
                      SaveFailed
                )
          )
      )

    SaveSucceeded ->
      case model.saveState of
        Saving savingList ->
          let
            (newModel, flashId) =
              addFlash "Save succeeded" model
          in
            ( { newModel
                  | saveState <- Chillin
                  , lastSaved <- Just savingList
              }
            , Effects.task (clearAfterTimeout flashId)
            )

        _ ->
          Debug.crash <| "SaveSucceeded in state " ++ toString model.saveState

    SaveFailed ->
      case model.saveState of
        Saving savingList ->
          let
            (newModel, flashId) =
              addFlash "Save failed" model
          in
            ( { newModel | saveState <- Chillin } -- TODO: add message
            , Effects.task (clearAfterTimeout flashId)
            )

        _ ->
          Debug.crash <| "SaveFailed in state " ++ toString model.saveState

    ClearFlashMessage id ->
      ( clearFlash id model
      , Effects.none
      )

    NoOp ->
      ( model
      , Effects.none
      )


clearAfterTimeout : FlashMessageId -> Task x Action
clearAfterTimeout id =
  (Task.sleep (2 * Time.second))
  `Task.andThen` (\_ ->
    Task.succeed (ClearFlashMessage id)
  )


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
        , button
            [ onClick addr Save
            , disabled (not <| isDirty model) ]
            [ text "Save" ]
        ]
    , ul
        []
        (List.map (\msg -> li [] [text msg.text]) model.flashMessages)
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
