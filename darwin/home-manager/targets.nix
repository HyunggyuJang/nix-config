{ ... }:
{
  targets.darwin.keybindings = {
    # Control shortcuts
    "^l" = "centerSelectionInVisibleArea:";
    "^/" = "undo:";
    "^_" = "undo:";
    "^ " = "setMark:";
    "^w" = "deleteToMark:";
    "^u" = "deleteToBeginningOfLine:";
    "^g" = "_cancelKey:";
    # Meta shortcuts
    "~y" = "yankPop:";
    "~f" = "moveWordForward:";
    "~b" = "moveWordBackward:";
    "~p" = "selectPreviousKeyView:";
    "~n" = "selectNextKeyView:";
    # Excaping XML expressions should be done automatically!
    "~&lt;" = "moveToBeginningOfDocument:";
    "~&gt;" = "moveToEndOfDocument:";
    "~v" = "pageUp:";
    "~/" = "complete:";
    "~c" = [ "capitalizeWord:" "moveForward:" "moveForward:" ];
    "~u" = [ "uppercaseWord:" "moveForward:" "moveForward:" ];
    "~l" = [ "lowercaseWord:" "moveForward:" "moveForward:" ];
    "~d" = "deleteWordForward:";
    "^~h" = "deleteWordBackward:";
    "~t" = "transposeWords:";
    "~\\@" = [ "setMark:" "moveWordForward:" "swapWithMark:" ];
    "~h" = [ "setMark:" "moveToEndOfParagraph:" "swapWithMark:" ];
    # C-x shortcuts
    "^x" = {
      "u" = "undo:";
      "k" = "performClose:";
      "^f" = "openDocument:";
      "^x" = "swapWithMark:";
      "^m" = "selectToMark:";
      "^s" = "saveDocument:";
      "^w" = "saveDocumentAs:";
    };
  };
}
