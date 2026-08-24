import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Effects
import SddmComponents 2.0

Rectangle {
  id: root
  width: 2560
  height: 1600
  color: "#101010"

  property date now: new Date()
  property int selectedSession: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
  property string loginUser: userModel.lastUser ||
    (userModel.count > 0 ? userModel.data(userModel.index(0, 0), Qt.UserRole + 1) : "")

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  Image {
    anchors.fill: parent
    source: "background.png"
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
  }

  Rectangle {
    anchors.fill: parent
    color: "#30000000"
  }

  Column {
    width: Math.min(570, parent.width - 64)
    spacing: 4
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -70

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: Qt.formatTime(root.now, "h:mm AP")
      color: "#ffffff"
      font.family: "Inter"
      font.pixelSize: 104
      font.weight: Font.Light
      style: Text.Raised
      styleColor: "#35000000"
    }

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: Qt.formatDate(root.now, "dddd, MMMM d")
      color: "#e8ffffff"
      font.family: "Inter"
      font.pixelSize: 20
    }

    Item {
      width: 1
      height: 22
    }

    Row {
      spacing: 14
      anchors.horizontalCenter: parent.horizontalCenter

      Rectangle {
        id: avatarFrame
        width: 60
        height: 60
        radius: 30
        color: "#d9101010"
        border.width: 2
        border.color: "#bfffffff"

        Image {
          id: avatarSource
          anchors.fill: parent
          anchors.margins: 2
          source: "avatar.jpg"
          fillMode: Image.PreserveAspectCrop
          sourceSize: Qt.size(112, 112)
          visible: false
        }

        Item {
          id: avatarMask
          anchors.fill: avatarSource
          visible: false
          layer.enabled: true

          Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "white"
          }
        }

        MultiEffect {
          anchors.fill: avatarSource
          source: avatarSource
          maskEnabled: true
          maskSource: avatarMask
        }
      }

      Rectangle {
        width: 370
        height: 60
        radius: 13
        color: "#dc101010"
        border.width: 1
        border.color: password.activeFocus ? "#ffc799" : "#80ffffff"

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 18
          anchors.verticalCenter: parent.verticalCenter
          text: "●"
          color: password.activeFocus ? "#ffc799" : "#b8ffffff"
          font.pixelSize: 11
        }

        QQC2.TextField {
          id: password
          anchors.left: parent.left
          anchors.leftMargin: 42
          anchors.right: submitButton.left
          anchors.rightMargin: 4
          anchors.verticalCenter: parent.verticalCenter
          height: parent.height
          placeholderText: "Password"
          placeholderTextColor: "#8fffffff"
          echoMode: TextInput.Password
          focus: true
          color: "#ffffff"
          selectionColor: "#ffc799"
          selectedTextColor: "#101010"
          font.family: "Inter"
          font.pixelSize: 16
          background: Item {}
          onAccepted: submitButton.clicked()
          Keys.onEscapePressed: text = ""
        }

        QQC2.Button {
          id: submitButton
          width: 52
          height: parent.height
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          enabled: root.loginUser.length > 0
          contentItem: Text {
            text: "↵"
            color: submitButton.down ? "#ea83a5" : "#ffffff"
            font.family: "Inter"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
          background: Item {}
          onClicked: {
            errorMessage.text = ""
            sddm.login(root.loginUser, password.text, root.selectedSession)
          }
        }
      }
    }

    Text {
      id: errorMessage
      width: parent.width
      height: 26
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      color: "#f5a191"
      font.family: "Inter"
      font.pixelSize: 13
      text: ""
    }
  }

  Text {
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.margins: 28
    text: "Niri"
    color: "#b8ffffff"
    font.family: "Inter"
    font.pixelSize: 14
  }

  QQC2.Button {
    id: powerButton
    width: 48
    height: 48
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 22
    contentItem: Text {
      text: "⏻"
      color: powerButton.down ? "#ea83a5" : "#d8ffffff"
      font.pixelSize: 22
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
      radius: 24
      color: powerButton.hovered ? "#70101010" : "transparent"
    }
    onClicked: sddm.powerOff()
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
