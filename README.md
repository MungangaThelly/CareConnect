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

## Swedish problem to validate

**Candidate need:** older adults and their chosen relatives may not get timely, clear information when a home-care visit is delayed, changed, or missed, and may not know whom to contact for follow-up. A consent-controlled update shared with the older adult, authorized relatives, and the care team could address this coordination gap.

This direction is informed by reported issues, not proof of an unmet market or product demand. Linköping's Older Adults Ombudsman 2024 report lists complaints about visits arriving at unexpected times without notice, difficulty reaching home-care services outside phone hours, lack of follow-up, communication gaps, and information-transfer failures between staff roles. A Swedish government inquiry (SOU 2020:70) describes relatives taking responsibility for contacting multiple care professionals and feeling unsure who is responsible or whom to contact.

**Possible first workflow:** show the planned visit window and send a simple delay or cancellation update, with a clear route for follow-up. The older adult chooses which relatives can see these updates. Keep the feature focused on coordination and visit status; do not use it as a clinical record or emergency-alert system.

**Validation needed:** ask older adults, relatives, and one municipal or private home-care provider how visit changes are communicated now, what information may be shared with relatives, which existing systems handle this, and whether the proposed workflow would be useful. The current evidence is limited and includes a local Linköping report; it does not establish national prevalence, demand, or that an app is the right solution.

Sources: [Linköping Older Adults Ombudsman, annual report 2024](https://www.linkoping.se/contentassets/lanksamling-aldreombudsmannens-rapport/aldreombudsmannens-arsrapport-2024.pdf); [SOU 2020:70, Fast omsorgskontakt i hemtjänsten](https://www.riksdagen.se/sv/dokument-och-lagar/dokument/statens-offentliga-utredningar/fast-omsorgskontakt-i-hemtjansten_h8b370/html/).

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
