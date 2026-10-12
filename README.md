# Tactix Minimal

Battery-efficient, customizable Connect IQ watch face for the Garmin tactix 7 / tactix 7 Pro (280x280 MIP). Written in Monkey C.

There is no `tactix7` Connect IQ device ID; the tactix 7 family ships under `fenix7x`.

## Layout

- Top: date (accent color)
- Center: large digital time
- Bottom: battery icon + `82%` or `82% (24d)`
- Optional: battery progress arc along the bezel, 12 tick markers

Redraws once per minute only (no seconds, no partial updates). Settings are cached and re-read only when they change.

## Settings

| Setting | Options |
| --- | --- |
| Accent Color | Olive Green, Tactical Orange, High-Vis Cyan, White, Red |
| Hours Color / Minutes Color | Match Accent, White, Light Grey, Olive Green, Tactical Orange, High-Vis Cyan, Red (colon follows hours) |
| Time Font | Condensed, Bold, Regular |
| Hours Size / Minutes Size | Small, Medium, Large, Extra Large (digits share a baseline; auto-shrinks to stay inside the ticks) |
| Show Colon | on / off (hours and minutes join when off) |
| Date Format | `MON · OCT 12`, `Monday, Oct 12`, `12 / OCT`, `YYYY-MM-DD`, `MM/DD/YY` |
| Time Format | Follow System, Military (24h) |
| Battery Days Left / Battery Arc / Tick Marks | on / off |

Change them on the watch (hold UP > Watch Face > Tactix Minimal > Customize) or, when installed from the Connect IQ Store, in the Connect IQ / Garmin Connect phone app. Sideloaded builds only support the on-watch menu.

## Build and run

Requires Java 17 (`brew install openjdk@17`), the Connect IQ SDK, the fenix 7X device downloaded in SDK Manager, and a developer key at `~/.garmin/developer_key.der`.

```bash
./build.sh        # builds bin/TactixMinimal.prg
./build.sh run    # builds, starts the simulator, loads the face
```

## Install (sideload)

Connect the watch over USB, open [OpenMTP](https://openmtp.ganeshrvel.com/), and copy `bin/TactixMinimal.prg` into `GARMIN/APPS/`. Disconnect, then select **Tactix Minimal** under Watch Face.
