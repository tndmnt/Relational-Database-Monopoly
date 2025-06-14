# Relational-Database-Monopoly
This project is about creating a relational database for running a monopoly game using SQLite

University Tycoon is a database simulation of a university-themed board game built using SQLite. Players navigate a game board representing campus locations, where they earn or lose credits based on roll values, location types, and ownership dynamics. The system uses complex SQL logic to manage game mechanics, enforce rules, and update states across game rounds.

Features
🎓 Player Management: Up to 6 unique players, each assigned a distinct token.

🏢 Location Modeling: Includes academic buildings, RAG events, and hearings with tuition fees and ownership logic.

💳 Credit System: Credits are gained/lost based on movement, ownership, and special conditions (e.g., passing Welcome Week).

🛠️ Game Logic: Implemented using SQL queries with CTEs and triggers to:

Move players based on dice rolls.

Update player credit balances.

Enforce rules for building purchases and tuition payments.

Handle special cases like landing on suspension zones.

🗂️ Normalized Database: 8 interconnected tables including Player, Location, BuildingOwnership, and AuditLog.

🧠 Advanced SQL Usage: Uses WITH clauses, JOINs, TRIGGERs, and nested logic for game progression.

Technologies
SQLite

SQL (DDL, DML, advanced CTE queries)

Files
create.sql: Defines the schema.

populate.sql: Seeds the database with tokens, players, locations, etc.

q1.sql – q8.sql: Contains logic to simulate game rounds and player moves.

How to Use
Run create.sql to set up the database schema.

Run populate.sql to insert sample data.

Execute the queries in q1.sql to q5.sql to simulate game rounds.

Review the AuditLog table for tracking player progress and credit changes.
