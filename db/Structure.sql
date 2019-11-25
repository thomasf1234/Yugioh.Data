BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS CardSpec (
  CardId integer PRIMARY KEY NOT NULL, 
  -- Type varchar NOT NULL, -- Monster, Spell, Trap 
  Name varchar NOT NULL, 
  Level integer, 
  Rank integer, 
  Link integer,
  PendulumScale integer, 
  PendulumEffect varchar,
  CardAttribute varchar NOT NULL, 
  Property varchar, 
  Attack varchar, 
  Defense varchar, 
  Description varchar NOT NULL --,
  -- Archetype varchar
);

CREATE TABLE IF NOT EXISTS MonsterType (
  MonsterTypeId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  Name varchar NOT NULL, 
  CardId integer NOT NULL
);

CREATE TABLE IF NOT EXISTS Artwork (
  CardId integer NOT NULL,
  Alternate BOOLEAN NOT NULL, 
  Image BLOB NOT NULL, 
  MD5 CHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS CardPrint (
  SetCode varchar PRIMARY KEY NOT NULL,
  CardId integer NOT NULL, 
  ArtworkId integer,
  RarityId integer,
  CardSetId integer
);

CREATE TABLE IF NOT EXISTS CardSet (
  CardSetId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  Abbreviation varchar NOT NULL,
  Name varchar NOT NULL
  -- ProductBasePrice integer NOT NULL
);

-- CREATE TABLE IF NOT EXISTS PackSpec (
--   PackSpecId varchar PRIMARY KEY NOT NULL, 
--   ProductId integer NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS PackCardSpec (
--   PackCardSpecId varchar PRIMARY KEY NOT NULL, 
--   PackCardIndex integer NOT NULL,
--   PackSpecId varchar NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS PackCardSpecPool (
--   PackCardSpecPoolId varchar PRIMARY KEY NOT NULL, 
--   Name varchar,
--   PackSpecId varchar NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS PackCardSpecPoolCardPrint (
--   PackCardSpecPoolCardPrintId integer NOT NULL, 
--   CardNumber varchar
-- );

-- "ProductName": "STRUCTURE DECK ZOMBIE MADNESS",
--   "ProductId": "SD2",
--   "ProductType": "StructureDeck",
--   "ProductBasePrice": 5000,
--   "ProductPackSpecs

CREATE TABLE IF NOT EXISTS Rarity (
  RarityId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  Name varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS ForbiddenLimitedList (
  ForbiddenLimitedListId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  EffectiveFrom date
);

CREATE TABLE IF NOT EXISTS ForbiddenLimitedListCard (
  ForbiddenLimitedListCardId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  ForbiddenLimitedListId integer, 
  CardId integer NOT NULL, 
  LimitedStatus varchar
);

-- CREATE VIEW IF NOT EXISTS CardPrint
-- AS 
-- SELECT cp.CardNumber, cs.Name, cs.Level, cs.Rank, cs.Link, cs.PendulumScale, cs.PendulumEffect, cs.CardAttribute, cs.Property, cs.Attack, cs.Defense, cs.Passcode, cs.Description, r.Name AS RarityName, a.ImagePath FROM CardSpec cs 
-- INNER JOIN CardPrint cp ON cp.CardId = cs.CardId 
-- INNER JOIN Rarity r ON r.RarityId = cp.RarityId 
-- LEFT JOIN Artwork a ON a.ArtworkId = cp.ArtworkId;

CREATE INDEX IX_MonsterTypeOnCardId ON MonsterType (CardId);
CREATE INDEX IX_ArtworkOnCardId ON Artwork (CardId);

CREATE UNIQUE INDEX UIX_CardPrintOnSetCode ON CardPrint (SetCode);
CREATE UNIQUE INDEX UIX_ArtworkOnMD5 ON Artwork (MD5);
CREATE UNIQUE INDEX UIX_RarityOnName ON Rarity (Name);
CREATE UNIQUE INDEX UIX_CardSetOnName ON CardSet (Name);
CREATE UNIQUE INDEX UIX_ForbiddenLimitedListOnEffectiveFrom ON ForbiddenLimitedList (EffectiveFrom);
CREATE UNIQUE INDEX UIX_ForbiddenLimitedListCardOnFLLIdAndCardId ON ForbiddenLimitedListCard (ForbiddenLimitedListId, CardId);
COMMIT;