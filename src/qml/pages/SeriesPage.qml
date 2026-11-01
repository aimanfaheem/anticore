import QtQuick
import QtQuick.Controls.Basic
import Scancore

// Series & TV Shows home: spotlight hero, continue watching, categories, trending, popular, and top rated TV series.
Item {
    id: page

    property var homeTask: Series.home()
    property var historyTask: Library.continueItems("series", 16)
    readonly property var home: homeTask && homeTask.ok ? homeTask.result : null
    readonly property var spotlight: home ? (home.spotlight || home.trending || []).filter(m => m.banner).slice(0, 6) : []
    property int spot: 0

    property string searchQuery: ""
    property string selectedGenre: ""
    property var searchTask: null

    function search(text) {
        searchQuery = text
        if (text.trim().length > 0) {
            searchTask = Series.search(text, {})
        } else {
            searchTask = null
        }
    }

    function selectGenre(genre) {
        if (selectedGenre === genre) selectedGenre = ""
        else selectedGenre = genre

        if (selectedGenre.length > 0) {
            searchTask = Series.search("", { genre: selectedGenre })
        } else if (searchQuery.length > 0) {
            searchTask = Series.search(searchQuery, {})
        } else {
            searchTask = null
        }
    }

    property bool libraryStale: false
    onVisibleChanged: if (visible && libraryStale) { libraryStale = false; refresh.restart() }
    Connections {
        target: Library
        function onChanged() { if (page.visible) refresh.restart(); else page.libraryStale = true }
    }
    Timer { id: refresh; interval: 500; onTriggered: page.historyTask = Library.continueItems("series", 16) }
    property var history: []
    Connections {
        target: page.historyTask
        function onFinished() { page.history = Router.keepTask(page.history, page.historyTask) }
    }

    Timer {
        id: slideTimer
        interval: 6500
        running: page.visible && page.spotlight.length > 1
        repeat: true
        onTriggered: page.spot = (page.spot + 1) % page.spotlight.length
    }

    SmoothFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + 60

        Column {
            id: column
            width: parent.width
            spacing: Theme.sectionGap

            // Spotlight Hero
            Item {
                id: hero
                width: parent.width
                height: Theme.compact ? 320 : 440
                visible: page.spotlight.length > 0 && searchTask === null

                Item {
                    id: heroArt
                    anchors.fill: parent
                    clip: true

                    Repeater {
                        model: page.spotlight
                        delegate: Item {
                            id: slide
                            required property var modelData
                            required property int index
                            readonly property bool current: index === page.spot
                            anchors.fill: parent
                            opacity: current ? 1 : 0
                            visible: opacity > 0
                            Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }

                            Image {
                                anchors.fill: parent
                                source: App.image(slide.modelData.banner)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Theme.alpha(Theme.base, 0.95) }
                            GradientStop { position: 0.55; color: Theme.alpha(Theme.base, 0.45) }
                            GradientStop { position: 1.0; color: Theme.alpha(Theme.base, 0.1) }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.5; color: "transparent" }
                            GradientStop { position: 1.0; color: Theme.base }
                        }
                    }
                }

                Column {
                    readonly property var currentSeries: page.spotlight[page.spot] || null
                    x: Theme.gutter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 28
                    width: Math.min(parent.width - 2 * Theme.gutter, 600)
                    spacing: 12

                    Text {
                        text: parent.currentSeries ? parent.currentSeries.title : ""
                        color: Theme.text
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.compact ? Theme.textXl : Theme.text3xl
                        font.weight: Font.Bold
                        wrapMode: Text.Wrap
                        width: parent.width
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Text {
                        text: parent.currentSeries ? parent.currentSeries.overview : ""
                        color: Theme.textMuted
                        font.family: Theme.fontSans
                        font.pixelSize: Theme.textSm
                        wrapMode: Text.Wrap
                        width: parent.width
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }

                    Row {
                        spacing: 12
                        ScButton {
                            text: qsTr("Watch Now")
                            iconName: "play"
                            onClicked: if (parent.parent.currentSeries) Router.openSeries(parent.parent.currentSeries, null)
                        }
                        ScButton {
                            text: qsTr("Episodes")
                            iconName: "list"
                            variant: "ghost"
                            onClicked: if (parent.parent.currentSeries) Router.openSeries(parent.parent.currentSeries, null)
                        }
                    }
                }
            }

            // Search Bar & Filter Row
            Item {
                width: parent.width
                height: searchRow.implicitHeight + 12

                Column {
                    id: searchRow
                    x: Theme.gutter
                    width: parent.width - 2 * Theme.gutter
                    spacing: 12

                    Row {
                        width: parent.width
                        spacing: 12

                        SearchField {
                            width: Theme.compact ? parent.width : 340
                            placeholderText: qsTr("Search TV series...")
                            onSubmitted: (text) => page.search(text)
                            onTextChanged: if (text.trim().length === 0 && page.searchQuery.length > 0) page.search("")
                        }

                        ScButton {
                            visible: !Theme.compact && page.searchTask !== null
                            text: qsTr("Clear Search")
                            iconName: "x"
                            variant: "ghost"
                            onClicked: { page.searchQuery = ""; page.selectedGenre = ""; page.searchTask = null }
                        }
                    }

                    // Genre chips row
                    Flickable {
                        width: parent.width
                        height: 38
                        contentWidth: genreRow.implicitWidth
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        Row {
                            id: genreRow
                            spacing: 8
                            Repeater {
                                model: Series.genres()
                                delegate: Chip {
                                    required property string modelData
                                    text: modelData
                                    selected: page.selectedGenre === modelData
                                    onClicked: page.selectGenre(modelData)
                                }
                            }
                        }
                    }
                }
            }

            // Search Results Grid
            Column {
                visible: page.searchTask !== null
                width: parent.width
                spacing: 16

                Text {
                    x: Theme.gutter
                    text: page.selectedGenre.length > 0 ? qsTr("Genre: ") + page.selectedGenre : qsTr("Results for “%1”").arg(page.searchQuery)
                    color: Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.textXl
                    font.weight: Font.DemiBold
                }

                CoverGrid {
                    items: page.searchTask && page.searchTask.ok ? page.searchTask.result.results : []
                    loading: page.searchTask ? page.searchTask.loading : false
                    onOpened: (it, cover) => Router.openSeries(it, cover)
                }
            }

            // Continue Watching Shelf
            Shelf {
                visible: page.searchTask === null && page.history.length > 0
                title: qsTr("Continue Watching")
                items: page.history
                loading: page.historyTask ? page.historyTask.loading && page.history.length === 0 : false
                subtitleFor: (it) => qsTr("Episode ") + (it.unitNumber || it.unitKey || "")
                progressFor: (it) => it.completed ? 1 : (it.percent || 0)
                onOpened: (it, cover) => Router.openSeries(it, cover)
            }

            // Trending Series Shelf
            Shelf {
                visible: page.searchTask === null
                title: qsTr("Trending Series")
                items: page.home ? page.home.trending : []
                loading: page.homeTask ? page.homeTask.loading : false
                error: page.homeTask && !page.homeTask.loading ? page.homeTask.error : ""
                subtitleFor: (it) => it.year || ""
                onOpened: (it, cover) => Router.openSeries(it, cover)
            }

            // Popular TV Shows Shelf
            Shelf {
                visible: page.searchTask === null
                title: qsTr("Popular Shows")
                items: page.home ? page.home.popular : []
                loading: page.homeTask ? page.homeTask.loading : false
                subtitleFor: (it) => it.year || ""
                onOpened: (it, cover) => Router.openSeries(it, cover)
            }

            // Airing Today Shelf
            Shelf {
                visible: page.searchTask === null
                title: qsTr("Airing Today")
                items: page.home ? page.home.airingToday : []
                loading: page.homeTask ? page.homeTask.loading : false
                subtitleFor: (it) => qsTr("New Episode Today")
                onOpened: (it, cover) => Router.openSeries(it, cover)
            }

            // Top Rated Shows Shelf
            Shelf {
                visible: page.searchTask === null
                title: qsTr("Top Rated Shows")
                items: page.home ? page.home.topRated : []
                loading: page.homeTask ? page.homeTask.loading : false
                subtitleFor: (it) => (it.rating ? "★ " + Number(it.rating).toFixed(1) : "")
                onOpened: (it, cover) => Router.openSeries(it, cover)
            }
        }
    }
}
