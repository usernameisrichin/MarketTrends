# Market — Portfolio Dashboard

A portfolio dashboard that tracks **Indian stock holdings** and **Bitcoin**.

| Layer    | Technology          |
|----------|---------------------|
| Backend  | Python + FastAPI    |
| Frontend | Flutter (iOS / Android / Web) |

---

## Project Structure

```
Market/
├── api/                          ← FastAPI backend
│   ├── main.py                   ← App entry point (wires routes + CORS)
│   ├── requirements.txt
│   ├── models/
│   │   └── portfolio.py          ← Pydantic data blueprints
│   ├── routes/
│   │   └── portfolio.py          ← GET /portfolio handler
│   └── services/
│       └── portfolio_service.py  ← Business logic + mock data
│
└── app/                          ← Flutter frontend
    └── lib/
        ├── main.dart             ← App entry point
        ├── core/
        │   ├── constants/
        │   │   └── api_constants.dart   ← API URL constants
        │   └── theme/
        │       └── app_theme.dart       ← App-wide theme
        ├── features/
        │   └── dashboard/
        │       ├── models/
        │       │   └── portfolio_model.dart   ← Dart data models
        │       ├── screens/
        │       │   └── dashboard_screen.dart  ← Main screen
        │       ├── services/
        │       │   └── portfolio_service.dart ← HTTP calls
        │       └── widgets/
        │           ├── asset_card.dart        ← Single asset row
        │           └── summary_card.dart      ← Portfolio total card
        └── shared/               ← Shared/reusable widgets (future use)
```

---

## Running the Backend

```bash
cd api
pip install -r requirements.txt
uvicorn main:app --reload
```

- API: http://localhost:8000
- Portfolio endpoint: http://localhost:8000/portfolio
- Interactive docs: http://localhost:8000/docs

---

## Running the Flutter App

```bash
cd app
flutter pub get
flutter run -d web        # Browser
flutter run -d ios        # iOS Simulator
flutter run -d android    # Android Emulator
```

> **Android users:** change `localhost` to `10.0.2.2` in
> `lib/core/constants/api_constants.dart` so the emulator
> can reach your computer's localhost.

---

## API Response Shape

`GET /portfolio`

```json
{
  "totalValue": 1600000,
  "dailyChange": "+2.3%",
  "assets": [
    { "type": "stock",  "name": "Reliance Industries", "symbol": "RELIANCE", "value": 500000, "change": "+1.2%" },
    { "type": "stock",  "name": "TCS",                 "symbol": "TCS",      "value": 300000, "change": "-0.5%" },
    { "type": "crypto", "name": "Bitcoin",              "symbol": "BTC",      "value": 450000, "change": "+3.8%" }
  ]
}
```

---

## Architecture Principles

- **Separation of concerns** — routes, models, and services each have one job
- **Feature folders** — Flutter code grouped by feature, not by file type
- **Single source of truth** — API URLs in `api_constants.dart`, theme in `app_theme.dart`
- **Conventional commits** — `feat:`, `fix:`, `chore:`, `docs:`
