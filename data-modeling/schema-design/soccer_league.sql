--Schema Diagram for Soccer League--
--league(league_id PK, name)--
--season(season_id PK, league_id FK, start_date, end_date)--
--teams(team_id PK, name, city)--
--players(player_id PK, team_id FK, name, position)--
--matches(match_id PK, season_id FK, home_team_id FK, away_team_id FK, match_date, location, referee_id FK, home_team_score, away_team_score)--
--goals(goal_id PK, match_id FK, player_id FK, minute_scored)--
--referees(referee_id PK, name)--
--match_referee(match_id FK, referee_id FK)--

CREATE TABLE league (
    league_id SERIAL PRIMARY KEY, 
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(100)
);

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    team_id INTEGER REFERENCES teams(team_id),
    position VARCHAR(50)
);

CREATE TABLE referees (
    referee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    home_team_id INTEGER REFERENCES teams(team_id),
    away_team_id INTEGER REFERENCES teams(team_id),
    match_date DATE,
    location TEXT,
    referee_id INTEGER REFERENCES referees(referee_id),
    home_team_score INTEGER DEFAULT 0,
    away_team_score INTEGER DEFAULT 0,
    UNIQUE (home_team_id, away_team_id, match_date),
    season_id INTEGER REFERENCES seasons(season_id)
);

CREATE TABLE goals (
    goal_id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(match_id),
    player_id INTEGER REFERENCES players(player_id),
    minute_scored INTEGER  -- Time in minutes when the goal was scored --
);

CREATE TABLE seasons (
    season_id SERIAL PRIMARY KEY,
    season_name TEXT NOT NULL UNIQUE,
    league_id INTEGER REFERENCES league(league_id),
    start_date DATE,
    end_date DATE
);

CREATE TABLE match_referee (
    match_id INTEGER REFERENCES matches(match_id),
    referee_id INTEGER REFERENCES referees(referee_id),
    PRIMARY KEY (match_id, referee_id)
);