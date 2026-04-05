# Market — Portfolio Dashboard

A simple portfolio dashboard app that tracks your **Indian stocks** and **Bitcoin** holdings.

Built with:
- **Backend**: Python + FastAPI (fast, modern API framework)
- **Frontend**: Flutter (one codebase → iOS, Android, Web)

---

## Project Structure

```
Market/
├── api/          ← Python FastAPI backend
│   ├── main.py
│   └── requirements.txt
├── app/          ← Flutter frontend
│   └── lib/
│       ├── main.dart
│       └── dashboard_screen.dart
└── README.md
```

---

## Running the Backend

```bash
# Step 1: Go into the api folder
cd api

# Step 2: Install Python dependencies
pip install -r requirements.txt

# Step 3: Start the server (--reload means it restarts on code changes)
uvicorn main:app --reload
```

The API will be live at: http://localhost:8000
Test it by opening: http://localhost:8000/portfolio

---

## Running the Flutter App

```bash
# Step 1: Go into the app folder
cd app

# Step 2: Install Flutter dependencies
flutter pub get

# Step 3: Run the app
flutter run          # picks a connected device automatically
flutter run -d web   # run in browser
flutter run -d ios   # run on iOS simulator
flutter run -d android  # run on Android emulator
```

---

## API Endpoints

| Method | URL          | Description                  |
|--------|--------------|------------------------------|
| GET    | `/portfolio` | Returns mock portfolio data  |

---

## What You'll See

- A dashboard screen with your portfolio summary
- Total portfolio value + daily change
- List of assets: Indian stocks + Bitcoin
- A button to load live data from the backend
