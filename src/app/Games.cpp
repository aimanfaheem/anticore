#include "Games.h"

#include <algorithm>
#include <QVariantList>

namespace sc {

namespace {

// Development mock data for Phase 1 UI verification.
// Isolated from production provider logic; no external network requests or process execution.
const QList<QVariantMap> kMockGames = {
    {
        {QStringLiteral("id"), QStringLiteral("mock-game-1")},
        {QStringLiteral("media"), QStringLiteral("game")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://game/1")},
        {QStringLiteral("title"), QStringLiteral("Echoes of the Void")},
        {QStringLiteral("year"), QStringLiteral("2025")},
        {QStringLiteral("developer"), QStringLiteral("Aetheria Studios")},
        {QStringLiteral("publisher"), QStringLiteral("Nova Interactive")},
        {QStringLiteral("platforms"), QStringList{QStringLiteral("PC"), QStringLiteral("PlayStation 5"), QStringLiteral("Xbox Series X")}},
        {QStringLiteral("rating"), 9.2},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Action RPG"), QStringLiteral("Sci-Fi")}},
        {QStringLiteral("description"), QStringLiteral("A high-fidelity space exploration RPG featuring vast planetary ecosystems, orbital combat, and ancient planetary secrets.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-game-2")},
        {QStringLiteral("media"), QStringLiteral("game")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://game/2")},
        {QStringLiteral("title"), QStringLiteral("Runeforge Chronicles")},
        {QStringLiteral("year"), QStringLiteral("2024")},
        {QStringLiteral("developer"), QStringLiteral("Ironwood Forge")},
        {QStringLiteral("publisher"), QStringLiteral("Indie Arc")},
        {QStringLiteral("platforms"), QStringList{QStringLiteral("PC"), QStringLiteral("Nintendo Switch")}},
        {QStringLiteral("rating"), 8.7},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Metroidvania"), QStringLiteral("Fantasy")}},
        {QStringLiteral("description"), QStringLiteral("A hand-crafted 2D action platformer set in a crumbling dwarven forge deep within the crystalline heart of a mountain.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-game-3")},
        {QStringLiteral("media"), QStringLiteral("game")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://game/3")},
        {QStringLiteral("title"), QStringLiteral("Cyberpunk Syndicate")},
        {QStringLiteral("year"), QStringLiteral("2024")},
        {QStringLiteral("developer"), QStringLiteral("Matrix Softworks")},
        {QStringLiteral("publisher"), QStringLiteral("Neon Guild")},
        {QStringLiteral("platforms"), QStringList{QStringLiteral("PC"), QStringLiteral("PlayStation 5")}},
        {QStringLiteral("rating"), 8.4},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Tactical Strategy"), QStringLiteral("Cyberpunk")}},
        {QStringLiteral("description"), QStringLiteral("Isometric squad-based tactics where corporate espionage operatives deploy stealth, hacking, and cyberware in neon-lit alleys.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    },
    {
        {QStringLiteral("id"), QStringLiteral("mock-game-4")},
        {QStringLiteral("media"), QStringLiteral("game")},
        {QStringLiteral("source"), QStringLiteral("mock")},
        {QStringLiteral("sourceUrl"), QStringLiteral("mock://game/4")},
        {QStringLiteral("title"), QStringLiteral("Wanderer's Odyssey")},
        {QStringLiteral("year"), QStringLiteral("2025")},
        {QStringLiteral("developer"), QStringLiteral("Sunlit Games")},
        {QStringLiteral("publisher"), QStringLiteral("Frontier Arts")},
        {QStringLiteral("platforms"), QStringList{QStringLiteral("PC"), QStringLiteral("PlayStation 5"), QStringLiteral("Xbox Series X"), QStringLiteral("Nintendo Switch")}},
        {QStringLiteral("rating"), 8.9},
        {QStringLiteral("genres"), QStringList{QStringLiteral("Open World"), QStringLiteral("Adventure")}},
        {QStringLiteral("description"), QStringLiteral("A serene open-world journey following a nomadic glider traversing ancient cloud kingdoms and wind-swept ruins.")},
        {QStringLiteral("cover"), QString()},
        {QStringLiteral("banner"), QString()}
    }
};

} // namespace

Games *Games::instance() {
    static auto *g = [] {
        auto *created = new Games;
        QJSEngine::setObjectOwnership(created, QJSEngine::CppOwnership);
        return created;
    }();
    return g;
}

QStringList Games::genres() const {
    return {
        QStringLiteral("Action RPG"), QStringLiteral("Adventure"), QStringLiteral("Cyberpunk"),
        QStringLiteral("Fantasy"), QStringLiteral("Metroidvania"), QStringLiteral("Open World"),
        QStringLiteral("Puzzle"), QStringLiteral("Sci-Fi"), QStringLiteral("Shooter"),
        QStringLiteral("Strategy"), QStringLiteral("Tactical Strategy")
    };
}

QStringList Games::platforms() const {
    return {
        QStringLiteral("PC"), QStringLiteral("PlayStation 5"),
        QStringLiteral("Xbox Series X"), QStringLiteral("Nintendo Switch")
    };
}

QString Games::seriesId(const QString &gameId) const {
    return QStringLiteral("game:mock:%1").arg(gameId);
}

QVariantMap Games::seriesFor(const QVariantMap &game) const {
    const auto id = game.value(QStringLiteral("id")).toString();
    QVariantMap map;
    map[QStringLiteral("id")] = seriesId(id);
    map[QStringLiteral("media")] = QStringLiteral("game");
    map[QStringLiteral("source")] = QStringLiteral("mock");
    map[QStringLiteral("sourceUrl")] = game.value(QStringLiteral("sourceUrl"), QStringLiteral("mock://game/") + id).toString();
    map[QStringLiteral("title")] = game.value(QStringLiteral("title")).toString();
    map[QStringLiteral("cover")] = game.value(QStringLiteral("cover")).toString();
    map[QStringLiteral("description")] = game.value(QStringLiteral("description")).toString();
    map[QStringLiteral("genres")] = game.value(QStringLiteral("genres")).toStringList().join(QStringLiteral(", "));
    map[QStringLiteral("status")] = QStringLiteral("Released");
    map[QStringLiteral("extra")] = QVariantMap{
        {QStringLiteral("banner"), game.value(QStringLiteral("banner"))},
        {QStringLiteral("rating"), game.value(QStringLiteral("rating"))},
        {QStringLiteral("year"), game.value(QStringLiteral("year"))},
        {QStringLiteral("developer"), game.value(QStringLiteral("developer"))},
        {QStringLiteral("publisher"), game.value(QStringLiteral("publisher"))},
        {QStringLiteral("platforms"), game.value(QStringLiteral("platforms"))}
    };
    return map;
}

Task *Games::home() {
    return Task::run([]() -> QVariant {
        QVariantList list;
        for (const auto &item : kMockGames)
            list.append(item);

        QVariantMap result;
        result[QStringLiteral("spotlight")] = list;
        result[QStringLiteral("popular")] = list;
        result[QStringLiteral("topRated")] = list;
        result[QStringLiteral("recent")] = list;
        return result;
    });
}

Task *Games::search(const QString &query, const QVariantMap &filters) {
    return Task::run([query = query.trimmed().toLower(), genre = filters.value(QStringLiteral("genre")).toString(), platform = filters.value(QStringLiteral("platform")).toString()]() -> QVariant {
        QVariantList matches;
        for (const auto &item : kMockGames) {
            const auto title = item.value(QStringLiteral("title")).toString().toLower();
            const auto genres = item.value(QStringLiteral("genres")).toStringList();
            const auto platforms = item.value(QStringLiteral("platforms")).toStringList();

            bool matchesQuery = query.isEmpty() || title.contains(query);
            bool matchesGenre = genre.isEmpty() || genres.contains(genre, Qt::CaseInsensitive);
            bool matchesPlatform = platform.isEmpty() || platforms.contains(platform, Qt::CaseInsensitive);

            if (matchesQuery && matchesGenre && matchesPlatform)
                matches.append(item);
        }

        QVariantMap result;
        result[QStringLiteral("results")] = matches;
        result[QStringLiteral("hasNextPage")] = false;
        return result;
    });
}

Task *Games::details(const QString &id) {
    return Task::run([id]() -> QVariant {
        for (const auto &item : kMockGames) {
            if (item.value(QStringLiteral("id")).toString() == id)
                return item;
        }
        if (!kMockGames.isEmpty())
            return kMockGames.first();
        return QVariantMap{};
    });
}

} // namespace sc
