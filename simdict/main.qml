import QtQml 2.12
import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    id: mainWindow

    function bingDictionary(text) {
        const bingPrefixUrl = "https://cn.bing.com/dict/search?q=";
        var url = bingPrefixUrl + text;
        https.setUrl(url);
        https.get();
    }

    function log(content) {
        var sp = 'text-indent:0px;">';
        var ep = '</p></body></html>';
        var list1 = content.split(sp);
        if (list1.length < 2)
            return ;

        var list2 = list1[1].split(ep);
        if (list2.length < 1)
            return ;

        console.log(list2[0]);
    }

    function parseHtml(content) {
        var html = content.toString();
        var sp = '<meta name="description" content="';
        var ep = '" />';
        var list1 = html.split(sp);
        if (list1.length < 2) {
            outputText.text = "No Data";
            return ;
        }
        var list2 = list1[1].split(ep);
        if (list2.length < 1) {
            outputText.text = "No Data";
            return ;
        }
        outputText.text = list2[0];
        log(outputText.text);
    }

    Component.onCompleted: {
        const content = https.getSearchContent();
        if (content != "")
            bingDictionary(content);

    }
    height: 360
    width: height * 1.618
    visible: true
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    title: qsTr("simdict")

    Rectangle {
        id: topLayout

        anchors.fill: parent
        color: "lightblue"
        Keys.onEscapePressed: {
            Qt.quit();
        }
        Keys.onTabPressed: {
            textInput.selectAll();
            textInput.focus = true;
        }

        Rectangle {
            id: textLayout

            anchors.top: topLayout.top
            anchors.left: topLayout.left
            width: parent.width - anchors.margins * 2
            height: 35
            anchors.margins: 2

            Image {
                id: searchIcon

                anchors.left: parent.left
                width: parent.height
                height: parent.height
                source: "qrc:/image/search.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: textInput.editingFinished()
                }

            }

            TextInput {
                id: textInput

                anchors.left: searchIcon.right
                anchors.right: parent.right
                height: parent.height
                focus: true
                clip: true
                font.pixelSize: 25
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                onEditingFinished: bingDictionary(text)
                text: https.getSearchContent()
            }

        }

        Rectangle {
            id: output

            anchors.top: textLayout.bottom
            anchors.bottom: topLayout.bottom
            anchors.left: topLayout.left
            anchors.right: topLayout.right
            anchors.margins: 2
            width: parent.width - anchors.margins * 2
            height: mainWindow.height - textLayout.height - anchors.margins * 2
            color: "#FFFFCC"

            TextEdit {
                id: outputText

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 25
                font.pixelSize: 24
                readOnly: true
                wrapMode: Text.Wrap
                textFormat: TextEdit.RichText
                selectByMouse: true
                mouseSelectionMode: TextEdit.SelectCharacters
            }

        }

        Connections {
            function onGetContent(content) {
                parseHtml(content);
            }

            target: https
        }

        Shortcut {
            sequence: "Ctrl+Q"
            context: Qt.ApplicationShortcut
            onActivated: Qt.quit()
        }

    }

}
