# Tactix Minimal

Customizable Connect IQ watch face for the Garmin tactix 7 / tactix 7 Pro (280x280 MIP). Written in Monkey C.

There is no `tactix7` Connect IQ device ID; the tactix 7 family ships under `fenix7x`.

## Layout (fixed zones)

Nothing stacks on the time digits. Fields only draw in reserved bands:

1. **Top** — date, then weather  
2. **Metrics strip** — HR, steps, calories, battery % (only enabled fields, evenly spaced)  
3. **Center** — digital time and/or analog hands  
4. **Bottom** — distance, sunrise/sunset  
5. **Chrome** — steps arc, battery arc, tick marks  

Extras hide in low-power sleep (backlight off), same as before.

## Real data

Values come from the watch APIs when available:

- Steps / calories / distance — `ActivityMonitor`
- Heart rate — live activity HR, else recent `SensorHistory`
- Weather + sunrise/sunset — Garmin weather cache (`Weather` + `Positioning`)

If a sensor has no sample yet, the field shows `--` (or hides weather/sun lines).

## Settings

Customize is nested. **Style** is first: picking a style applies a full visual preset (colors, arcs, which fields show). You can still override anything afterward.

| Style | Feel |
| --- | --- |
| Tactix | Orange/cyan hybrid, arrow hands, blinking colon |
| Military | Olive/grey hybrid, syringe field hands, dense hash ring |
| Casual | Soft cyan/white hybrid, baton hands, cardinal dots |
| Sport | Red/orange hybrid, sword hands, pulsing seconds arc |
| Stealth | Cream/grey analog, thin pencil hands, quiet halo |

| Menu | Options |
| --- | --- |
| Style | Tactix / Military / Casual / Sport / Stealth |
| Chrome | Background black/white, images (None / Angry Bear / Wolf / Sniper Scope), accent, seconds arc, ticks |
| Time | Digital / Analog / Hybrid, expanded color palette, font, sizes, colon, 12/24h |
| Date | Show, color, format |
| Battery | Show, color, days left, arc |
| Steps | Show, color, arc |
| Heart Rate | Show, color |
| Calories | Show, color |
| Distance | Show, color |
| Weather | Show, color |
| Sunrise / Sunset | Show, color |
| Chrome | Accent color, tick marks |

Color / list pickers still use a live face preview with options on the left.

## Build and run

Requires Java 17, the Connect IQ SDK, fenix 7X device defs, and `~/.garmin/developer_key.der`.

```bash
./build.sh        # builds bin/TactixMinimal.prg
./build.sh run    # simulator
```

## Install (sideload)

Copy `bin/TactixMinimal.prg` into `GARMIN/APPS/` with [OpenMTP](https://openmtp.ganeshrvel.com/), disconnect, select **Tactix Minimal** under Watch Face.
