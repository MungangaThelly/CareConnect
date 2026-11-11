# CareConnect

CareConnect helps older adults stay connected to the people they choose. It coordinates optional check-ins, reminders, appointments, and family updates without tracking location, monitoring activity, or making medical decisions.

## Product brief

**People:** an older adult (the account owner), trusted family/friends, and invited care professionals. The older adult controls who can see and receive each kind of update.

**Promise:** make it easy to say “I’m okay” and easy for a trusted person to follow up when an expected check-in is missed.

**First release:** a daily check-in schedule with configurable grace period and escalation contacts; a shared family message board; medication reminders that record only “reminded” and an optional self-reported acknowledgement; appointment coordination; consent and access management.

**Boundaries:** check-ins are voluntary; no sensors, GPS, passive activity tracking, inferred health status, or automated diagnosis. A missed check-in is a request for a human to check in, not evidence of an emergency. Users are told who will be notified and when before enabling a schedule. Pause, change, revoke, export, and delete controls are available to the account owner.

**Business:** family subscription for household coordination; care-provider and municipal plans for managed groups, delegated staff access, and operational reporting. Institutional access is explicit, scoped, auditable, and never silently added to a family account.

**Measures:** successful check-ins, time from missed check-in to a human follow-up, reminder usefulness, consent comprehension, and user-reported sense of connection. Avoid optimizing for time in app or volume of alerts.

**Risks to validate:** missed alerts can create false reassurance; noisy alerts create fatigue; medication information is sensitive; older adults may face coercion. Use clear delivery status, retry/fallback channels, least-privilege roles, audit history, and straightforward consent withdrawal. Do not describe this product as emergency response or medication adherence verification.

## OTP foundation

The Erlang service uses a supervised in-memory store and an OTP `gen_server` for check-in schedules and due-alert processing. The API is intentionally a local/demo foundation; data is ephemeral and there is no authentication or durable storage yet. Before real use, add authenticated identity, per-person authorization, encrypted persistence, consent records, auditable access, rate limits, delivery-provider integration, retention/deletion workflows, and operational monitoring.

Run with `rebar3 shell`. The HTTP API listens on port 8080:

- `GET /health`
- `GET /api/households/demo/checkins`
- `POST /api/households/demo/checkins` with `{"person":"Alex","due_at":1794400000,"grace_seconds":1800}` (Unix seconds)
- `POST /api/households/demo/checkins/:id/complete`
- `GET /api/households/demo/updates`
- `POST /api/households/demo/updates` with `{"author":"Sam","message":"Appointment moved to Thursday"}`

Missed check-ins are emitted as demo alerts in the event log and visible in the check-in list. No automated emergency notification is sent.

## Prototype

Open `web/index.html` directly in a browser. It is a static, responsive product prototype with sample data and local-only interactions.
