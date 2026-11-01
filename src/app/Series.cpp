#include "Series.h"

#include <algorithm>
#include <QVariantList>

namespace sc {

namespace {

// Development mock data for Phase 1 UI verification.
// Isolated from production provider logic; no external network requests.
const QList<QVariantMap> kMockSeries = {
    {
        {QStringLiteral("id"), QStringLiteral("mock-series-1")},
        {QStringLiteral("media"), QStringLiteral("series")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://series/1")},
        {QStringLiteral("title"), QStringLiteral("Chronicles of the Fringe")},
        {QStringLiteral("year"), QStringLiteral("2024")},
        {QStringLiteral("status"), QStringLiteral("Returning Series")},
        {QStringLiteral("seasons"), 2},
        {QStringLiteral("episodesCount"), 20},
        {QStringLiteral("rating"), 8.8},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Sci-Fi"), QStringLiteral("Mystery")}},
        {QStringLiteral("overview"), QStringLiteral("Border patrol specialists stationed along an electromagnetic perimeter investigate dimensional fissures leaking forgotten technology into the badlands.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-series-2")},
        {QStringLiteral("media"), QStringLiteral("series")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://series/2")},
        {QStringLiteral("title"), QStringLiteral("The Silent Kingdom")},
        {QStringLiteral("year"), QStringLiteral("2023")},
        {QStringLiteral("status"), QStringLiteral("Completed")},
        {QStringLiteral("seasons"), 3},
        {QStringLiteral("episodesCount"), 24},
        {QStringLiteral("rating"), 8.5},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Fantasy"), QStringLiteral("Drama")}},
        {QStringLiteral("overview"), QStringLiteral("An ancient monarchy grapples with a mysterious phenomenon where royal bloodlines lose their speech upon inheriting the throne.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-series-3")},
        {QStringLiteral("media"), QStringLiteral("series")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://series/3")},
        {QStringLiteral("title"), QStringLiteral("Midnight Protocol")},
        {QStringLiteral("year"), QStringLiteral("2025")},
        {QStringLiteral("status"), QStringLiteral("Returning Series")},
        {QStringLiteral("seasons"), 1},
        {QStringLiteral("episodesCount"), 10},
        {QStringLiteral("rating"), 8.3},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Crime"), QStringLiteral("Thriller")}},
        {QStringLiteral("overview"), QStringLiteral("A specialized cyber-forensics taskforce unravels autonomous AI systems manipulating high-frequency financial markets.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-series-4")},
        {QStringLiteral("media"), QStringLiteral("series")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://series/4")},
        {QStringLiteral("title"), QStringLiteral("Starlight Station")},
        {QStringLiteral("year"), QStringLiteral("2024")},
        {QStringLiteral("status"), QStringLiteral("In Production")},
        {QStringLiteral("seasons"), 1},
        {QStringLiteral("episodesCount"), 8},
        {QStringLiteral("rating"), 8.0},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Comedy"), QStringLiteral("Sci-Fi")}},
        {QStringLiteral("overview"), QStringLiteral("The quirky misadventures of the eccentric maintenance crew keeping a rundown orbital refueling depot operational.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    }
};

} // namespace

Series *Series::instance() {
    static auto *s = [] {
        auto *created = new Series;
        QJSEngine::setObjectOwnership(created, QJSEngine::CppOwnership);
        return created;
    }();
    return s;
}

QStringList Series::genres() const {
    return {
        QStringLiteral("Action & Adventure"), QStringLiteral("Animation"), QStringLiteral("Comedy"),
        QStringLiteral("Crime"), QStringLiteral("Documentary"), QStringLiteral("Drama"),
        QStringLiteral("Family"), QStringLiteral("Mystery"), QStringLiteral("Sci-Fi & Fantasy")
    };
}

QString Series::seriesId(const QString &seriesId) const {
    return QStringLiteral("series:mock:%1").arg(seriesId);
}

QVariantMap Series::seriesFor(const QVariantMap &series) const {
    const auto id = series.value(QStringLiteral("id")).toString();
    QVariantMap map;
    map[QStringLiteral("id")] = seriesId(id);
    map[QStringLiteral("media")] = QStringLiteral("series");
    map[QStringLiteral("source")] = QStringLiteral("mock");
    map[QStringLiteral("sourceUrl")] = series.value(QStringLiteral("sourceUrl"), QStringLiteral("mock://series/") + id).toString();
    map[QStringLiteral("title")] = series.value(QStringLiteral("title")).toString();
    map[QStringLiteral("cover")] = series.value(QStringLiteral("cover")).toString();
    map[QStringLiteral("description")] = series.value(QStringLiteral("overview")).toString();
    map[QStringLiteral("genres")] = series.value(QStringLiteral("genres")).toStringList().join(QStringLiteral(", "));
    map[QStringLiteral("status")] = series.value(QStringLiteral("status"), QStringLiteral("Ongoing")).toString();
    map[QStringLiteral("extra")] = QVariantMap{
        {QStringLiteral("banner"), series.value(QStringLiteral("banner"))},
        {QStringLiteral("rating"), series.value(QStringLiteral("rating"))},
        {QStringLiteral("year"), series.value(QStringLiteral("year"))},
        {QStringLiteral("seasons"), series.value(QStringLiteral("seasons"))}
    };
    return map;
}

Task *Series::home() {
    return Task::run([]() -> QVariant {
        QVariantList list;
        for (const auto &item : kMockSeries)
            list.append(item);

        QVariantMap result;
        result[QStringLiteral("spotlight")] = list;
        result[QStringLiteral("trending")] = list;
        result[QStringLiteral("popular")] = list;
        result[QStringLiteral("topRated")] = list;
        return result;
    });
}

Task *Series::search(const QString &query, const QVariantMap &filters) {
    return Task::run([query = query.trimmed().toLower(), genre = filters.value(QStringLiteral("genre")).toString()]() -> QVariant {
        QVariantList matches;
        for (const auto &item : kMockSeries) {
            const auto title = item.value(QStringLiteral("title")).toString().toLower();
            const auto genres = item.value(QStringLiteral("genres")).toStringList();

            bool matchesQuery = query.isEmpty() || title.contains(query);
            bool matchesGenre = genre.isEmpty() || genres.contains(genre, Qt::CaseInsensitive);

            if (matchesQuery && matchesGenre)
                matches.append(item);
        }

        QVariantMap result;
        result[QStringLiteral("results")] = matches;
        result[QStringLiteral("hasNextPage")] = false;
        return result;
    });
}

Task *Series::details(const QString &id) {
    return Task::run([id]() -> QVariant {
        for (const auto &item : kMockSeries) {
            if (item.value(QStringLiteral("id")).toString() == id)
                return item;
        }
        if (!kMockSeries.isEmpty())
            return kMockSeries.first();
        return QVariantMap{};
    });
}

Task *Series::episodes(const QString &id, int season) {
    return Task::run([id, season]() -> QVariant {
        QVariantList epList;
        // Generate mock episodes for UI display
        for (int i = 1; i <= 8; ++i) {
            QVariantMap ep;
            ep[QStringLiteral("key")] = QStringLiteral("s%1e%2").arg(season).arg(i);
            ep[QStringLiteral("number")] = i;
            ep[QStringLiteral("season")] = season;
            ep[QStringLiteral("title")] = QStringLiteral("Episode %1").arg(i);
            ep[QStringLiteral("overview")] = QStringLiteral("Season %1 episode %2: key narrative progression and character developments.").arg(season).arg(i);
            ep[QStringLiteral("image")] = QString();
            epList.append(ep);
        }
        return epList;
    });
}

} // namespace sc
