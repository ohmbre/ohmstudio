import ohm 1.0
import QtQuick

Module {
    id: shaderMod    
    label: 'Shader'
    

    InJack {
        label: 'input';
        onInFuncUpdated: function (lbl,func) {
           renderWin.shaderSink.setFunc(func);
        }
    }

    tags: ['interface']

    property var vertex: "void main() {\n  gl_Position = ubuf.qt_Matrix * aVertex;\n  vTexCoord = aTexCoord;\n}"
    
    property var fragment: "void main() {\n  fragColor = vec4(fragCoord.x,1,1,1);\n}"

    display: Column {
        spacing: 23
        width: parent.width
        OhmEditor {
            id: vertEdit
            title: "Vertex Shader"            
            width: parent.width
            text: vertex
            onTextChanged: shaderMod.vertex = text
        }
        
        OhmEditor {
            id: fragEdit
            title: "Fragment Shader"            
            width: parent.width            
            text: fragment
            onTextChanged: shaderMod.fragment = text
        }
        OhmButton {
            text: "Compile & Run"
            width: 100
            x: parent.width/2 - width/2
            onClicked: {
                shaderMod.renderWin.shaderSink.run(vertEdit.text, fragEdit.text);
                shaderMod.renderWin.visible = true
            }
        }
    }
    
    property var renderWin: Window {
        width: 800
        height: 600
        visible: false
        color: "black"
        onFrameSwapped: shaderSink.update()
        ShaderSink {
            id: shaderSink
            anchors.fill: parent
        }
        OhmText {
            anchors.fill: parent
            color: 'white'
            font.family: "Fantasque sans mono"
            font.pixelSize: 14           
            text: shaderSink.status
        }
        property alias shaderSink: shaderSink
    }

    exports: ({ x:'x', y:'y', vertex: 'vertex', fragment: 'fragment'})


}


