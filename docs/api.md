# LabLend REST API Documentation

Base URL: `http://localhost:5000/api/v1` (or `http://10.0.2.2:5000/api/v1` from Android Emulator)

All JSON responses follow a standardized envelope convention:

### Success Response Envelope
```json
{
  "success": true,
  "message": "Equipment retrieved successfully",
  "data": {},
  "pagination": {
    "page": 1,
    "limit": 12,
    "total": 7,
    "totalPages": 1
  }
}
```

### Error Response Envelope
```json
{
  "success": false,
  "message": "A readable error message",
  "code": "VALIDATION_ERROR",
  "errors": [
    { "field": "email", "message": "Please enter a valid institutional email" }
  ]
}
```

---

## 1. Authentication Endpoints

### Register
`POST /api/v1/auth/register`
- **Body**:
  ```json
  {
    "fullName": "Dr. Elena Rostova",
    "email": "erostova@stanford.edu",
    "password": "Password123!",
    "institutionName": "Stanford Bioengineering Research Core",
    "institutionType": "university",
    "city": "Stanford",
    "state": "CA",
    "contactNumber": "+1 (650) 555-0142",
    "department": "Bioengineering",
    "title": "Principal Investigator"
  }
  ```
- **Response**: `201 Created` with JWT access token and user profile.

### Login
`POST /api/v1/auth/login`
- **Rate Limit**: 20 requests per 15 minutes.
- **Body**:
  ```json
  {
    "email": "erostova@stanford.edu",
    "password": "Password123!"
  }
  ```
- **Response**: `200 OK` with token and user object.

### Current User Profile
`GET /api/v1/auth/me`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `200 OK` with populated institution profile.

### Password Recovery
`POST /api/v1/auth/forgot-password`
- **Body**: `{ "email": "erostova@stanford.edu" }`
- **Response**: `200 OK` (simulated reset token generated in development mode).

---

## 2. Equipment Endpoints

### List Equipment Catalog
`GET /api/v1/equipment`
- **Query Parameters**:
  - `search`: Keyword string matching title or description
  - `category`: `microscopy`, `centrifugation`, `spectroscopy`, `chromatography`, `thermal_analysis`, `electronics`, `cell_culture`, `analytical_chemistry`, `general_lab`
  - `listingType`: `rent`, `buy`, `both`
  - `availability`: `available`, `rented`, `maintenance`, `reserved`
  - `minPrice`: Minimum rental or purchase price
  - `maxPrice`: Maximum price limit
  - `city`, `state`: Geographic location filters
  - `sort`: `newest` (default), `price_asc`, `price_desc`, `popular`
  - `page`: Page index (default: 1)
  - `limit`: Items per page (default: 12)
  - `featured`: `true` | `false`

### Create Equipment Listing
`POST /api/v1/equipment`
- **Headers**: `Authorization: Bearer <token>`
- **Body**:
  ```json
  {
    "title": "Olympus IX83 Inverted Fluorescence Microscope",
    "description": "Fully motorized inverted microscope optimized for live-cell imaging...",
    "category": "microscopy",
    "condition": "like_new",
    "listingType": "both",
    "rentalPrice": 75,
    "rentalPricingUnit": "hour",
    "purchasePrice": 42000,
    "location": {
      "building": "Shriram Center",
      "room": "B-104",
      "city": "Stanford",
      "state": "CA"
    },
    "images": [
      {
        "url": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3",
        "publicId": "olympus_ix83_01",
        "isCover": true
      }
    ],
    "technicalSpecs": [
      { "key": "Magnification", "value": "100x TIRF" }
    ]
  }
  ```

### Get Equipment by ID
`GET /api/v1/equipment/:id`

### Update Listing
`PATCH /api/v1/equipment/:id`
- **Headers**: `Authorization: Bearer <token>` (Owner authorization enforced)

### Archive / Delete Listing
`DELETE /api/v1/equipment/:id`
- **Headers**: `Authorization: Bearer <token>`

---

## 3. Request & Reservation Endpoints

### Submit Request
`POST /api/v1/requests`
- **Headers**: `Authorization: Bearer <token>`
- **Body**:
  ```json
  {
    "equipmentId": "65b...",
    "requestType": "rental",
    "rentalStartDate": "2026-10-18T09:00:00Z",
    "rentalEndDate": "2026-10-22T17:00:00Z",
    "requestedQuantity": 1,
    "intendedUse": "High-throughput live cell confocal microscopy protocol.",
    "message": "We would like to book the instrument for our cell cycle assay."
  }
  ```
- **Validation**:
  - Rejects self-requests (requester cannot request their own listing).
  - Validates date overlaps against active approved bookings (`RENTAL_DATE_CONFLICT`).

### Get Sent Requests
`GET /api/v1/requests/sent`

### Get Received Requests
`GET /api/v1/requests/received`

### Owner Actions
- `PATCH /api/v1/requests/:id/approve`
  - Body: `{ "notes": "Authorized. Check in with lab manager." }`
- `PATCH /api/v1/requests/:id/reject`
  - Body: `{ "reason": "Conflict with core scheduled maintenance." }`

### Requester / Lifecycle Actions
- `PATCH /api/v1/requests/:id/cancel`
- `PATCH /api/v1/requests/:id/complete`

---

## 4. Media Upload Endpoints

### Generate Signed Cloudinary Upload Signature
`POST /api/v1/uploads/signature`
- Generates SHA1 signature and timestamp using server secret, allowing the mobile client to upload directly to Cloudinary without exposing credentials.

### Delete Cloudinary Asset
`DELETE /api/v1/uploads/:publicId`
- Verifies that `publicId` belongs to an equipment listing owned by the authenticated user before initiating Cloudinary destruction.

---

## 5. Notification Endpoints
- `GET /api/v1/notifications`: List notifications with `unreadCount`.
- `PATCH /api/v1/notifications/:id/read`: Mark single notification read.
- `PATCH /api/v1/notifications/read-all`: Mark all notifications read.
