//
//  IQKeyboardManagerConstants.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

///----------------
/// MARK: Debugging
///----------------

/**
Set `-DIQKEYBOARDMANAGER_DEBUG` flag in 'other swift flag' to enable debugging.
*/


///-----------------------------------
/// MARK: IQAutoToolbarManageBehaviour
///-----------------------------------

/**
`IQAutoToolbarBySubviews`
Creates Toolbar according to subview's hirarchy of Textfield's in view.

`IQAutoToolbarByTag`
Creates Toolbar according to tag property of TextField's.

`IQAutoToolbarByPosition`
Creates Toolbar according to the y,x position of textField in it's superview coordinate.
*/
enum IQAutoToolbarManageBehaviour {
    case bySubviews
    case byTag
    case byPosition
}


/*

/---------------------------------------------------------------------------------------------------\
\---------------------------------------------------------------------------------------------------/
|                                   iOS NSNotification Mechanism                                    |
/---------------------------------------------------------------------------------------------------\
\---------------------------------------------------------------------------------------------------/

1) Begin Editing:-         When TextField begin editing.
2) End Editing:-           When TextField end editing.
3) Switch TextField:-      When Keyboard Switch from a TextField to another TextField.
3) Orientation Change:-    When Device Orientation Change.


----------------------------------------------------------------------------------------------------------------------------------------------
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
----------------------------------------------------------------------------------------------------------------------------------------------
=============
UITextField
=============

Begin Editing                                Begin Editing
--------------------------------------------           ----------------------------------           ---------------------------------
|UITextFieldTextDidBeginEditingNotification| --------> | UIKeyboardWillShowNotification | --------> | UIKeyboardDidShowNotification |
--------------------------------------------           ----------------------------------           ---------------------------------
^                  Switch TextField             ^               Switch TextField
|                                               |
|                                               |
| Switch TextField                              | Orientation Change
|                                               |
|                                               |
|                                               |
--------------------------------------------    |      ----------------------------------           ---------------------------------
| UITextFieldTextDidEndEditingNotification | <-------- | UIKeyboardWillHideNotification | --------> | UIKeyboardDidHideNotification |
--------------------------------------------           ----------------------------------           ---------------------------------
|                    End Editing                                                             ^
|                                                                                            |
|--------------------End Editing-------------------------------------------------------------|


----------------------------------------------------------------------------------------------------------------------------------------------
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
----------------------------------------------------------------------------------------------------------------------------------------------
=============
UITextView
=============
|-------------------Switch TextView--------------------------------------------------------------|
| |------------------Begin Editing-------------------------------------------------------------| |
| |                                                                                            | |
v |                  Begin Editing                               Switch TextView               v |
--------------------------------------------           ----------------------------------           ---------------------------------
| UITextViewTextDidBeginEditingNotification| <-------- | UIKeyboardWillShowNotification | --------> | UIKeyboardDidShowNotification |
--------------------------------------------           ----------------------------------           ---------------------------------
^
|
|------------------------Switch TextView--------|
|                                               | Orientation Change
|                                               |
|                                               |
|                                               |
--------------------------------------------    |      ----------------------------------           ---------------------------------
| UITextViewTextDidEndEditingNotification  | <-------- | UIKeyboardWillHideNotification |           | UIKeyboardDidHideNotification |
--------------------------------------------           ----------------------------------           ---------------------------------
|                    End Editing                                                             ^
|                                                                                            |
|--------------------End Editing-------------------------------------------------------------|


----------------------------------------------------------------------------------------------------------------------------------------------
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
----------------------------------------------------------------------------------------------------------------------------------------------
*/
