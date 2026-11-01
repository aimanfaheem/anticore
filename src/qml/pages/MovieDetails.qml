import QtQuick
import QtQuick.Controls.Basic
import Scancore

// Movie Details: poster, backdrop, synopsis, runtime, rating, and library tracking.
// Phase 1 UI shell using SCANCORE's native components.
Item {
    id: page

    property string movieId: ""
    property var summary: ({})
    property bool autoResume: false

    property var detailsTask: movieId.length > 0 ? Movies.details(movieId) : null
    readonly property var movie: detailsTask && detailsTask.ok ? detailsTask.result : summary
    readonly property string seriesId: Movies.seriesId(movieId.length > 0 ? movieId : (summary.id || ""))
    readonly property bool saved: Library.isSaved(seriesId)
    readonly property var progress: Library.progressMap(seriesId)

    function toggleSaved() {
        if (saved) {
            Library.remove(seriesId)
        } else {
            const seriesObj = Movies.seriesFor(movie)
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

            // Header Banner Backdrop
            Item {
                width: parent.width
                height: Theme.compact ? 280 : 380

                Image {
                    anchors.fill: parent
                    source: App.image(movie.banner || movie.cover || "")
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

                // Back Button
                IconButton {
                    x: Theme.gutter
                    y: 16
                    iconName: "arrow-left"
                    tip: qsTr("Back")
                    onClicked: Router.back()
                }

                // Movie Info Floating over Bottom of Banner
                Row {
                    x: Theme.gutter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 16
                    width: parent.width - 2 * Theme.gutter
                    spacing: 20

                    // Poster
                    Cover {
                        width: Theme.compact ? 100 : 130
                        height: Theme.compact ? 150 : 195
                        source: movie.cover || ""
                        radius: Theme.radiusMd
                    }

                    Column {
                        width: parent.width - (Theme.compact ? 120 : 150)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text {
                            text: movie.title || ""
                            color: Theme.text
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.compact ? Theme.textXl : Theme.text2xl
                            font.weight: Font.Bold
                            wrapMode: Text.Wrap
                            width: parent.width
                        }

                        Row {
                            spacing: 12
                            visible: !!movie.year || !!movie.rating || !!movie.runtime

                            Text {
                                visible: !!movie.year
                                text: movie.year || ""
                                color: Theme.textMuted
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                            }

                            Text {
                                visible: !!movie.runtime
                                text: movie.runtime || ""
                                color: Theme.textMuted
                                font.family: Theme.fontSans
                                font.pixelSize: Theme.textSm
                            }

                            Text {
                                visible: !!movie.rating
                                text: "★ " + Number(movie.rating).toFixed(1)
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
                                model: movie.genres || []
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
                    text: qsTr("Watch Movie")
                    iconName: "play"
                    variant: "primary"
                    onClicked: Router.toast(qsTr("Movie streaming will be enabled in a future phase."), "info")
                }

                IconButton {
                    iconName: Library.isFavourite(page.seriesId) ? "heart" : "heart"
                    iconColor: Library.isFavourite(page.seriesId) ? Theme.accent : Theme.textMuted
                    tip: qsTr("Favourite")
                    onClicked: Library.setFavourite(page.seriesId, !Library.isFavourite(page.seriesId))
                }
            }

            // Synopsis
            Column {
                x: Theme.gutter
                width: parent.width - 2 * Theme.gutter
                spacing: 8
                visible: !!movie.overview

                Text {
                    text: qsTr("Overview")
                    color: Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.textLg
                    font.weight: Font.DemiBold
                }

                Text {
                    text: movie.overview || ""
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
