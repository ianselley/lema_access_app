# Ticket and scanner changes — temporary resume checklist

Keep this file until user review. Each owner updates only their section. Do not redo completed work.

## Ownership
- Agent scanner: `scanner_active_screen.dart` and scanner-specific tests. All post-scan UI/behavior, camera lifecycle/recovery, pause during recent sheet.
- Agent detail: `ticket_detail_screen.dart`, extras edit widget if needed, ticket/scan services and ticket providers, detail tests. Extras editing persistence and undo confirmation. Backend extras RPC migration only in lema-backend if required.
- Agent models: models and model tests, shared reason translations/core failures. Verify database VIP contract, guest counts and shared ticket-name labels; backend snapshot migration only if required. Coordinate backend work with detail agent.
- Root: remaining screens/history, integration review, final checks.

## Scanner
- [x] Reservation count; one Reservado name; table schedule label; remove small top text.
- [x] Already-used transient only unless extras pending; close semantics; red invalid/orange pending extras, including last-scan row.
- [x] Remove outside-validity explanatory paragraph; retain explicit decision buttons.
- [x] Pause during recent activity; lock/resume cleanup before any frame; manual Reiniciar cámara button; queue reads current state and survives errors; controller-keyed camera rebuild.
- [x] Preserve returned extras snapshot after redemption and VIP/extras metadata in detail navigation.
- [x] Six scanner regression tests pass: colors/persistence; lock cleanup without frame, resume, failed-start reset and disposal; history QR blocking/resume; reservation labels/count/schedule and close; automatic dismissal with consumed extras; outside-validity modal.
- [x] Fixed modal/header and collapsing-badge overflow discovered by widget tests.
- Device follow-up: physical iPhone lock/unlock/background and camera indicator verification. Tests mock native camera; genuinely hung native platform calls cannot be safely canceled with Dart timeouts without risking competing camera sessions.

## Detail
- [x] Reservation count/title and distinct table/access schedules.
- [x] Extras editor with reversible selections, changed indicators, orange save/gray close; narrow phone scrolling and no-change close tested.
- [x] Undo access confirmation; cancel and confirm tested.
- [x] Atomic extras edit RPC with permission checks, ticket-scoped locks, stale count/retry protection and rollback. Created via supabase migration new in lema-backend: supabase/migrations/20260917133510_access_edit_ticket_add_ons.sql. Applied and verified on local Supabase only; deploy this migration with the app. Runnable rollback assertions: lema-backend/supabase/tests/access_edit_ticket_add_ons.sql.

## Models
- [x] Verified local Supabase shared snapshot already returns people_count_current and people_count_initial; no migration needed. All snapshot variants expose ticketTypeLabel and zoneOffer.guestCountLabel (current total, initial fallback), retain extras and validity.
- [x] Spanish mapping covers all local DB access reason/error codes, unknown statuses/categories/codes use Spanish fallback; core and scan failures expose displayMessage.
- [x] flutter test test/scan_models_test.dart: 7 passed, including all 4 snapshot variants, updated guest count, title deduplication, reason translation and safe error fallback.

## Integration (root)
- [x] All ticket-name renderers use shared VIP label; event/history/detail conversions retain VIP, extras and validity metadata. History result reasons and failure messages are Spanish.
- [x] Reviewed requested behavior and agent changes; scanner stale post-redemption snapshot fixed following independent review. Backend concurrency review completed; redemption-before-assignment lock ordering and ticket-scoped locks applied.
- [x] Final verification: all 37 Flutter tests passed; all changed Dart files formatted; git diff --check clean in both repositories. Flutter analyze has no errors/new issues, only 2 existing unused-parameter warnings and 1 existing null-aware-elements info in untouched login_screen.dart. SQL rollback assertion fixture passed after final scoped-lock change.
- Remaining release checks: deploy backend migration to target environment; physical iPhone lock/unlock, route exit/re-entry and camera reset QA. Native camera tests use a fake platform; hardware behavior was not verified.
