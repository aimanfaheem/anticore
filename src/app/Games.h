#pragma once

#include "core/Task.h"

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>

namespace sc {

// Video Games service: manages game catalog metadata, platforms, and library entries.
// Phase 1 provides clean, isolated development mock data. Real scrapers,
// sync systems, and launchers will be introduced in subsequent phases.
class Games : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    static Games *instance();
    static Games *create(QQmlEngine *, QJSEngine *) { return instance(); }

    Q_INVOKABLE QStringList genres() const;
    Q_INVOKABLE QStringList platforms() const;

    // Featured game shelves: { spotlight, popular, topRated, recent }
    Q_INVOKABLE sc::Task *home();

    // Search and filter: { results: [...], hasNextPage: false }
    Q_INVOKABLE sc::Task *search(const QString &query, const QVariantMap &filters = {});

    // Full game details: title, description, developer, publisher, release year, platforms, rating
    Q_INVOKABLE sc::Task *details(const QString &id);

    // Library row representation for a game
    Q_INVOKABLE QVariantMap seriesFor(const QVariantMap &game) const;
    Q_INVOKABLE QString seriesId(const QString &gameId) const;
};

} // namespace sc
