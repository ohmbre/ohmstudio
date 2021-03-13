import QtQuick
import QtQuick.Controls

Rectangle {
    id: editor        
    property var title: ''
    property alias text: code.text
    border.color: 'black'
    border.width: 1
    width: parent.width
    height: xpct(19)
    
    OhmText {
        y: -7
        font.family: "Fantasque sans mono"
        font.pixelSize: 6
        text: editor.title
        width: parent.width
    }        
    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 2
        contentHeight: code.paintedHeight
        contentWidth: code.paintedWidth
        clip: true
        TextEdit {
            id: code
            width: flick.width
            height: flick.height
            font.family: "Fantasque sans mono"
            selectByMouse: true
            font.pixelSize: 6
            wrapMode: TextEdit.Wrap
            tabStopDistance: 3*2
            text: editor.placeholder
            onCursorRectangleChanged: {
                if (flick.contentY >= cursorRectangle.y) flick.contentY = cursorRectangle.y
                else if (flick.contentY+flick.height <= cursorRectangle.y+cursorRectangle.height)
                    flick.contentY = cursorRectangle.y+cursorRectangle.height-flick.height;
            }
            Action {
                shortcut: "PgDown"
                enabled: code.activeFocus
                onTriggered: jump(1000)
            }
            Action {
                shortcut: "PgUp"
                enabled: code.activeFocus
                onTriggered: jump(-1000)
            }
            Action {
                shortcut: "Ctrl+f"
                enabled: code.activeFocus
                onTriggered: {
                    search.forceActiveFocus()
                    if (search.text.length > 0) search.textChanged()
                }
            }
        }
    }

    Rectangle {
        border.color: 'black'
        border.width: 1
        anchors.top: flick.bottom
        width: parent.width
        height: 10
        Row {
            x:2; y: 2
            spacing: 4
            
            OhmText {
                font.family: "Fantasque sans mono"
                font.pixelSize: 6
                text: 'search:'
            }
            
            TextInput {
                id: search
                width: parent.width*.9
                font.family: "Fantasque sans mono"
                font.pixelSize: 6
                onTextChanged: {
                    const idx = code.text.indexOf(text)
                    if (idx === -1) return
                    code.cursorPosition = idx
                    code.moveCursorSelection(idx + text.length, TextEdit.SelectCharacters)
                }
                Action {
                    enabled: search.activeFocus
                    shortcut: "Esc"
                    onTriggered: {
                        code.forceActiveFocus()
                    }
                }
                Action {
                    shortcut: "F3"
                    enabled: search.activeFocus || code.activeFocus
                    onTriggered: {
                        if (code.selectionStart == code.selectionEnd) {
                            search.forceActiveFocus()
                            if (search.text.length > 0) search.textChanged()
                            return
                        }
                        const textRemain = code.text.substring(code.cursorPosition,code.text.length)
                        let idx = textRemain.indexOf(search.text);
                        if (idx === -1) {
                            idx = code.text.indexOf(search.text) - code.cursorPosition
                            if (idx === -1) return;
                        }
                        code.cursorPosition += idx
                        code.moveCursorSelection(code.cursorPosition + search.text.length, TextEdit.SelectCharacters)
                    }
                }
            } 
        }
    }
}
