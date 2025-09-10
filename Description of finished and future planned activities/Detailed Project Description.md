City View Nursery and Primary School Website

Overview
The project is a Flutter Web app backed by Firebase (Auth, Firestore, Storage, Functions) and hosted on Firebase Hosting. It provides a public site, an admin CMS, and a parent/student portal.

Key Tech
- Flutter Web
- GoRouter routing, Provider state
- Firebase: Auth, Firestore, Storage, Functions
- Cloud Functions (Node 20, TypeScript)

Project Structure (high level)
- lib/app.dart: Central app router and theming
- lib/core: bootstrap, auth controller, theme controller
- lib/features/public: public pages (home, about, academics, sports, health, achievements, blog, gallery, contact), plus admissions, events
- lib/features/admin: admin screens (dashboard, blog, pages, gallery, theme, users, live, admissions, events, homework, attendance, results)
- lib/features/portal: portal login/home, homework, attendance, results, print view
- functions/src: Cloud Functions index (contact, prerender, sitemap, Paystack payments)
- firestore.rules, firestore.indexes.json: security and indexes
- README.md: setup notes including Paystack

Authentication & Roles
- Auth via Firebase Auth email/password
- Roles are stored in Firestore `users/{uid}.role` with values: `super_admin`, `content_manager`, `blogger`
- Admin routes enforce role-based redirects; portal routes require auth

Completed Features (as of this document)
Public
- Admissions: form with Firestore submission, reference ID, payment flow page
- Events: public list page (upcoming), nav links added for Events and Admissions

Admin
- Dashboard with navigation cards
- Theme editor, Live stream, Users, Pages/CMS, Gallery, Blog (existing)
- Admissions admin list with status updates and payment status visibility
- Events admin CRUD (create/edit/delete)
- Homework admin create/update
- Attendance admin entry
- Results/Report cards admin create/update with subjects map

Portal (Parent/Student)
- Login and home
- Homework list auto-filtered by `users/{uid}.className`
- Attendance list with date-range, auto-filtered by class
- Results list and print-friendly view `/portal/results/:id/print`

Cloud Functions
- Contact callable
- Prerender HTTP endpoint (for bots)
- Sitemap scheduled job (migrate to v2 onSchedule when convenient)
- Paystack integration:
  - `initiateAdmissionPayment` (callable) initializes payment
  - `paystackWebhook` (HTTP) verifies and updates admissions payment status

Security Rules (Firestore)
- Public read collections: `events`, `settings`, `blogPosts` (published), `images`
- Admissions: public create; read/update/delete by `super_admin` or `content_manager`
- Homework & Attendance: read if signed-in; admin write
- Results: only the owning `studentUid` can read; admin write
- Users: admin only

Indexes
- Admissions: status + createdAt
- Events: startDate
- Attendance: date
- Results: studentUid + createdAt

Navigation & Routes (selected)
- Public: `/`, `/about`, `/academics`, `/sports`, `/health-diet`, `/achievements`, `/blog`, `/blog/:slug`, `/gallery`, `/contact`, `/events`, `/admissions`, `/admissions/pay/:id`
- Admin: `/admin`, `/admin/login`, `/admin/pages`, `/admin/theme`, `/admin/blog`, `/admin/gallery`, `/admin/live`, `/admin/users`, `/admin/admissions`, `/admin/events`, `/admin/portal/homework`, `/admin/portal/attendance`, `/admin/portal/results`
- Portal: `/portal/login`, `/portal`, `/portal/homework`, `/portal/attendance`, `/portal/results`, `/portal/results/:id/print`

Deployment & Setup (summary)
1) Flutter web run: `flutter run` (clean URLs enabled)
2) Firestore: deploy rules and indexes
   - `firebase deploy --only firestore:rules,firestore:indexes`
3) Functions: Node 20, TypeScript
   - `cd functions && npm install && npm run build`
   - Paystack secret: `firebase functions:config:set paystack.secret_key="sk_test_xxx"`
   - Deploy: `firebase deploy --only functions`
4) Paystack webhook URL: `https://us-central1-city-view-8e128.cloudfunctions.net/paystackWebhook`

Known Items / Polishing
- Replace Unsplash demo images with local assets
- Improve public Events card visuals
- Add validation/messages UX in admin editors

Future Planned Activities
Short Term
- Migrate `generateSitemap` to v2 `onSchedule` API
- Add teacher role and per-class posting for homework/attendance
- Admissions: receipt PDF and email notification on payment success
- Events: RSVP with reminders (email/SMS/WhatsApp)

Medium Term
- Site-wide search (pages, blog, staff, documents)
- Editorial workflow (draft → review → publish) with approvals
- Multilingual (English + local language), including localized slugs and SEO tags
- Comprehensive SEO (schema.org, OG/Twitter, sitemaps for pages/blog/events)

Long Term
- Full Parent/Student portal expansions: fees history, term calendars, messaging
- Staff directory and protected resources repository
- Backups/versioning for media and CMS content

Operational Notes
- Roles: set `users/{uid}.role` to `super_admin`, `content_manager`, or `blogger`
- Admissions amount: set `admissions/{id}.amount` (NGN) and ensure `email` is present
- Payments require Paystack secret config and webhook setup

Change Log (manual)
- 2025-09-05: Admissions, Events, Portal (Homework/Attendance/Results), Paystack scaffolding added; navigation updated; rules/indexes deployed.


