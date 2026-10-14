# LabLend Installation & Setup Guide

This guide provides end-to-end instructions for deploying and running **LabLend**, including the Node.js backend REST service and the Flutter mobile application.

---

## 1. System Requirements

- **Node.js**: v20.0.0 LTS or higher (`node -v`)
- **NPM**: v10.0.0 or higher (`npm -v`)
- **Flutter SDK**: v3.24+ / 3.47+ stable (`flutter --version`)
- **Dart**: v3.5+
- **MongoDB**: MongoDB Atlas cluster URI or local MongoDB Community Server
- **Cloudinary Account**: Cloud name, API Key, and API Secret for media asset hosting

---

## 2. Backend Setup (`backend/`)

### A. Environment Configuration
Navigate to the `backend/` directory:
```bash
cd backend
cp .env.example .env
```

Edit `.env` with your credentials:
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/lablend?retryWrites=true&w=majority
JWT_ACCESS_SECRET=your_long_random_jwt_secret_key_minimum_32_chars
JWT_ACCESS_EXPIRES_IN=7d
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
CLIENT_ORIGIN=*
```

> [!NOTE]
> If MongoDB is not yet running locally, the server starts in development mode and tests run in isolated offline mock mode. When real Cloudinary credentials are provided, direct uploads are cryptographically signed. If left blank in development, a graceful high-resolution simulation fallback is used.

### B. Dependency Installation
```bash
npm install
```

### C. Populate Seed Data
To populate the database with realistic scientific equipment listings, verified academic core facilities (Stanford, MIT, UC Berkeley, Salk Institute), and sample reservations:
```bash
npm run seed
```

Default credentials populated by the seed script:
- `erostova@stanford.edu` / `Password123!` (Stanford Bioengineering Core - Principal Investigator)
- `mchen@mit.edu` / `Password123!` (MIT Materials & NanoLab - Senior Faculty)
- `salmansoor@berkeley.edu` / `Password123!` (UC Berkeley QB3 Core - Facility Manager)
- `jvance@salk.edu` / `Password123!` (Salk Institute - Postdoctoral Fellow)

### D. Start Backend Service
```bash
# Development mode with automatic reload
npm run dev

# Production start
npm start
```

Verify service health:
```bash
curl http://localhost:5000/api/v1/health
```

### E. Run Backend Test Suite
```bash
npm test
```

---

## 3. Flutter Mobile Application Setup (`flutter_app/`)

### A. Dependency Resolution
Navigate to `flutter_app/`:
```bash
cd flutter_app
flutter pub get
```

### B. Emulator vs. Physical Device Networking

| Environment | API Host Address | Rationale |
| :--- | :--- | :--- |
| **Android Emulator** | `http://10.0.2.2:5000/api/v1` | **Default**: Android emulators run inside a virtual network where `10.0.2.2` aliases the development machine's `127.0.0.1`. |
| **iOS Simulator** | `http://localhost:5000/api/v1` | iOS simulators share the host machine's network stack directly. |
| **Physical Android / iOS Device** | `http://192.168.x.x:5000/api/v1` | Physical devices cannot resolve `localhost` or `10.0.2.2`. Use your computer's local Wi-Fi IP. |
| **Tunnel (ngrok / Localtunnel)** | `https://xxxx.ngrok-free.app/api/v1` | Ideal for remote mobile testing without Wi-Fi subnet restrictions. |

> [!TIP]
> You can also adjust the active API base URL live inside the Flutter application by navigating to **Profile -> Network & Emulator Settings** and selecting the one-tap preset or typing your IP.

### C. Run Static Analysis & Tests
```bash
# Verify static analysis
flutter analyze

# Execute Flutter widget and unit tests
flutter test
```

### D. Launch Mobile Application
```bash
# Run on connected Android device or running emulator
flutter run
```

---

## 4. Common Troubleshooting

1. **Android Emulator: Connection refused on `localhost:5000`**:
   - Ensure the app is configured to use `http://10.0.2.2:5000/api/v1`, not `localhost`.
2. **Cloudinary Upload Returns 401**:
   - Verify `CLOUDINARY_API_KEY` and `CLOUDINARY_API_SECRET` match your Cloudinary dashboard.
3. **MongoDB Atlas Whitelist**:
   - In MongoDB Atlas, ensure your current IP address is added to the Network Access IP Access List (`0.0.0.0/0` for development).
