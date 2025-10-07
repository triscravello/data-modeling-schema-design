--Schema Diagram for Soccer League--
--league(league_id PK, name)--
--season(season_id PK, league_id FK, start_date, end_date)--
--teams(team_id PK, name, city)--
--players(player_id PK, team_id FK, name, position)--
--matches(match_id PK, season_id FK, home_team_id FK, away_team_id FK, match_date, location, referee_id FK, home_team_score, away_team_score)--
--goals(goal_id PK, match_id FK, player_id FK, minute_scored)--
--referees(referee_id PK, name)--
--match_referee(match_id FK, referee_id FK)--

DROP DATABASE IF EXISTS soccer_league;
CREATE DATABASE soccer_league;
\c soccer_league;

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
    team_id INTEGER REFERENCES teams(team_id) ON DELETE CASCADE,
    position VARCHAR(50)
);

CREATE TABLE referees (
    referee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE seasons (
    season_id SERIAL PRIMARY KEY,
    season_name TEXT NOT NULL UNIQUE,
    league_id INTEGER REFERENCES league(league_id) ON DELETE CASCADE,
    start_date DATE,
    end_date DATE
);

CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    season_id INTEGER REFERENCES seasons(season_id) ON DELETE CASCADE,
    home_team_id INTEGER REFERENCES teams(team_id) ON DELETE CASCADE,
    away_team_id INTEGER REFERENCES teams(team_id) ON DELETE CASCADE,
    match_date DATE NOT NULL,
    location TEXT,
    home_team_score INTEGER DEFAULT 0,
    away_team_score INTEGER DEFAULT 0,
    UNIQUE (home_team_id, away_team_id, match_date)
);

CREATE TABLE goals (
    goal_id SERIAL PRIMARY KEY,
    match_id INTEGER REFERENCES matches(match_id),
    player_id INTEGER REFERENCES players(player_id) ON DELETE SET NULL,
    minute_scored INTEGER  -- Time in minutes when the goal was scored --
);

CREATE TABLE match_referee (
    match_id INTEGER REFERENCES matches(match_id) ON DELETE CASCADE,
    referee_id INTEGER REFERENCES referees(referee_id) ON DELETE CASCADE,
    PRIMARY KEY (match_id, referee_id)
);

CREATE OR REPLACE FUNCTION check_player_team()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM matches m 
        JOIN players p ON (p.team_id = m.home_team_id OR p.team_id = m.away_team_id)
        WHERE m.match_id = NEW.match_id AND p.player_id = NEW.player_id
    ) THEN
        RAISE EXCEPTION 'Player % does not belong to either team in match %', NEW.player_id, NEW.match_id;
        END IF;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_goal_player
BEFORE INSERT ON goals
FOR EACH ROW EXECUTE FUNCTION check_player_team();

ALTER TABLE matches
ADD COLUMN created_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON matches
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Indexes for performance optimization --
CREATE INDEX idx_players_team ON players(team_id);
CREATE INDEX idx_matches_season ON matches(season_id);
CREATE INDEX idx_matches_home_team ON matches(home_team_id);
CREATE INDEX idx_matches_away_team ON matches(away_team_id);
CREATE INDEX idx_goals_match ON goals(match_id);
CREATE INDEX idx_goals_player ON goals(player_id);
CREATE INDEX idx_match_refeee_match ON match_referee(match_id);
CREATE INDEX idx_match_referee_referee ON match_referee(referee_id);
CREATE INDEX idx_seasons_league ON seasons(league_id);
CREATE INDEX idx_teams_name ON teams(name); -- For searching by team name --
CREATE INDEX idx_players_name ON players(name); -- For searching by player name --
CREATE INDEX idx_referees_name ON referees(name); -- For searching by referee name --
CREATE INDEX idx_matches_date ON matches(match_date); -- For sorting/filtering by match date --
CREATE INDEX idx_seasons_dates ON seasons(start_date, end_date); -- For filtering by season

-- Sample data insertion --
INSERT INTO league (name) VALUES ('Premier League'), ('La Liga'), ('Bundesliga');
INSERT INTO teams (name, city) VALUES ('Manchester United', 'Manchester'), ('Real Madrid', 'Madrid'), ('Bayern Munich', 'Munich');
INSERT INTO players (name, team_id, position) VALUES ('Cristiano Ronaldo', 1, 'Forward'), ('Sergio
Ramos', 2, 'Defender'), ('Robert Lewandowski', 3, 'Forward');
INSERT INTO referees (name) VALUES ('Michael Oliver'), ('Antonio Mateu Lahoz'), ('Felix Brych');
INSERT INTO seasons (season_name, league_id, start_date, end_date) VALUES ('2023/2024', 1, '2023-08-01', '2024-05-31');
INSERT INTO matches (season_id, home_team_id, away_team_id, match_date, location) VALUES (1, 1, 2, '2023-09-15', 'Old Trafford');
INSERT INTO goals (match_id, player_id, minute_scored) VALUES (1, 1, 23), (1, 2, 45);
INSERT INTO match_referee (match_id, referee_id) VALUES (1, 1);
