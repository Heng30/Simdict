import QtQml 2.12
import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    id: mainWindow

    property bool isAltOn: false

    function bingDictionary(text) {
        const bingPrefixUrl = "https://cn.bing.com/dict/search?q=";
        var url = bingPrefixUrl + text;
        https.setUrl(url);
        https.get();
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
    }

    height: 360
    width: height * 1.618
    visible: true
    flags: Qt.Dialog
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    title: qsTr("simdict")

    Rectangle {
        id: topLayout

        anchors.fill: parent
        color: "lightblue"

        Keys.onEscapePressed: {
            mainWindow.hide();
            mainWindow.requestActivate();
        }
        Keys.onTabPressed: {
            textInput.selectAll();
            textInput.focus = true;
        }
        Keys.onReleased: isAltOn = false

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
                height: parent.height;
                focus: true
                clip: true
                font.pixelSize: 25
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                onEditingFinished: bingDictionary(text)
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

        Connections {
            function onAlt4S() {
                mainWindow.hide();
                mainWindow.x = (Screen.desktopAvailableWidth - width) / 2;
                mainWindow.y = (Screen.desktopAvailableHeight - height) / 2;
                textInput.selectAll();
                mainWindow.show();
            }

            target: gsf
        }

        Connections {
            function onAlt4A() {
                mainWindow.hide();
                mainWindow.x = (Screen.desktopAvailableWidth - width) / 2;
                mainWindow.y = (Screen.desktopAvailableHeight - height) / 2;
                textInput.selectAll();
                textInput.paste();
                mainWindow.show();
            }

            target: gsf
        }

        Connections {
            function onAlt4Z() {
                process.xclip_o_sel();
            }

            target: gsf
        }

        Connections {
            function onXclip_o_sel_finished() {
                mainWindow.hide();
                mainWindow.x = (Screen.desktopAvailableWidth - width) / 2;
                mainWindow.y = (Screen.desktopAvailableHeight - height) / 2;
                textInput.text = word;
                textInput.editingFinished();
                mainWindow.show();
            }

            target: process
        }

        Shortcut {
            sequence: "Ctrl+Q"
            context: Qt.ApplicationShortcut
            onActivated: Qt.quit()
        }

    }

}
