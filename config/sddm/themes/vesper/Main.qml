import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
  id: root
  width: 2560
  height: 1600
  color: "#101010"

  property int selectedUser: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
  property int selectedSession: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

  Image {
    anchors.fill: parent
    source: "background.png"
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
  }

  Rectangle {
    anchors.fill: parent
    color: "#990b0b0b"
  }

  Rectangle {
    width: Math.min(500, parent.width - 40)
    height: 610
    anchors.centerIn: parent
    radius: 24
    color: "#e6101010"
    border.width: 1
    border.color: "#3fffffff"
  }

  Column {
    width: Math.min(420, parent.width - 64)
    spacing: 18
    anchors.centerIn: parent

    Image {
      width: 112
      height: 112
      anchors.horizontalCenter: parent.horizontalCenter
      source: userModel.count > 0 ? userModel.data(userModel.index(root.selectedUser, 0), Qt.UserRole + 4) : ""
      fillMode: Image.PreserveAspectCrop
      sourceSize: Qt.size(width, height)
      layer.enabled: true
    }

    Label {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: userModel.count > 0 ? userModel.data(userModel.index(root.selectedUser, 0), Qt.UserRole + 1) : "Welcome"
      color: "#ffffff"
      font.family: "JetBrains Mono"
      font.pixelSize: 24
    }

    ComboBox {
      id: userBox
      width: parent.width
      model: userModel
      textRole: "name"
      currentIndex: root.selectedUser
      onCurrentIndexChanged: root.selectedUser = currentIndex
    }

    TextField {
      id: password
      width: parent.width
      placeholderText: "Password"
      echoMode: TextInput.Password
      focus: true
      color: "#ffffff"
      font.family: "JetBrains Mono"
      font.pixelSize: 16
      implicitHeight: 54
      leftPadding: 18
      rightPadding: 18
      background: Rectangle {
        radius: 12
        color: "#e6191919"
        border.width: 1
        border.color: password.activeFocus ? "#ea83a5" : "#3fffffff"
      }
      onAccepted: loginButton.clicked()
      Keys.onEscapePressed: text = ""
    }

    Label {
      id: errorMessage
      width: parent.width
      visible: text.length > 0
      horizontalAlignment: Text.AlignHCenter
      color: "#f5a191"
      font.family: "JetBrains Mono"
      text: ""
    }

    Button {
      id: loginButton
      width: parent.width
      text: "Sign in"
      enabled: userModel.count > 0
      implicitHeight: 54
      contentItem: Text {
        text: loginButton.text
        color: "#101010"
        font.family: "JetBrains Mono"
        font.pixelSize: 16
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
      background: Rectangle {
        radius: 12
        color: loginButton.down ? "#e29eca" : "#ea83a5"
      }
      onClicked: {
        errorMessage.text = ""
        sddm.login(userBox.currentText, password.text, root.selectedSession)
      }
    }

    ComboBox {
      width: parent.width
      model: sessionModel
      textRole: "name"
      currentIndex: root.selectedSession
      onCurrentIndexChanged: root.selectedSession = currentIndex
    }
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      password.text = ""
      password.forceActiveFocus()
      errorMessage.text = "Authentication failed"
    }
  }
}
