#pragma once

#include "core/Task.h"

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>

namespace sc {

// Series & Television service: manages TV series metadata, seasons, and episodes.
// Phase 1 provides clean, isolated development mock data. Real scrapers and
// streaming providers will be introduced in subsequent phases.
class Series : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    static Series *instance();
    static Series *create(QQmlEngine *, QJSEngine *) { return instance(); }

    Q_INVOKABLE QStringList genres() const;

    // Featured shelves: { spotlight, trending, popular, topRated }
    Q_INVOKABLE sc::Task *home();

    // Search and filter: { results: [...], hasNextPage: false }
    Q_INVOKABLE sc::Task *search(const QString &query, const QVariantMap &filters = {});

    // Full series details: title, overview, year, status, seasons, genres, rating
    Q_INVOKABLE sc::Task *details(const QString &id);

    // Episodes for a given season: [{ number, title, overview, key }, ...]
    Q_INVOKABLE sc::Task *episodes(const QString &id, int season = 1);

    // Library row representation for a series
    Q_INVOKABLE QVariantMap seriesFor(const QVariantMap &series) const;
    Q_INVOKABLE QString seriesId(const QString &seriesId) const;
};

} // namespace sc
