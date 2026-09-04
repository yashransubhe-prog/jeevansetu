# JeevanSetu Beast Build Prompt

Build JeevanSetu as a premium, judge-ready disaster-response product, not a collection of disconnected demo screens.

## Non-negotiable product rule
The five user roles — Citizen, Rescue Team, Authority, Volunteer and Organization — must operate on one shared incident lifecycle. A citizen report or SOS must immediately become visible to the other relevant roles in the same app session. Every action taken by another role must update that same incident status, timeline, communication room and assignment state.

## Shared lifecycle
Citizen submits report/SOS → Authority verifies and activates warning → Rescue accepts and dispatches → Volunteer supports evacuation/check-in → Organization reserves shelter/medical/food/transport → incident progresses to safe/recovered.

Every incident must have one stable ID, source, priority, location, current status, assigned team, progress and event timeline. Role actions must never create disconnected copies of the incident.

## UX target
Use the visual quality and workflow clarity of the JeevanSetu infographic as the product standard: premium mobile layout, real maps, meaningful imagery, live status chips, spatial context, strong typography, rich but uncluttered cards, smooth transitions, visual hierarchy and clear role-to-role handoff.

Avoid childish layouts, giant empty areas, repetitive white cards, fake static A-to-B route illustrations, raw debug values, broken images, low-contrast text and decorative UI with no interaction.

## Role experiences
Keep the existing role dashboards as the visual foundation, but make every inner tab world-class and role-specific.

Rescue Team: tactical mission map, triage queue, dispatch, safest responder corridor, aerial scan, medical handoff, mission progress, field command voice/video and rescue toolkit.

Authority: district command map, verification queue, citizen evidence, warning broadcast, risk-zone perimeter, district resources, decision log, evidence confidence and secure channels.

Volunteer: task marketplace, ground missions, household check-in, evacuation support, relief delivery, verified photo evidence, checkpoint/QR flow, offline mission pack and volunteer communications.

Organization: shelter occupancy, medical capacity, food/water inventory, transport dispatch, incoming resource requests, partner network, relief vouchers, logistics map and fulfillment progress.

Citizen: retain current foundation but ensure reports feed the shared network and later status updates can be represented consistently.

## Maps and intelligence
Use real interactive OpenStreetMap tiles through flutter_map. Show incident markers, hazard polygon, safe corridor polyline, responder/hub markers and route controls. Intelligence screens should combine rainfall, soil saturation, slope movement, citizen evidence and confidence with an explainable risk breakdown.

## Communications
Every active incident has a response room. Support in-app voice and video call UI, operational chat, role sender identity, live status and a synchronized event timeline.

## Prototype realism
Interactions must visibly change app state. Buttons must dispatch, verify, accept, reserve, send messages, open calls, open maps, simulate scans or update incident status. Do not use dead buttons. External integrations that are not truly live should be presented as prototype integrations, not falsely claimed as deployed services.

## Performance
Favor native Flutter widgets, lightweight animation, ResizeImage/caching for remote images, limited rebuild scope, ValueNotifier/state shared across screens and real map widgets. Avoid unnecessary packages and heavy continuous animations.

## Judge demo goal
A judge should be able to perform this exact flow in under three minutes: Citizen submits an incident → switch to Authority and verify it → switch to Rescue and dispatch → open response-room call/chat → switch to Volunteer and accept support task → switch to Organization and reserve relief capacity → return to any operational screen and see the same incident ID with updated state and timeline.
