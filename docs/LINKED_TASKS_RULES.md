# Linked Tasks - Rules and flows

This document describes the runtime flows and safety guarantees for the Linked Tasks system (server + client).

## Login flow

1. Player logs in.
2. Server ensures DB rows exist for all configured tasks (`player_tasks`).
3. Server registers the player for Linked Tasks events (extended opcode + death handler).
4. Server schedules a delayed full sync to the client.

**Fail-safe:** If the server cannot determine the player or the system is missing, the login flow exits without sending any task data.

## Sync flow (client/server)

### Client → Server request

- Client requests sync using ExtendedOpcode `222` with payload:
  - `"sync"` → server sends a full sync.
  - `"check"` → server validates the active task and responds accordingly.

Unknown payloads are ignored by the server.

### Server → Client full sync

- ExtendedOpcode `220` is used.
- Payload format (string):
  - Line delimiter: `\n`
  - Field delimiter: `\t`
  - First line: `ACTIVE\t<taskId>`
  - Subsequent lines: `TASK\t<id>\t<status>\t<progress>\t<required>\t<name>\t<description>\t<objectiveType>\t<objectiveTarget>\t<rewardGold>\t<rewardExperience>\t<rewardItems>`

### Server → Client update

- ExtendedOpcode `221` is used.
- Payload format (string): `UPDATE\t<taskId>\t<status>\t<progress>\t<required>`

### Client-side rules

- The client **must** treat ExtendedOpcode payloads as optional and abort parsing when the payload is missing, empty, or malformed.
- The client must handle plain string payloads (e.g., `"sync"`, `"check"`) without assuming binary data.

## Kill progression flow

1. A monster dies and the server receives `onDeath` with `killer` and `mostDamageKiller`.
2. The system resolves a player from those parameters (including pet/summon masters).
3. If the player has an active task of type `kill` and the monster name matches the target, progress is incremented.
4. When progress reaches the required amount, the task is completed, rewards are granted, and a full sync is sent.

**Fail-safe:** If the killer is not a player, if the victim is not a monster, or if the monster is a summon, the task system does nothing.

## Collect progression flow

1. The player asks to `check` the current task.
2. If the active task is of type `collect`, the server counts items in inventory and updates progress.
3. If progress reaches the required amount, the task is completed, rewards are granted, and a full sync is sent.

**Fail-safe:** If the task is not a collect task or the player has no active task, the system only responds with an informational message and sync.

## Reward flow

- On completion, rewards are granted in this order:
  1. Bank gold.
  2. Experience points.
  3. Item rewards.
- The server sends a completion message (`MESSAGE_EVENT_ADVANCE`) and immediately syncs the client.

## Fail-safe rules

### Client must never assume

- Payloads are always present.
- Payloads are always binary or follow a specific format.
- The server always sends complete fields.

### Server must always validate

- The killer is a player (or player-owned summon).
- The dead creature is a monster (not a summon).
- The player has an active task with a matching objective type and target.
- Payloads sent to the client are sanitized to remove protocol delimiters and control characters.

## Payload sanitization rules

- The server removes `\n`, `\r`, and `\t` from any string fields sent to the client.
- The delimiters `\n` and `\t` are reserved for protocol framing and must never appear inside a field value.
- Reward items are encoded as `id:count` pairs separated by commas; `:` and `,` are therefore reserved for that field only.
