module Model where

import Debug

type alias Model =
  { todos : UndoTodoList
  , currentText : String
  , latestId : TodoId
  }


type alias UndoTodoList =
  { pastStates : List (List Todo) -- most recent first
  , currentState : List Todo
  , futureStates : List (List Todo)
  }


emptyUndoTodoList : UndoTodoList
emptyUndoTodoList =
  { pastStates = []
  , currentState = []
  , futureStates = [] }


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
  , todos = emptyUndoTodoList
  , latestId = 0
  }


{-| Has no effect if the given todo id is not found -}
markDone : TodoId -> Bool -> List Todo -> List Todo
markDone id done todos =
  let
    update todo =
      if todo.id == id then
        { todo | done = done }
      else
        todo
  in
    List.map update todos


delete : TodoId -> List Todo -> List Todo
delete id todos =
  List.filter (\todo -> todo.id /= id) todos


add : Todo -> List Todo -> List Todo
add todo todoList =
  todo :: todoList

-- undo

updateList : (List Todo -> List Todo) -> UndoTodoList -> UndoTodoList
updateList updateFun undoTodoList =
  let
    newList =
      updateFun undoTodoList.currentState
  in
    { pastStates = undoTodoList.currentState :: undoTodoList.pastStates
    , currentState = newList
    , futureStates = []
    }


undo : UndoTodoList -> Maybe UndoTodoList
undo undoTodoList =
  case undoTodoList.pastStates of
    mostRecentState :: furtherBackStates ->
      { pastStates = furtherBackStates
      , currentState = mostRecentState
      , futureStates =  undoTodoList.currentState :: undoTodoList.futureStates
      } |> Just

    _ ->
      Nothing


redo : UndoTodoList -> Maybe UndoTodoList
redo undoTodoList =
  case undoTodoList.futureStates of
    nextStateForward :: furtherForwardStates ->
      { pastStates = undoTodoList.currentState :: undoTodoList.pastStates
      , currentState = nextStateForward
      , futureStates = furtherForwardStates
      } |> Just

    _ ->
      Nothing


canUndo : UndoTodoList -> Bool
canUndo undoTodoList =
  not (List.isEmpty undoTodoList.pastStates)


canRedo : UndoTodoList -> Bool
canRedo undoTodoList =
  not (List.isEmpty undoTodoList.futureStates)


getOrCrash : String -> Maybe a -> a
getOrCrash msg maybe =
  case maybe of
    Just val ->
      val

    Nothing ->
      Debug.crash msg
