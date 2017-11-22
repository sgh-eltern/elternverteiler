# Datenmodell Elternverteiler

# Rollen

EV G elternbeirat
SK G elternvertreter-schulkonferenz
EBV G elternbeiratsvorsitzende
J1-AGH K eltern-J1-KOOP
J2-AGH K eltern-J2-KOOP

1. EBV
2. EBV
1. EV
2. EV
SK

# Rollenzuordnungen der Eltern (Erziehungsberechtigter <=> Rolle)

ErziehungsberechtigterID
RolleID

PrimaryKey ErziehungsberechtigterID,RolleID

# Rollenzuordnungen der Kinder (Schüler <=> Rolle)

SchülerID
RolleID

PrimaryKey SchülerID,RolleID
