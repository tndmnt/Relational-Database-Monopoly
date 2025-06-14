-- Token Table Creation
CREATE TABLE Token(
    TokenID INTEGER PRIMARY KEY AUTOINCREMENT,
    TokenName TEXT NOT NULL
);

-- Player Table Creation
CREATE TABLE Player (
    PlayerID INTEGER PRIMARY KEY AUTOINCREMENT,
    PlayerName TEXT NOT NULL,
    TokenID INTEGER NOT NULL,
    FOREIGN KEY (TokenID) REFERENCES Token(TokenID)
);

-- LocationType Table Creation
CREATE TABLE LocationType (
    TypeID INTEGER PRIMARY KEY AUTOINCREMENT,
    TypeName TEXT NOT NULL
);

-- Location Table Creation
CREATE TABLE Location (
    LocationID INTEGER PRIMARY KEY AUTOINCREMENT,
    LocationName TEXT NOT NULL,  
    TypeID INTEGER NOT NULL,
    TuitionFee INTEGER DEFAULT 0,
    FOREIGN KEY (TypeID) REFERENCES LocationType(TypeID)
);

-- Colour Table Creation
CREATE TABLE Colour (
    ColourID INTEGER PRIMARY KEY AUTOINCREMENT,
    ColourName TEXT NOT NULL
);
	
-- BuildingOwnership Table
CREATE TABLE BuildingOwnership (
    LocationID INTEGER PRIMARY KEY NOT NULL,
    OwnerID INTEGER DEFAULT NULL,
    ColourID INTEGER NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID),
    FOREIGN KEY (OwnerID) REFERENCES Player(PlayerID),
    FOREIGN KEY (ColourID) REFERENCES Colour(ColourID)
);

-- GameRound Table Creation
CREATE TABLE GameRound (
    GameRoundID INTEGER PRIMARY KEY AUTOINCREMENT,
    SpecialCondition TEXT DEFAULT NULL
);

-- AuditLog Table Creation
CREATE TABLE AuditLog (
    LogID INTEGER PRIMARY KEY AUTOINCREMENT,
    PlayerID INTEGER NOT NULL,
    GameRoundID INTEGER NOT NULL,
    RollValue INTEGER DEFAULT 0,
    CreditBalance INTEGER NOT NULL CHECK (CreditBalance >= 0),
    LocationID INTEGER NOT NULL,
    FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
    FOREIGN KEY (GameRoundID) REFERENCES GameRound(GameRoundID),
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- Trigger for player table, to limit number of players up to 6
CREATE TRIGGER limit_player_count
BEFORE INSERT ON Player
BEGIN
    SELECT CASE 
        WHEN (SELECT COUNT(*) FROM Player) >= 6 THEN
            RAISE(ABORT, 'Cannot insert more than 6 players.')
    END;
END;