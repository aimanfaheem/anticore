#pragma once

#include "core/Task.h"

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>

namespace sc {

// Movies section service: manages movie metadata and shell navigation.
// Phase 1 provides clean, isolated development mock data. Real scrapers and
// streaming providers will be introduced in subsequent phases.
class Movies : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    static Movies *instance();
    static Movies *create(QQmlEngine *, QJSEngine *) { return instance(); }

    Q_INVOKABLE QStringList genres() const;

    // Returns featured movie shelves: { spotlight, trending, popular, topRated }
    Q_INVOKABLE sc::Task *home();

    // Search and filter: { results: [...], hasNextPage: false }
    Q_INVOKABLE sc::Task *search(const QString &query, const QVariantMap &filters = {});

    // Full movie details: title, overview, year, runtime, genres, rating
    Q_INVOKABLE sc::Task *details(const QString &id);

    // Library row representation for a movie
    Q_INVOKABLE QVariantMap seriesFor(const QVariantMap &movie) const;
    Q_INVOKABLE QString seriesId(const QString &movieId) const;
};

} // namespace sc
