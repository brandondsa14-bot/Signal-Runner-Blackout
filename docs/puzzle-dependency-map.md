# Puzzle Dependency Map

```text
CEMETERY TERMINAL
    |
    v
Cemetery Key
    |
    v
Far-right Grave -> Hidden Stairway
    |
    v
UNDERGROUND RECEPTION
    |
    +-- Find Spare Fuse
    +-- Install Fuse -> Partial Power
                         |
                         v
                   SECURITY CONTROL
                         |
                         +-- Read sequence clue
                         +-- R -> B -> Y -> B
                         |
                         +--> Security Keycard + SIGNAL 1
                              |                   |
             +----------------+                   |
             |                                    |
             v                                    v
       RECORDS ARCHIVE                      MEDICAL LAB
             |                                    |
             +-- Intake Records (EVIDENCE 1)      +-- Audio clue
             +-- BLUE scan -> code 7-3-1          +-- B/R/Y receivers
             |                                    +-- SIGNAL 2
             +------------------+-----------------+
                                |
                                v
                         DETENTION BLOCK
                                |
                                +-- YELLOW bypass + code/keycard
                                +-- Cell Key
                                +-- Cell 04 belongings (EVIDENCE 2)
                                +-- Maintenance Badge
                                |
                                v
                         MAINTENANCE
                                |
                                +-- Screwdriver
                                +-- Open Relay Panel 3
                                +-- RED scan -> SIGNAL 3
                                |
                                v
                    CONTAINMENT UNLOCKED
                                |
                                +-- Node A = YELLOW
                                +-- Node B = BLUE
                                +-- Node C = RED
                                +-- C-17 Log (EVIDENCE 3)
                                |
                                v
                       FINAL INVESTIGATION
                                |
                                +-- Required evidence 1 + 2 + 3
                                +-- BLUE decrypt
                                +-- Upload to Marshall PD
                                |
                                v
                              ENDING
```

## Scanner mechanic variety

- Sequence input — Security.
- Hidden evidence detection — Archive.
- Multi-receiver alignment — Laboratory.
- Electronic lock bypass — Detention.
- Relay synchronization — Maintenance.
- Multi-node calibration under pursuit — Containment.
- Evidence decryption — Final Investigation.

## Non-scanner item logic

- Cemetery Key.
- 20A fuse.
- Security Keycard.
- Physical Cell Key.
- Maintenance Badge.
- Screwdriver.
- Evidence collection.

Critical item state is stored in the persistent `Game` struct, so normal room transitions and deaths do not delete mandatory progression.
