# LabLend Backend REST API Service

The backend REST API for **LabLend**, an institutional laboratory equipment marketplace built with Node.js, Express, MongoDB Atlas, and Cloudinary.

## Features
- **Architecture**: Modular layered design (Models, Routes, Controllers, Services, Middleware, Validators).
- **Authentication**: JWT token-based auth with bcrypt password hashing and rate limiting.
- **Equipment Catalog**: Search, multi-criteria filtering (category, price, condition, availability, location), sorting, pagination.
- **Request Workflow**: Complete rental and purchase request state machine (`pending` -> `approved` / `rejected` -> `completed` / `cancelled`) with concurrency conflict protection for overlapping dates.
- **Cloudinary Integration**: Signed upload signatures for secure direct mobile uploads, with ownership validation on deletion.
- **In-App Notifications**: Real-time notifications for booking requests and status updates.
- **Security**: Helmet headers, CORS policies, Zod request body validation, Express rate limiter on sensitive endpoints.

## Getting Started

### 1. Environment Setup
Copy `.env.example` to `.env` and fill in credentials:
```bash
cp .env.example .env
```

Required keys:
- `MONGODB_URI`: Your MongoDB connection string (local or Atlas)
- `JWT_ACCESS_SECRET`: Secret key for signing tokens
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`: Media upload keys

### 2. Install Dependencies
```bash
npm install
```

### 3. Seed Database
```bash
npm run seed
```

### 4. Run Development Server
```bash
npm run dev
```
The server will start at `http://localhost:5000`. Health check: `http://localhost:5000/api/v1/health`.

### 5. Run Tests
```bash
npm test
```
