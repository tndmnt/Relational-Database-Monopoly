-- Create view leaderboard with net worth
CREATE VIEW leaderboard AS
    SELECT
        Player.PlayerName AS name,
        CurrentLocation.LocationName AS location,
        LatestAudit.CreditBalance AS credits,
        COALESCE(
            (SELECT GROUP_CONCAT(OwnedLoc.LocationName, ', ')
            FROM BuildingOwnership
            JOIN Location AS OwnedLoc 
            ON BuildingOwnership.LocationID = OwnedLoc.LocationID
            WHERE BuildingOwnership.OwnerID = Player.PlayerID
            ORDER BY OwnedLoc.LocationID ASC), 
        '') AS buildings,
        IFNULL(SUM(2 * OwnedLoc.TuitionFee), 0) AS property_value, 
        (LatestAudit.CreditBalance + IFNULL(SUM(2 * OwnedLoc.TuitionFee), 0)) AS net_worth
    FROM Player
    JOIN AuditLog AS LatestAudit 
    ON Player.PlayerID = LatestAudit.PlayerID
    AND LatestAudit.LogID = (
        SELECT MAX(LogID) 
        FROM AuditLog 
        WHERE PlayerID = Player.PlayerID
        )
    JOIN Location AS CurrentLocation 
    ON LatestAudit.LocationID = CurrentLocation.LocationID
    LEFT JOIN BuildingOwnership 
    ON Player.PlayerID = BuildingOwnership.OwnerID
    LEFT JOIN Location AS OwnedLoc 
    ON BuildingOwnership.LocationID = OwnedLoc.LocationID
    GROUP BY Player.PlayerID
    ORDER BY net_worth DESC
;
