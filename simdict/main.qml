import QtQml 2.12
import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    property bool isAltOn: false

    id: mainWindow
    width: 700
    height: 500
    visible: true
    flags: Qt.Dialog
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    title: qsTr("Simdict")

    Rectangle {
        id: topLayout
        anchors.fill: parent
        color: "lightblue"
        border.color: "lightgreen"
        border.width: 3
        radius: 10

        Rectangle {
            id: textLayout
            anchors.top: topLayout.top
            anchors.left: topLayout.left
            anchors.right: topLayout.right
            anchors.topMargin: 5
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 5
            width: parent.width - 10
            height: 35
            radius: 10
            color: "white"

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
                leftPadding: 10
                rightPadding: 5
                bottomPadding: 5
                width: parent.width - searchIcon.width - aboutIcon.width - leftPadding - rightPadding
                focus: true
                font.pixelSize: 25
                selectByMouse: true
                horizontalAlignment : TextInput.AlignVCenter
                onEditingFinished: bingDictionary(text)
            }

            Image {
                    id: aboutIcon
                    anchors.right: parent.right
                    width: parent.height
                    height: parent.height
                    source: "qrc:/image/about.png"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var text = '<h1>simdict v1.1.0</h1>'
                            text += '<p></p>'
                            text += '<b>'
                            text += '<p>Author: Heng</p>'
                            text += '<p>Blog: heng30.space</p>'
                            text += '<p>Email: 2238288979@qq.com</P>'
                            text += '<p>Github: github.com/Heng30/simdict</p>'
                            text += '<p>Dogecoin: D8Ng7dd7uT3fQ3eD33biyRfiULntb6CTu3</p>'
                            text += '</b>'
                            outputText.text = text
                        }
                    }
                }
        }

        Rectangle {
            id: output
            anchors.top: textLayout.bottom
            anchors.bottom: topLayout.bottom
            anchors.left: topLayout.left
            anchors.right: topLayout.right
            anchors.topMargin: 10
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            anchors.bottomMargin: 5
            width: parent.width - 10
            height: mainWindow.height - textLayout.height - 20
            radius: 10
            color: "#FFFFCC"

            TextEdit {
                id: outputText
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 30
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.bottomMargin: 10
                font.pixelSize: 22
                readOnly: true
                wrapMode: Text.Wrap
                textFormat: TextEdit.RichText
                selectByMouse: true
                mouseSelectionMode: TextEdit.SelectCharacters
            }
        }

        Connections {
            target: https
            function onGetContent(content) {
                parseHtml(content)
            }
        }

        Connections {
            target: gsf
            function onAlt4S() {
                mainWindow.hide()
                mainWindow.x = (Screen.desktopAvailableWidth - width) / 2
                mainWindow.y = (Screen.desktopAvailableHeight - height) / 2
                textInput.selectAll()
                mainWindow.show()
            }
        }

        Connections {
            target: gsf
            function onAlt4A() {
                mainWindow.hide()
                mainWindow.x = (Screen.desktopAvailableWidth - width) / 2
                mainWindow.y = (Screen.desktopAvailableHeight - height) / 2
                textInput.selectAll()
                textInput.paste()
                mainWindow.show()
             }
        }

        Connections {
            target: gsf
            function onAlt4Z() {
                process.xclip_o_sel();
             }
        }

        Connections {
            target: process
            function onXclip_o_sel_finished() {
                mainWindow.hide()
                mainWindow.x = (Screen.desktopAvailableWidth - width) / 2
                mainWindow.y = (Screen.desktopAvailableHeight - height) / 2
                textInput.text = word;
                textInput.editingFinished();
                mainWindow.show()
            }
        }

        Keys.onEscapePressed: {
            mainWindow.hide()
            mainWindow.requestActivate()
        }

        Keys.onTabPressed: {
            textInput.selectAll()
            textInput.focus = true;
        }

        Keys.onReleased: isAltOn = false;

        Shortcut {
             sequence: "Ctrl+Q"
             context: Qt.ApplicationShortcut
             onActivated: Qt.quit()
        }
    }

    function bingDictionary(text) {
        const bingPrefixUrl = "https://cn.bing.com/dict/clientsearch?mkt=zh-CN&setLang=zh"
                                + "&form=BDVEHC&ClientVer=BDDTV3.5.1.4320&q=";
        var url = bingPrefixUrl + text;
        https.setUrl(url);
        https.get();
    }

    // TOFIX: ugly
    function parseHtml(content) {
        var html = content.toString();
        var sp = 'ClientPartCall.IAddNewWord';
        var ep = '"></div>';

        var list1 = html.split(sp);
        if (list1.length < 2) {
            outputText.text = "No Data";
            return;
        }

        var list2 = list1[1].split(ep);
        if (list2.length < 1) {
            outputText.text = "No Data";
            return;
        }

        // (this,'apple','[ˈæp(ə)l] ', 'n. 苹果公司； web. 苹果电脑')
        var data = list2[0].slice(1, -1);
        while (true) {
            var tmp = data;
            data = data.replace("'", "");
            data = data.replace("\\", "");
            if (tmp === data) break;
        }

        var list3 = data.split(',');
        if (list3.length < 2) {
            outputText.text = "No Data";
            return;
        }

        var word = list3[1];
        var pronunciation = list3.length > 3 ? list3[2] : '';
        var translation = list3[list3.length - 1];
        var types = ['web.', 'adj.', 'adv.', 'abbr.', 'n.', 'v.'];
        var typesIndex = [-1, -1, -1, -1, -1, -1];
        var typesTrans = [];

        for (var i = 0; i < types.length; i++) {
            var pos = translation.indexOf(types[i]);
            if (pos > 0 && translation[pos-1] === 'd') continue; // mismatch v. between adv.
            if (pos >= 0 && typesIndex[i] === -1) typesIndex[i] = pos;
        }

        typesIndex.sort(function(a, b) {
            if (a > b) return 1;
            else if (b > a) return -1;
            else return 0;
        });

        for (var j = 0; j < typesIndex.length; j++) {
            if (typesIndex[j] < 0) continue;
            var s = typesIndex[j];
            var e = j < typesIndex.length - 1 ? typesIndex[j+1] : translation.length;
            var t = translation.substring(s, e).trim();
            if (t[t.length-1] === ';') t = t.substring(0, t.length-1);
            typesTrans.push(t);
        }

        var text = `<h1><b>${word}</b></h1>`;
        text += '<p></p>';
        text += '<b>';
        if (pronunciation.length > 0)
            text += `<p>${pronunciation}</p>`;

        for (var k = 0; k < typesTrans.length; k++)
            text += `<p>${typesTrans[k]}</p>`;

        text += '<b>'
        outputText.text = text;
    }
}
