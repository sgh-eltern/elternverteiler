# Datenmodell Elternverteiler

# Schüler

ID
Vorname (Pflicht)
Nachname (Pflicht)
Klasse (Pflicht)

PrimaryKey ID

# Table: Erziehungsberechtigter

ID
Vorname (Optional)
Nachname (Pflicht)
Mail (Optional)
Telefon (Optional)
Zugang (Optional)
Abgang (Optional)

PrimaryKey ID

# Erziehungsberechtigung (Schüler <=> Erziehungsberechtigter)

SchülerID
ErziehungsberechtigterID

PrimaryKey SchülerID,ErziehungsberechtigterID

# Rollen

J1-AGH K eltern-J1-KOOP
J2-AGH K eltern-J2-KOOP
EV G elternbeirat
SK G elternvertreter-schulkonferenz
EBV G elternbeiratsvorsitzende

1. EBV
2. EBV
1. EV
2. EV
SK

# Rollenzuordnungen der Kinder (Schüler <=> Rolle)

SchülerID
RolleID

PrimaryKey SchülerID,RolleID

# Rollenzuordnungen der Eltern (Erziehungsberechtigter <=> Rolle)

ErziehungsberechtigterID
RolleID

PrimaryKey ErziehungsberechtigterID,RolleID

# View: Klassenstufenverteiler

Klasse starts with 5,6,7,8,9,10,J1,J2

# TODO

* Indices (für Suche)
