#include "Movies.h"

#include <algorithm>
#include <QVariantList>

namespace sc {

namespace {

// Development mock data for Phase 1 UI verification.
// Isolated from production provider logic; no external network requests.
const QList<QVariantMap> kMockMovies = {
    {
        {QStringLiteral("id"), QStringLiteral("mock-movie-1")},
        {QStringLiteral("media"), QStringLiteral("movie")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://movie/1")},
        {QStringLiteral("title"), QStringLiteral("Cosmic Horizon")},
        {QStringLiteral("year"), QStringLiteral("2025")},
        {QStringLiteral("runtime"), QStringLiteral("135 min")},
        {QStringLiteral("rating"), 8.6},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Sci-Fi"), QStringLiteral("Adventure")}},
        {QStringLiteral("overview"), QStringLiteral("When a deep-space observatory detects a rhythmic signal from the edge of the Kuiper belt, an international crew embarks on humanity's first interstellar rendezvous.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-movie-2")},
        {QStringLiteral("media"), QStringLiteral("movie")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://movie/2")},
        {QStringLiteral("title"), QStringLiteral("Shadows of Kyoto")},
        {QStringLiteral("year"), QStringLiteral("2024")},
        {QStringLiteral("runtime"), QStringLiteral("118 min")},
        {QStringLiteral("rating"), 8.2},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Mystery"), QStringLiteral("Thriller")}},
        {QStringLiteral("overview"), QStringLiteral("A retired detective in Kyoto is drawn into a labyrinth of hidden gardens and family secrets when an antique tea bowl vanishes from a historic estate.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-movie-3")},
        {QStringLiteral("media"), QStringLiteral("movie")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://movie/3")},
        {QStringLiteral("title"), QStringLiteral("The Clockwork Alchemist")},
        {QStringLiteral("year"), QStringLiteral("2024")},
        {QStringLiteral("runtime"), QStringLiteral("124 min")},
        {QStringLiteral("rating"), 7.9},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Fantasy"), QStringLiteral("Action")}},
        {QStringLiteral("overview"), QStringLiteral("In a steam-powered metropolis, an apprentice alchemist discovers a forbidden mechanism capable of reversing chemical reactions and altering time.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-movie-4")},
        {QStringLiteral("media"), QStringLiteral("movie")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://movie/4")},
        {QStringLiteral("title"), QStringLiteral("Neon Velocity")},
        {QStringLiteral("year"), QStringLiteral("2025")},
        {QStringLiteral("runtime"), QStringLiteral("110 min")},
        {QStringLiteral("rating"), 8.1},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Action"), QStringLiteral("Sci-Fi")}},
        {QStringLiteral("overview"), QStringLiteral("An underground hover-racing syndicate uncovers a corporate conspiracy that threatens to power down the lower residential sectors of New Babel.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    }
};

} // namespace

Movies *Movies::instance() {
    static auto *m = [] {
        auto *created = new Movies;
        QJSEngine::setObjectOwnership(created, QJSEngine::CppOwnership);
        return created;
    }();
    return m;
}

QStringList Movies::genres() const {
    return {
        QStringLiteral("Action"), QStringLiteral("Adventure"), QStringLiteral("Animation"),
        QStringLiteral("Comedy"), QStringLiteral("Crime"), QStringLiteral("Drama"),
        QStringLiteral("Fantasy"), QStringLiteral("Mystery"), QStringLiteral("Romance"),
        QStringLiteral("Sci-Fi"), QStringLiteral("Thriller")
    };
}

QString Movies::seriesId(const QString &movieId) const {
    return QStringLiteral("movie:mock:%1").arg(movieId);
}

QVariantMap Movies::seriesFor(const QVariantMap &movie) const {
    const auto id = movie.value(QStringLiteral("id")).toString();
    QVariantMap series;
    series[QStringLiteral("id")] = seriesId(id);
    series[QStringLiteral("media")] = QStringLiteral("movie");
    series[QStringLiteral("source")] = QStringLiteral("mock");
    series[QStringLiteral("sourceUrl")] = movie.value(QStringLiteral("sourceUrl"), QStringLiteral("mock://movie/") + id).toString();
    series[QStringLiteral("title")] = movie.value(QStringLiteral("title")).toString();
    series[QStringLiteral("cover")] = movie.value(QStringLiteral("cover")).toString();
    series[QStringLiteral("description")] = movie.value(QStringLiteral("overview")).toString();
    series[QStringLiteral("genres")] = movie.value(QStringLiteral("genres")).toStringList().join(QStringLiteral(", "));
    series[QStringLiteral("status")] = QStringLiteral("Released");
    series[QStringLiteral("extra")] = QVariantMap{
        {QStringLiteral("banner"), movie.value(QStringLiteral("banner"))},
        {QStringLiteral("rating"), movie.value(QStringLiteral("rating"))},
        {QStringLiteral("year"), movie.value(QStringLiteral("year"))},
        {QStringLiteral("runtime"), movie.value(QStringLiteral("runtime"))}
    };
    return series;
}

Task *Movies::home() {
    return Task::run([]() -> QVariant {
        QVariantList list;
        for (const auto &item : kMockMovies)
            list.append(item);

        QVariantMap result;
        result[QStringLiteral("spotlight")] = list;
        result[QStringLiteral("trending")] = list;
        result[QStringLiteral("popular")] = list;
        result[QStringLiteral("topRated")] = list;
        return result;
    });
}

Task *Movies::search(const QString &query, const QVariantMap &filters) {
    return Task::run([query = query.trimmed().toLower(), genre = filters.value(QStringLiteral("genre")).toString()]() -> QVariant {
        QVariantList matches;
        for (const auto &item : kMockMovies) {
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

Task *Movies::details(const QString &id) {
    return Task::run([id]() -> QVariant {
        for (const auto &item : kMockMovies) {
            if (item.value(QStringLiteral("id")).toString() == id)
                return item;
        }
        if (!kMockMovies.isEmpty())
            return kMockMovies.first();
        return QVariantMap{};
    });
}

} // namespace sc
