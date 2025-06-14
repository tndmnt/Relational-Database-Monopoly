# Relational-Database-Monopoly
This project is about creating a relational database for running a monopoly game using SQLite


University Tycoon is a database simulation of a university-themed board game built using SQLite. Players navigate a game board representing campus locations, where they earn or lose credits based on roll values, location types, and ownership dynamics. The system uses complex SQL logic to manage game mechanics, enforce rules, and update states across game rounds.


Features
- Player Management: Up to 6 unique players, each assigned a distinct token.
- Location Modeling: Includes academic buildings, RAG events, and hearings with tuition fees and ownership logic.
- Credit System: Credits are gained/lost based on movement, ownership, and special conditions (e.g., passing Welcome Week).
- Game Logic: Implemented using SQL queries with CTEs and triggers to:
- Move players based on dice rolls.
- Update player credit balances.
- Enforce rules for building purchases and tuition payments.
- Handle special cases like landing on suspension zones.


Normalized Database: 8 interconnected tables including Player, Location, BuildingOwnership, and AuditLog.


Advanced SQL Usage: Uses WITH clauses, JOINs, TRIGGERs, and nested logic for game progression.


Files
1. create.sql: Defines the schema.
2. populate.sql: Seeds the database with tokens, players, locations, etc.
3. q1.sql – q8.sql: Contains logic to simulate game rounds and player moves.


How to Use
1. Run create.sql to set up the database schema.
2. Run populate.sql to insert sample data.
3. Execute the queries in q1.sql to q5.sql to simulate game rounds.
4. Review the AuditLog table for tracking player progress and credit changes.
