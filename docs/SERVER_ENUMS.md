# Linked Tasks - Server enums

This document lists the enums/constants that the Linked Tasks system relies on for protocol and runtime validation. When values are not exposed in the Lua layer, prefer the constant names and refer to the Canary/Crystal server core for the numeric values.

## MessageType (sendTextMessage)

These are the message types used by the Linked Tasks system when calling `player:sendTextMessage`.

| Constant | Value | Description | Usage rules | Compatibility notes |
| --- | --- | --- | --- | --- |
| `MESSAGE_EVENT_ADVANCE` | Defined in server core | Positive feedback to the player (task start/finish, success messages). | Use for success, completion, or advancement messages. | Safe for Canary/OTServBR clients. |
| `MESSAGE_INFO_DESCR` | Defined in server core | Informational text channel. | Use for descriptive/informative messages where appropriate. | Safe for Canary/OTServBR clients. |
| `MESSAGE_STATUS_CONSOLE_ORANGE` | Defined in server core | Error/warning feedback in console channel. | Use for player-facing errors or denial messages. | Safe for Canary/OTServBR clients. |
| `MESSAGE_STATUS_CONSOLE_BLUE` | Defined in server core | Neutral/informational feedback in console channel. | Use for status and instructions. | Safe for Canary/OTServBR clients. |

## ExtendedOpcode (Linked Tasks)

These constants define the protocol opcodes used between server and client.

| Name | Value | Direction | Description | Usage rules |
| --- | --- | --- | --- | --- |
| `LinkedTasks.opcode.sync` | `220` | Server → Client | Full state sync payload (ACTIVE + TASK lines). | Payload is a UTF-8 string, with `\n` separating lines and `\t` separating fields. |
| `LinkedTasks.opcode.update` | `221` | Server → Client | Incremental task update payload. | Payload is `UPDATE\t<taskId>\t<status>\t<progress>\t<required>`. |
| `LinkedTasks.opcode.request` | `222` | Client → Server | Client requests sync or check. | Payload is the string `"sync"` or `"check"`. Unknown values are ignored. |

## LinkedTasks.status

Status values used for persistence and sync payloads.

| Name | Value | Description | Usage rules | Compatibility notes |
| --- | --- | --- | --- | --- |
| `LinkedTasks.status.notStarted` | `0` | Task not started in this cycle. | Used in DB and sync payloads. | Lua-defined constant in `linked_tasks.lua`. |
| `LinkedTasks.status.inProgress` | `1` | Task currently active/in progress. | Used in DB and sync payloads. | Lua-defined constant in `linked_tasks.lua`. |
| `LinkedTasks.status.completed` | `2` | Task completed in this cycle. | Used in DB and sync payloads. | Lua-defined constant in `linked_tasks.lua`. |
