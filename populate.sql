-- Token Insertion
INSERT INTO Token (TokenID, TokenName) 
VALUES
    (1, 'Mortarboard'),
    (2, 'Book'),
    (3, 'Certificate'),
    (4, 'Gown'),
    (5, 'Laptop'),
    (6, 'Pen')
;

-- Player Insertion
INSERT INTO Player (PlayerID, PlayerName, TokenID) 
VALUES
    (1, 'Gareth', 3),
    (2, 'Uli', 1),
    (3, 'Pradyumn', 2),
    (4, 'Ruth', 6)
;

-- LocationType Insertion
INSERT INTO LocationType (TypeID, TypeName) 
VALUES
    (1, 'Corner'),
    (2, 'Hearing'),
    (3, 'RAG'),
    (4, 'Building');

-- Location Insertion
INSERT INTO Location (LocationID, LocationName, TypeID, TuitionFee) 
VALUES
    (1, 'welcome_week', 1, 100),
    (2, 'kilburn', 4, -15),
    (3, 'it', 4, -15),
    (4, 'hearing_1', 2, -20),
    (5, 'uni_place', 4, -25),
    (6, 'ambs', 4, -25),
    (7, 'rag_1', 3, 15),
    (8, 'suspension', 1, 0),
    (9, 'crawford', 4, -30),
    (10, 'sugden', 4, -30),
    (11, 'ali_g', 1, 0),
    (12, 'shopping_precinct', 4, -35),
    (13, 'mecd', 4, -35),
    (14, 'rag_2', 3, -30),
    (15, 'library', 4, -40),
    (16, 'sam_alex', 4, -40),
    (17, 'hearing_2', 2, -25),
    (18, 'youre_suspended', 1, 0),
    (19, 'museum', 4, -50),
    (20, 'whitworth_hall', 4, -50)
;	

-- Colour Insertion
INSERT INTO Colour(ColourID, ColourName) 
VALUES
    (1, 'Green'),
    (2, 'Orange'),
    (3, 'Blue'),
    (4, 'Brown'),
    (5, 'Grey'),
    (6, 'Black')
;

-- BuildingOwnership Insertion
INSERT INTO BuildingOwnership(LocationID, OwnerID, ColourID) 
VALUES
    (2, 4, 1),
    (3, 1, 1),
    (5, 1, 2),
    (6, 2, 2),
    (9, 3, 3),
    (10, 1, 3),
	(12, NULL, 4),
    (13, 2, 4),
    (15, 3, 5),
	(16, NULL, 5),
    (19, 3, 6),
    (20, 4, 6)
;

-- GameRounds Insertion for Initial State
INSERT INTO GameRound (GameRoundID, SpecialCondition) 
VALUES
	(0, NULL)
 ;

-- AuditLog Insertion
INSERT INTO AuditLog (LogID, PlayerID, GameRoundID, RollValue, CreditBalance, LocationID) 
VALUES
    (1, 1, 0, 0, 345, 19),
    (2, 2, 0, 0, 590, 2),
    (3, 3, 0, 0, 465, 6),
    (4, 4, 0, 0, 360, 4)
;