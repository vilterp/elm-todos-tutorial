module Model where

import Debug

type alias Model =
  { todos : UndoTodoList
  , currentText : String
  , latestId : TodoId
  , lastSaved : Maybe (List Todo)
  , saveState : SaveState
  , flashMessages : List FlashMessage
  , latestFlashId : FlashMessageId
  }


type alias FlashMessageId =
  Int


type alias FlashMessage =
  { id : FlashMessageId
  , text : String
  }


type SaveState
  = Saving (List Todo)
  | Chillin


type alias UndoTodoList =
  { pastStates : List (List Todo) -- most recent first
  , currentState : List Todo
  , futureStates : List (List Todo)
  }


initialUndoTodoList : List Todo -> UndoTodoList
initialUndoTodoList initialState =
  { pastStates = []
  , currentState = initialState
  , futureStates = []
  }


type alias Todo =
  { id : TodoId
  , text : String
  , done : Bool
  }


type alias TodoId =
  Int


initialModel : List { text : String, done : Bool } -> Model
initialModel initialTodos =
  { currentText = ""
  , todos =
      initialTodos
        |> List.map2
            (\id todo ->
              { id = id
              , text = todo.text
              , done = todo.done
              })
            [0..List.length initialTodos]
        |> initialUndoTodoList
  , latestId = List.length initialTodos
  , saveState = Chillin
  , lastSaved = Nothing
  , latestFlashId = 0
  , flashMessages = []
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
      , futureStates = 
          undoTodoList.currentState :: undoTodoList.futureStates
      } |> Just

    _ ->
      Nothing


redo : UndoTodoList -> Maybe UndoTodoList
redo undoTodoList =
  case undoTodoList.futureStates of
    nextStateForward :: furtherForwardStates ->
      { pastStates =
          undoTodoList.currentState :: undoTodoList.pastStates
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

-- Saving

isDirty : Model -> Bool
isDirty model =
  case model.lastSaved of
    Just lastSaved ->
      lastSaved /= model.todos.currentState

    Nothing ->
      model.todos.currentState /= []


-- flash messages

addFlash : String -> Model -> (Model, FlashMessageId)
addFlash text model =
  let
    newFlash =
      { id = model.latestFlashId
      , text = text
      }
  in
    ( { model
          | latestFlashId = model.latestFlashId + 1
          , flashMessages = newFlash :: model.flashMessages
      }
    , model.latestFlashId
    )


clearFlash : FlashMessageId -> Model -> Model
clearFlash id model =
  { model | flashMessages =
      List.filter (\msg -> msg.id /= id) model.flashMessages
  }
