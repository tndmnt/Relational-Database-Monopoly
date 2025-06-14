-- GameRoundID = 1, PlayerID = 1, RollValue = 4

-- Ensure GameRoundID 1 exists
INSERT OR IGNORE INTO GameRound (GameRoundID, SpecialCondition)
VALUES
	(1, NULL)
;

-- Standardize TuitionFee values to be positive
UPDATE Location SET TuitionFee = ABS(TuitionFee);

-- Step 1: Calculate the player's new state and insert into AuditLog

-- 1st CTE: CurrentState
WITH 
CurrentState AS (
	SELECT
		AuditLog.CreditBalance,
		AuditLog.LocationID,
		1 AS PlayerID,
		4 AS RollValue
	FROM AuditLog
	WHERE AuditLog.PlayerID = 1
	ORDER BY AuditLog.LogID DESC
	LIMIT 1
),
-- 2nd CTE: NewLocation
NewLocation AS (
	SELECT
		CASE
			WHEN (CurrentState.LocationID + CurrentState.RollValue) > 20
				THEN (CurrentState.LocationID + CurrentState.RollValue) - 20
			ELSE CurrentState.LocationID + CurrentState.RollValue
		END AS NewLocationID,
		CurrentState.*
	FROM CurrentState
),
-- 3rd CTE: LocationDetails
LocationDetails AS (
	SELECT
		NewLocation.*,
		Location.TypeID,
		Location.TuitionFee,
		Location.LocationName
	FROM NewLocation
	JOIN Location
	ON Location.LocationID = NewLocation.NewLocationID
),
-- 4th CTE: BuildingDetails
BuildingDetails AS (
	SELECT
		LocationDetails.*,
		BuildingOwnership.OwnerID AS BuildingOwnerID,
		BuildingOwnership.ColourID
	FROM LocationDetails
	LEFT JOIN BuildingOwnership
	ON BuildingOwnership.LocationID = LocationDetails.NewLocationID
),
-- 5th CTE: PassesWelcomeWeek
PassesWelcomeWeek AS (
	SELECT
		*,
		CASE
			WHEN (LocationID + RollValue) > 20
				THEN 1
			ELSE 0
		END AS PassesWelcomeWeek
	FROM BuildingDetails
),
-- 6th CTE: SpecialConditions
SpecialConditions AS (
	SELECT
		*,
		CASE
			WHEN NewLocationID = 18
				THEN 1
			ELSE 0
		END AS LandsOnSuspension,
		CASE
			WHEN NewLocationID = 8
				THEN 1
			ELSE 0
		END AS LandsOnSuspensionLocation
	FROM PassesWelcomeWeek
),
-- 7th CTE: OwnerProperties
OwnerProperties AS (
	SELECT
		SpecialConditions.*,
		CASE
			WHEN SpecialConditions.TypeID = 4
				AND SpecialConditions.BuildingOwnerID IS NOT NULL
				AND SpecialConditions.BuildingOwnerID != PlayerID
					THEN
						CASE
							WHEN
								(SELECT COUNT(*)
								FROM BuildingOwnership
								WHERE BuildingOwnership.OwnerID = SpecialConditions.BuildingOwnerID
									AND BuildingOwnership.ColourID = SpecialConditions.ColourID)
								=
								(SELECT COUNT(*)
								FROM BuildingOwnership
								WHERE BuildingOwnership.ColourID = SpecialConditions.ColourID)
									THEN 1
							ELSE 0
						END
			ELSE 0
		END AS OwnerOwnsAllColour
	FROM SpecialConditions
),
-- 8th CTE: CreditCalculations
CreditCalculations AS (
	SELECT
		*,
		-- Welcome Week Credit
		CASE
			WHEN PassesWelcomeWeek = 1
				THEN 100
			ELSE 0
		END AS WelcomeWeekCredit,
		-- Tuition Fee Credit (what the player pays or receives)
		CASE
			WHEN LandsOnSuspension = 1
				THEN 0
			WHEN RollValue = 6
				THEN 0 -- No effect when rolling a 6
			WHEN TypeID = 2 -- 'Hearing'
				THEN -TuitionFee
			WHEN NewLocationID = 7
				THEN TuitionFee
			WHEN NewLocationID = 14
				THEN -TuitionFee
			WHEN TypeID = 4
				AND BuildingOwnerID IS NULL
					THEN -2 * TuitionFee -- Buying unowned building
			WHEN TypeID = 4
				AND BuildingOwnerID = PlayerID
					THEN 0 -- Landing on own building
			WHEN TypeID = 4
				AND BuildingOwnerID != PlayerID
					THEN
						CASE
							WHEN OwnerOwnsAllColour = 1
								THEN -2 * TuitionFee -- Paying double tuition fee
							ELSE -TuitionFee  -- Paying tuition fee
						END
			ELSE 0
		END AS TuitionFeeCredit,
		-- Amount to be credited to the owner
		0 AS OwnerReceivesCredit -- Placeholder, will compute separately
	FROM OwnerProperties
),
-- 9th CTE: FinalCalculations
FinalCalculations AS (
    SELECT
        *,
        (CreditBalance + WelcomeWeekCredit + TuitionFeeCredit) AS NewCreditBalance
    FROM CreditCalculations
)
-- Insert into AuditLog
INSERT INTO AuditLog (PlayerID, GameRoundID, RollValue, CreditBalance, LocationID)
SELECT
    PlayerID,
    1 AS GameRoundID,
    RollValue,
    CASE
        WHEN (RollValue != 6
	        AND LandsOnSuspensionLocation = 1)
		        THEN CreditBalance -- No change
        WHEN (RollValue = 6)
	        THEN CreditBalance -- No change
        ELSE NewCreditBalance
    END AS CreditBalance,
    CASE
        WHEN LandsOnSuspension = 1
	        THEN 8 -- Move to 'Suspension' location
        ELSE NewLocationID
    END AS LocationID
FROM FinalCalculations
;

-- Step 2: Update BuildingOwnership if the player buys an unowned building

UPDATE BuildingOwnership
SET OwnerID = 1
WHERE OwnerID IS NULL
  AND LocationID = (
    SELECT AuditLog.LocationID
    FROM AuditLog
    JOIN Location
    ON Location.LocationID = AuditLog.LocationID
    LEFT JOIN BuildingOwnership
    ON BuildingOwnership.LocationID = AuditLog.LocationID
    WHERE AuditLog.PlayerID = 1
      AND AuditLog.LogID = (
	      SELECT MAX(LogID)
	      FROM AuditLog
	      WHERE PlayerID = 1)
      AND AuditLog.RollValue != 6
      AND Location.TypeID = 4
      AND BuildingOwnership.OwnerID IS NULL
);

-- Step 3: Update the building owner's CreditBalance if the player landed on their building

-- 1st CTE: LastMove
WITH
LastMove AS (
	SELECT AuditLog.*
	FROM AuditLog
	WHERE AuditLog.PlayerID = 1
	ORDER BY AuditLog.LogID DESC
	LIMIT 1
),
-- 2nd CTE: MoveDetails
MoveDetails AS (
	SELECT
		LastMove.*,
		Location.TypeID,
		Location.TuitionFee,
		BuildingOwnership.OwnerID AS BuildingOwnerID,
		BuildingOwnership.ColourID,
		LastMove.RollValue
	FROM LastMove
	JOIN Location
	ON Location.LocationID = LastMove.LocationID
	LEFT JOIN BuildingOwnership
	ON BuildingOwnership.LocationID = LastMove.LocationID
),
-- 3rd CTE: OwnerReceives
OwnerReceives AS (
	SELECT
		MoveDetails.*,
		-- Calculate OwnerOwnsAllColour
		CASE
			WHEN MoveDetails.TypeID = 4
				AND MoveDetails.BuildingOwnerID IS NOT NULL
				AND MoveDetails.BuildingOwnerID != MoveDetails.PlayerID
					THEN
						CASE
							WHEN
								(SELECT COUNT(*)
								FROM BuildingOwnership
								WHERE BuildingOwnership.OwnerID = MoveDetails.BuildingOwnerID
									AND BuildingOwnership.ColourID = MoveDetails.ColourID)
								=
								(SELECT COUNT(*)
								FROM BuildingOwnership
								WHERE BuildingOwnership.ColourID = MoveDetails.ColourID)
			                        THEN 1
			                ELSE 0
		                END
		    ELSE 0
		END AS OwnerOwnsAllColour
	FROM MoveDetails
),
-- 4th CTE: OwnerReceiveFinal
OwnerReceivesFinal AS (
	SELECT
		OwnerReceives.*,
		-- Calculate amount owner should receive
		CASE
			WHEN OwnerReceives.RollValue = 6
				THEN 0  -- No effect when rolling a 6
			WHEN OwnerReceives.TypeID = 4
				AND OwnerReceives.BuildingOwnerID IS NOT NULL
				AND OwnerReceives.BuildingOwnerID != OwnerReceives.PlayerID
					THEN
						CASE
							WHEN OwnerReceives.OwnerOwnsAllColour = 1
								THEN 2 * OwnerReceives.TuitionFee  -- Owner receives double tuition fee (positive)
							ELSE OwnerReceives.TuitionFee  -- Owner receives tuition fee (positive)
						END
			ELSE 0
		END AS OwnerReceivesCredit
	FROM OwnerReceives
)
-- Insert owner's payment receival to AuditLog
INSERT INTO AuditLog (PlayerID, GameRoundID, RollValue, CreditBalance, LocationID)
SELECT
	OwnerReceivesFinal.BuildingOwnerID AS PlayerID,
	OwnerReceivesFinal.GameRoundID,
	NULL AS RollValue,
	(SELECT CreditBalance
	FROM AuditLog
	WHERE PlayerID = OwnerReceivesFinal.BuildingOwnerID
	ORDER BY LogID DESC
	LIMIT 1) + OwnerReceivesFinal.OwnerReceivesCredit AS CreditBalance,
	(SELECT LocationID
	FROM AuditLog
	WHERE PlayerID = OwnerReceivesFinal.BuildingOwnerID
	ORDER BY LogID DESC
	LIMIT 1) AS LocationID
FROM OwnerReceivesFinal
WHERE OwnerReceivesFinal.OwnerReceivesCredit > 0
;