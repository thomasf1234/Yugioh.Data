BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS Card (
  CardId integer PRIMARY KEY NOT NULL, 
  CardType varchar, 
  Category varchar, 
  Name varchar, 
  Level integer, 
  Rank integer, 
  Link integer,
  PendulumScale integer, 
  PendulumEffect varchar,
  CardAttribute varchar, 
  Property varchar, 
  Attack varchar, 
  Defense varchar, 
  Passcode varchar, 
  Description varchar
);

CREATE TABLE IF NOT EXISTS MonsterType (
  MonsterTypeId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  Name varchar, 
  CardId integer
);

CREATE TABLE IF NOT EXISTS Artwork (
  ArtworkId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  SourceUrl varchar, 
  ImagePath varchar, 
  CardId integer
);

CREATE TABLE IF NOT EXISTS CardPrint (
  CardPrintId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  Number varchar,
  CardId integer, 
  ArtworkId integer,
  RarityId integer,
  ProductId integer
);

CREATE TABLE IF NOT EXISTS Product (
  ProductId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  Name varchar
);

CREATE TABLE IF NOT EXISTS Rarity (
  RarityId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  Name varchar,
  Ratio float
);

CREATE TABLE IF NOT EXISTS ForbiddenLimitedList (
  ForbiddenLimitedListId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  EffectiveFrom date
);

CREATE TABLE IF NOT EXISTS ForbiddenLimitedListCard (
  ForbiddenLimitedListCardId integer PRIMARY KEY AUTOINCREMENT NOT NULL, 
  ForbiddenLimitedListId integer, 
  CardId integer, 
  LimitedStatus varchar
);

CREATE INDEX IX_CardOnPasscode ON Card (Passcode);
CREATE UNIQUE INDEX IX_CardOnDatabaseId ON Card (CardId);
CREATE UNIQUE INDEX IX_CardPrintOnNumber ON CardPrint (Number);
CREATE UNIQUE INDEX IX_RarityOnName ON Rarity (Name);
CREATE UNIQUE INDEX IX_ProductOnName ON Product (Name);
CREATE UNIQUE INDEX IX_ForbiddenLimitedListOnEffectiveFrom ON ForbiddenLimitedList (EffectiveFrom);
CREATE UNIQUE INDEX UIX_ForbiddenLimitedListCardOnFLLIdAndCardId ON ForbiddenLimitedListCard (ForbiddenLimitedListId, CardId);
COMMIT;