import QtQuick
import QtQuick.Controls.Basic
import Scancore

// Game Details: banner, cover, developer, publisher, platforms, rating, genres, and library tracking.
// Phase 1 UI shell using SCANCORE's native components.
Item {
    id: page

    property string gameId: ""
    property var summary: ({})

    property var detailsTask: gameId.length > 0 ? Games.details(gameId) : null
    readonly property var game: detailsTask && detailsTask.ok ? detailsTask.result : summary
    readonly property string libraryId: Games.seriesId(gameId.length > 0 ? gameId : (summary.id || ""))
    readonly property bool saved: Library.isSaved(libraryId)

    function toggleSaved() {
        if (saved) {
            Library.remove(libraryId)
        } else {
            const seriesObj = Games.seriesFor(game)
            Library.save(seriesObj, "reading")
        }
    }

    SmoothFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + 80

        Column {
            id: column
            width: parent.width
            spacing: 24

            // Header Banner
            Item {
                width: parent.width
                height: Theme.compact ? 280 : 380

                Image {
                    anchors.fill: parent
                    source: App.image(game.banner || game.cover || "")
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.alpha(Theme.base, 0.4) }
                        GradientStop { position: 0.7; color: Theme.alpha(Theme.base, 0.8) }
                        GradientStop { position: 1.0; color: Theme.base }
                    }
                }

                IconButton {
                    x: Theme.gutter
                    y: 16
                    iconName: "arrow-left"
                    tip: qsTr("Back")
                    onClicked: Router.back()
                }

                // Game Info over Banner
                Row {
                    x: Theme.gutter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 16
                    width: parent.width - 2 * Theme.gutter
                    spacing: 20

                    Cover {
                        width: Theme.compact ? 100 : 130
                        height: Theme.compact ? 150 : 195
                        source: game.cover || ""
                        radius: Theme.radiusMd
                    }

                    Column {
                        width: parent.width - (Theme.compact ? 120 : 150)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text {
                            text: game.title || ""
                            color: Theme.text
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.compact ? Theme.textXl : Theme.text2xl
                            font.weight: Font.Bold
                            wrapMode: Text.Wrap
                            width: parent.width
                        }

                        Row {
                            spacing: 12
                            visible: !!game.year || !!game.rating

                            Text {
                                visible: !!game.year
                                text: game.year || ""
                                color: Theme.textMuted
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                            }

                            Text {
                                visible: !!game.developer
                                text: game.developer || ""
                                color: Theme.textMuted
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                            }

                            Text {
                                visible: !!game.rating
                                text: "★ " + Number(game.rating).toFixed(1)
                                color: "#f59e0b"
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                                font.weight: Font.Bold
                            }
                        }

                        // Genres
                        Flow {
                            width: parent.width
                            spacing: 6
                            Repeater {
                                model: game.genres || []
                                delegate: Chip {
                                    required property string modelData
                                    text: modelData
                                    compact: true
                                }
                            }
                        }
                    }
                }
            }

            // Action Buttons Row
            Row {
                x: Theme.gutter
                width: parent.width - 2 * Theme.gutter
                spacing: 12

                ScButton {
                    text: page.saved ? qsTr("In Library") : qsTr("Add to Library")
                    iconName: page.saved ? "check" : "bookmark-plus"
                    variant: page.saved ? "ghost" : "secondary"
                    onClicked: page.toggleSaved()
                }

                IconButton {
                    iconName: Library.isFavourite(page.libraryId) ? "heart" : "heart"
                    iconColor: Library.isFavourite(page.libraryId) ? Theme.accent : Theme.textMuted
                    tip: qsTr("Favourite")
                    onClicked: Library.setFavourite(page.libraryId, !Library.isFavourite(page.libraryId))
                }
            }

            // Platforms Shelf
            Column {
                x: Theme.gutter
                width: parent.width - 2 * Theme.gutter
                spacing: 8
                visible: (game.platforms || []).length > 0

                Text {
                    text: qsTr("Platforms")
                    color: Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.textLg
                    font.weight: Font.DemiBold
                }

                Flow {
                    width: parent.width
                    spacing: 8
                    Repeater {
                        model: game.platforms || []
                        delegate: Rectangle {
                            required property string modelData
                            width: platText.implicitWidth + 20
                            height: 32
                            radius: Theme.radiusSm
                            color: Theme.surface2
                            border.width: 1
                            border.color: Theme.border

                            Text {
                                id: platText
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: Theme.text
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }

            // Metadata: Developer / Publisher
            Row {
                x: Theme.gutter
                width: parent.width - 2 * Theme.gutter
                spacing: 32
                visible: !!game.developer || !!game.publisher

                Column {
                    visible: !!game.developer
                    spacing: 4
                    Text {
                        text: qsTr("Developer")
                        color: Theme.textMuted
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.textXs
                    }
                    Text {
                        text: game.developer || ""
                        color: Theme.text
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.textSm
                        font.weight: Font.Medium
                    }
                }

                Column {
                    visible: !!game.publisher
                    spacing: 4
                    Text {
                        text: qsTr("Publisher")
                        color: Theme.textMuted
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.textXs
                    }
                    Text {
                        text: game.publisher || ""
                        color: Theme.text
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.textSm
                        font.weight: Font.Medium
                    }
                }
            }

            // Description
            Column {
                x: Theme.gutter
                width: parent.width - 2 * Theme.gutter
                spacing: 8
                visible: !!game.description

                Text {
                    text: qsTr("About")
                    color: Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.textLg
                    font.weight: Font.DemiBold
                }

                Text {
                    text: game.description || ""
                    color: Theme.textMuted
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.textMd
                    wrapMode: Text.Wrap
                    width: parent.width
                    lineHeight: 1.4
                }
            }
        }
    }
}
