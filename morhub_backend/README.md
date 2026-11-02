# MorHub TU Backend (Node.js + MySQL)

Backend-only MVP package. The existing HTML/CSS/JavaScript frontend is intentionally **not included or modified** because the frontend is still being designed.

## Technology
- Node.js 20+
- Express.js REST API
- MySQL 8.0.16+ / InnoDB / utf8mb4
- bcrypt password hashing, JWT authentication
- QR Code check-in with one-use hashed tokens
- Queue management, in-app appointment reminders, analytics

## Important database note
The supplied `database/morhub_tu_schema.sql` is preserved from your upload. It contains `DROP DATABASE IF EXISTS morhub_tu;` near the beginning. **Do not run that file against an existing database unless you intentionally want to delete and recreate the database.**

For an existing `morhub_tu` database, take a backup and run only:

```bash
mysql -u root -p morhub_tu < database/migration_features.sql
```

The migration is additive and creates only `check_ins` and `queues`. It does not drop or recreate existing tables.

If this is a brand-new database with no data, you can initialize it using the supplied schema, then apply the migration. Review the DROP DATABASE statement first.

## Setup

1. Install Node.js 20+ and MySQL 8.0.16+.
2. Make sure your existing database is named `morhub_tu` and the original schema has been applied.
3. Run the additive migration shown above.
4. Install packages:

```bash
npm install
```

5. Copy `.env.example` to `.env` and fill in your MySQL credentials. Set `JWT_SECRET` to a random secret of at least 32 characters.
6. Start the API:

```bash
npm run dev
# or
npm start
```

7. Check `http://localhost:3000/api/health`. Expected response includes `"database":"connected"`.

## Create the first administrator

```bash
node scripts/create-admin.js "MorHub Admin" admin@example.com "ChangeThisPassword123!"
```

Use a strong password and do not share it. Staff accounts must have a matching row in `staff` and a valid `hospital_id`; patient registration automatically creates both `accounts` and `patients` rows.

## Environment variables

| Variable | Description |
|---|---|
| `PORT` | API port (default 3000) |
| `CLIENT_ORIGIN` | Allowed frontend origin; comma-separated origins are accepted |
| `DB_HOST` / `DB_PORT` | MySQL host and port |
| `DB_USER` / `DB_PASSWORD` | MySQL credentials |
| `DB_NAME` | Must match the existing database (`morhub_tu`) |
| `JWT_SECRET` | Random secret, minimum 32 characters |
| `JWT_EXPIRES_IN` | JWT lifetime (default `8h`) |
| `QR_TOKEN_TTL_MINUTES` | QR token lifetime (default 1440 minutes) |

## API overview

All protected endpoints require `Authorization: Bearer <JWT>`.

### Health and authentication

| Method | Endpoint | Access | Purpose |
|---|---|---|---|
| GET | `/api/health` | Public | API and database health |
| POST | `/api/auth/register` | Public | Register a patient account |
| POST | `/api/auth/login` | Public | Login and receive JWT |
| GET | `/api/auth/me` | Login | Current account |
| PATCH | `/api/auth/change-password` | Login | Change password |

Register JSON example:

```json
{
  "full_name": "Test Patient",
  "email": "patient@example.com",
  "password": "StrongPass123!",
  "phone": "0800000000"
}
```

Login JSON example:

```json
{ "email": "patient@example.com", "password": "StrongPass123!" }
```

### Doctors, schedules and appointments

| Method | Endpoint | Access | Purpose |
|---|---|---|---|
| GET | `/api/doctors` | Public | Search active doctors; optional `hospital_id`, `department_id`, `q` |
| GET | `/api/doctors/departments` | Public | List departments |
| GET | `/api/doctors/:id/schedules` | Login | Weekly schedule |
| POST | `/api/schedules` | Staff/Admin | Add doctor schedule |
| DELETE | `/api/schedules/:id` | Staff/Admin | Delete schedule |
| POST | `/api/schedules/leaves` | Staff/Admin | Add doctor leave |
| DELETE | `/api/schedules/leaves/:id` | Staff/Admin | Delete doctor leave |
| GET | `/api/appointments` | Login | Patient sees own appointments; staff sees own hospital |
| POST | `/api/appointments` | Patient | Create appointment request |
| PATCH | `/api/appointments/:id/cancel` | Login | Cancel appointment (owner or staff/admin) |
| PATCH | `/api/appointments/:id/confirm` | Staff/Admin | Confirm pending appointment |
| PATCH | `/api/appointments/:id/complete` | Staff/Admin | Mark appointment as seen |

Appointment JSON example:

```json
{
  "doctor_id": 1,
  "appt_date": "2026-12-15",
  "appt_time": "09:00:00",
  "symptom_note": "มีอาการปวดศีรษะ"
}
```

The existing MySQL trigger remains responsible for checking the doctor's schedule, leave date and slot capacity. The API returns a database validation error if a slot is invalid or full.

### QR check-in and queue

| Method | Endpoint | Access | Purpose |
|---|---|---|---|
| POST | `/api/checkins/:appointmentId/qr` | Patient/owner | Issue QR for confirmed appointment |
| POST | `/api/checkins/scan` | Staff/Admin | Scan token, check in and create queue |
| GET | `/api/queues?hospital_id=1&date=YYYY-MM-DD` | Staff/Admin | List daily queues |
| PATCH | `/api/queues/:id/call` | Staff/Admin | Call a waiting queue |
| PATCH | `/api/queues/:id/complete` | Staff/Admin | Complete queue and mark appointment seen |

QR scan JSON example:

```json
{ "token": "raw-token-returned-when-QR-was-issued" }
```

The raw QR token is returned only when issuing the QR. Only its SHA-256 hash is stored in MySQL. The token is one-use and expires. Check-in is restricted to the appointment date. The QR image is returned as a data URL for the future frontend to display.

### Notifications and analytics

| Method | Endpoint | Access | Purpose |
|---|---|---|---|
| GET | `/api/notifications` | Login | List notifications visible to the account |
| POST | `/api/notifications/:id/read` | Login | Mark notification as read |
| GET | `/api/analytics?from=YYYY-MM-DD&to=YYYY-MM-DD` | Staff/Admin | Appointment totals and department breakdown |

An in-app reminder job runs every 15 minutes and creates one notification for each upcoming appointment on the following day. This is an in-app reminder only; email/SMS/push delivery is not configured.

## Suggested test sequence

1. Create an admin account.
2. Ensure the database has at least one hospital, department, doctor, doctor schedule, and staff account linked to that hospital.
3. Register a patient and log in.
4. Create an appointment for a valid future date/time in the doctor's schedule.
5. Log in as staff and confirm the appointment.
6. On the appointment date, patient requests the QR token; staff submits it to `/api/checkins/scan`.
7. Staff views `/api/queues`, calls the queue and completes it.
8. Staff/admin checks `/api/analytics`.

## Security and MVP limitations

- Use fake/demo patient data only for presentations.
- Use HTTPS when deployed; keep `.env` private; never commit secrets.
- JWT is sent in the Authorization header. The future frontend should avoid storing sensitive tokens in insecure persistent storage.
- This MVP does not yet implement email/SMS delivery, password reset workflow, file upload, or full production-grade healthcare compliance review.
- The existing schema's appointment insert trigger checks capacity, but a production deployment should also harden concurrent booking with transactional slot locking.
- Staff permissions are scoped to their hospital for queue, schedule, appointment listing and confirmation.
