import QtQuick
import QtQuick.Controls.Basic
import Scancore

// TV Series Details: backdrop, seasons picker, episodes list with mock metadata, and library tracking.
// Phase 1 UI shell using SCANCORE's native components.
Item {
    id: page

    property string seriesId: ""
    property var summary: ({})
    property bool autoResume: false

    property var detailsTask: seriesId.length > 0 ? Series.details(seriesId) : null
    readonly property var series: detailsTask && detailsTask.ok ? detailsTask.result : summary
    readonly property string libraryId: Series.seriesId(seriesId.length > 0 ? seriesId : (summary.id || ""))
    readonly property bool saved: Library.isSaved(libraryId)
    readonly property var progress: Library.progressMap(libraryId)

    property int currentSeason: 1
    readonly property int totalSeasons: series.seasons || 1
    property var episodesTask: Series.episodes(seriesId.length > 0 ? seriesId : summary.id, currentSeason)
    readonly property var episodes: episodesTask && episodesTask.ok ? episodesTask.result : []

    onCurrentSeasonChanged: {
        episodesTask = Series.episodes(seriesId.length > 0 ? seriesId : summary.id, currentSeason)
    }

    function toggleSaved() {
        if (saved) {
            Library.remove(libraryId)
        } else {
            const seriesObj = Series.seriesFor(series)
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
                    source: App.image(series.banner || series.cover || "")
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

                // Series Info over Banner
                Row {
                    x: Theme.gutter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 16
                    width: parent.width - 2 * Theme.gutter
                    spacing: 20

                    Cover {
                        width: Theme.compact ? 100 : 130
                        height: Theme.compact ? 150 : 195
                        source: series.cover || ""
                        radius: Theme.radiusMd
                    }

                    Column {
                        width: parent.width - (Theme.compact ? 120 : 150)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text {
                            text: series.title || ""
                            color: Theme.text
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.compact ? Theme.textXl : Theme.text2xl
                            font.weight: Font.Bold
                            wrapMode: Text.Wrap
                            width: parent.width
                        }

                        Row {
                            spacing: 12
                            visible: !!series.year || !!series.rating || !!series.seasons

                            Text {
                                visible: !!series.year
                                text: series.year || ""
                                color: Theme.textMuted
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                            }

                            Text {
                                visible: !!series.seasons
                                text: series.seasons + (series.seasons === 1 ? qsTr(" Season") : qsTr(" Seasons"))
                                color: Theme.textMuted
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                            }

                            Text {
                                visible: !!series.status
                                text: series.status || ""
                                color: Theme.accent
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                                font.weight: Font.Medium
                            }

                            Text {
                                visible: !!series.rating
                                text: "★ " + Number(series.rating).toFixed(1)
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
                                model: series.genres || []
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

                ScButton {
                    text: qsTr("Watch")
                    iconName: "play"
                    variant: "primary"
                    onClicked: Router.toast(qsTr("Series playback will be enabled in a future phase."), "info")
                }

                IconButton {
                    iconName: Library.isFavourite(page.libraryId) ? "heart" : "heart"
                    iconColor: Library.isFavourite(page.libraryId) ? Theme.accent : Theme.textMuted
                    tip: qsTr("Favourite")
                    onClicked: Library.setFavourite(page.libraryId, !Library.isFavourite(page.libraryId))
                }
            }

            // Synopsis
            Column {
                x: Theme.gutter
                width: parent.width - 2 * Theme.gutter
                spacing: 8
                visible: !!series.overview

                Text {
                    text: qsTr("Overview")
                    color: Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.textLg
                    font.weight: Font.DemiBold
                }

                Text {
                    text: series.overview || ""
                    color: Theme.textMuted
                    font.family: Theme.fontSans
                    font.pixelSize: Theme.textMd
                    wrapMode: Text.Wrap
                    width: parent.width
                    lineHeight: 1.4
                }
            }

            // Season Selection & Episodes List
            Column {
                x: Theme.gutter
                width: parent.width - 2 * Theme.gutter
                spacing: 16

                Row {
                    width: parent.width
                    spacing: 16

                    Text {
                        text: qsTr("Episodes")
                        color: Theme.text
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.textLg
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Season Selector Chips
                    Flickable {
                        width: parent.width - 120
                        height: 36
                        contentWidth: seasonRow.implicitWidth
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        Row {
                            id: seasonRow
                            spacing: 8
                            Repeater {
                                model: page.totalSeasons
                                delegate: Chip {
                                    required property int index
                                    readonly property int sNum: index + 1
                                    text: qsTr("Season ") + sNum
                                    selected: page.currentSeason === sNum
                                    onClicked: page.currentSeason = sNum
                                }
                            }
                        }
                    }
                }

                // Episodes Column
                Column {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: page.episodes
                        delegate: Rectangle {
                            id: epCard
                            required property var modelData
                            required property int index
                            width: parent.width
                            height: 72
                            radius: Theme.radiusMd
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 14

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: Theme.surface2
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        anchors.centerIn: parent
                                        text: String(epCard.modelData.number || (epCard.index + 1))
                                        color: Theme.textMuted
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.textSm
                                        font.weight: Font.Bold
                                    }
                                }

                                Column {
                                    width: parent.width - 110
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        text: epCard.modelData.title || (qsTr("Episode ") + (epCard.index + 1))
                                        color: Theme.text
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.textMd
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: epCard.modelData.overview || ""
                                        color: Theme.textMuted
                                        font.family: Theme.fontSans
                                        font.pixelSize: Theme.textXs
                                        elide: Text.ElideRight
                                        width: parent.width
                                        maximumLineCount: 1
                                    }
                                }

                                IconButton {
                                    iconName: "play"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: Router.toast(qsTr("Series playback will be enabled in a future phase."), "info")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
