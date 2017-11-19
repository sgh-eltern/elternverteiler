# Datenmodell Elternverteiler

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
