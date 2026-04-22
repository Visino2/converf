# Bid & Schedule API Reference - Mobile vs WebApp

## 🔷 Overview
Complete API specification for how contractors submit bids and create/submit schedules for projects.

---

## 📋 Part 1: BIDDING ENDPOINTS

### Endpoint 1: Submit Bid to Project
**Endpoint:** `POST /api/v1/projects/{projectId}/bids`

#### Request Payload
```json
{
  "amount": 5000.50,
  "proposal": "I can complete this project in 2 weeks...",
  "schedule_id": "uuid-required",
  "duration": "2 weeks",
  "payment_preference": "milestone",
  "milestones": [
    { "name": "Phase 1", "amount": 2500, "date": "2026-05-15" }
  ],
  "team_members": ["John Doe", "Jane Smith"],
  "equipment": ["Excavator", "Bulldozer"],
  "portfolio_projects": ["proj-uuid-1", "proj-uuid-2"],
  "certifications": [
    { "name": "OSHA Safety", "date": "2026-01-15" }
  ],
  "documents[]": "[File Upload if documentPaths provided]"
}
```

#### Response
```json
{
  "status": true,
  "message": "Bid submitted successfully",
  "data": {
    "id": "bid-uuid-123",
    "project_id": "project-uuid-456",
    "contractor_id": "contractor-uuid-789",
    "amount": 5000.50,
    "proposal": "...",
    "status": "pending",
    "created_at": "2026-04-22T10:30:00Z",
    "updated_at": "2026-04-22T10:30:00Z"
  }
}
```

#### Mobile Implementation
**File:** `lib/features/marketplace/repositories/marketplace_repository.dart` (line 50)

```dart
Future<BidResponse> submitBid(String projectId, SubmitBidPayload payload) async {
  dynamic data;
  if (payload.documentPaths != null && payload.documentPaths!.isNotEmpty) {
    final formData = FormData.fromMap(payload.toJson());
    for (final path in payload.documentPaths!) {
      formData.files.add(MapEntry(
        'documents[]',
        await MultipartFile.fromFile(path),
      ));
    }
    data = formData;
  } else {
    data = payload.toJson();
  }

  final response = await _apiClient.post(
    '/api/v1/projects/$projectId/bids',
    data: data,
  );
  if (response.data is! Map<String, dynamic>) {
      throw Exception("Invalid response format from server");
  }
  final responseData = response.data as Map<String, dynamic>;
  if (responseData['status'] == false) {
     throw Exception(responseData['message'] ?? 'Failed to submit bid');
  }
  return BidResponse.fromJson(responseData);
}
```

#### SubmitBidPayload Model
**File:** `lib/features/marketplace/models/marketplace_responses.dart` (line 86)

```dart
class SubmitBidPayload {
  final double amount;
  final String proposal;
  final String? scheduleId;
  final String? duration;
  final String? paymentPreference;
  final List<Map<String, dynamic>>? milestones;
  final List<String>? teamMembers;
  final List<String>? equipment;
  final List<String>? portfolioProjects;
  final List<Map<String, dynamic>>? certifications;
  final List<String>? documentPaths;

  const SubmitBidPayload({
    required this.amount,
    required this.proposal,
    this.scheduleId,
    this.duration,
    this.paymentPreference,
    this.milestones,
    this.teamMembers,
    this.equipment,
    this.portfolioProjects,
    this.certifications,
    this.documentPaths,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'proposal': proposal,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (duration != null) 'duration': duration,
      if (paymentPreference != null) 'payment_preference': paymentPreference,
      if (milestones != null) 'milestones': milestones,
      if (teamMembers != null) 'team_members': teamMembers,
      if (equipment != null) 'equipment': equipment,
      if (portfolioProjects != null) 'portfolio_projects': portfolioProjects,
      if (certifications != null) 'certifications': certifications,
    };
  }
}
```

---

## 📅 Part 2: SCHEDULE ENDPOINTS

### Endpoint 2: Create Schedule from Bid
**Endpoint:** `POST /api/v1/bids/{bidId}/schedule`

#### Request Payload
```json
{
  "contractor_notes": "Optional initial notes from contractor"
}
```

#### Response
```json
{
  "id": "schedule-uuid-789",
  "project_id": "project-uuid-456",
  "bid_id": "bid-uuid-123",
  "status": "draft",
  "status_label": "Draft",
  "contractor_id": "contractor-uuid-789",
  "contractor_notes": "Optional initial notes",
  "is_locked": false,
  "is_editable": true,
  "phases": [],
  "revision_history": [],
  "created_at": "2026-04-22T10:30:00Z",
  "updated_at": "2026-04-22T10:30:00Z"
}
```

#### Mobile Implementation
**File:** `lib/features/projects/repositories/schedule_repository.dart` (line 88)

```dart
Future<Schedule> createScheduleFromBid(String bidId, String contractorNotes) async {
  final response = await _apiClient.post(
    '/api/v1/bids/$bidId/schedule',
    data: {
      'contractor_notes': contractorNotes,
    },
  );
  if (response.data is Map<String, dynamic>) {
    final map = response.data['data'] ?? response.data;
    return Schedule.fromJson(map);
  }
  throw Exception("Invalid response format from server");
}
```

---

### Endpoint 3: Create Schedule from Project (Self-Contractor)
**Endpoint:** `POST /api/v1/projects/{projectId}/schedule`

#### Request Payload
```json
{
  "contractor_notes": "Optional initial notes"
}
```

#### Response
Same as Endpoint 2 (Schedule object)

#### Mobile Implementation
**File:** `lib/features/projects/repositories/schedule_repository.dart` (line 108)

```dart
Future<Schedule> createScheduleFromProject(String projectId, String contractorNotes) async {
  final response = await _apiClient.post(
    '/api/v1/projects/$projectId/schedule',
    data: {
      'contractor_notes': contractorNotes,
    },
  );
  if (response.data is Map<String, dynamic>) {
    final map = response.data['data'] ?? response.data;
    return Schedule.fromJson(map);
  }
  throw Exception("Invalid response format from server");
}
```

---

### Endpoint 4: Submit Schedule from Bid
**Endpoint:** `POST /api/v1/bids/{bidId}/schedule/submit`

#### Request Payload
```json
{
  "contractor_notes": "Final notes before submission"
}
```

#### Response
```
Status: 200 OK
(No body content typically)
```

#### Mobile Implementation
**File:** `lib/features/projects/repositories/schedule_repository.dart` (line 103)

```dart
Future<void> submitScheduleFromBid(String bidId, String contractorNotes) async {
  await _apiClient.post(
    '/api/v1/bids/$bidId/schedule/submit',
    data: {'contractor_notes': contractorNotes},
  );
}
```

---

### Endpoint 5: Submit Generic Schedule
**Endpoint:** `POST /api/v1/schedules/{scheduleId}/submit`

#### Request Payload
```json
{
  "contractor_notes": "Final notes"
}
```

#### Response
```
Status: 200 OK
```

#### Mobile Implementation
**File:** `lib/features/projects/repositories/schedule_repository.dart` (line 117)

```dart
Future<void> submitSchedule(String scheduleId, String contractorNotes) async {
  await _apiClient.post(
    '/api/v1/schedules/$scheduleId/submit',
    data: {'contractor_notes': contractorNotes},
  );
}
```

---

### Endpoint 6: Create Phase in Schedule
**Endpoint:** `POST /api/v1/schedules/{scheduleId}/phases`

#### Request Payload
```json
{
  "name": "Phase 1: Foundation",
  "order": 1,
  "start_date": "2026-05-01",
  "end_date": "2026-06-01",
  "description": "Setting up the foundation"
}
```

#### Response
```json
{
  "id": "phase-uuid-111",
  "schedule_id": "schedule-uuid-789",
  "name": "Phase 1: Foundation",
  "order": 1,
  "activities_count": 0,
  "created_at": "2026-04-22T10:30:00Z"
}
```

#### Mobile Implementation
**File:** `lib/features/projects/repositories/schedule_repository.dart`

```dart
Future<SchedulePhase> createPhase(String scheduleId, SchedulePhasePayload payload) async {
  final response = await _apiClient.post(
    '/api/v1/schedules/$scheduleId/phases',
    data: payload.toJson(),
  );
  if (response.data is Map<String, dynamic>) {
    final map = response.data['data'] ?? response.data;
    return SchedulePhase.fromJson(map);
  }
  throw Exception("Invalid response format from server");
}
```

---

### Endpoint 7: Create Activity in Phase
**Endpoint:** `POST /api/v1/schedules/{scheduleId}/phases/{phaseId}/activities`

#### Request Payload
```json
{
  "title": "Excavation",
  "activity_code": "EXC001",
  "deadline": "2026-05-15",
  "standard_duration_days": 5,
  "assigned_to": "contractor-uuid-789",
  "description": "Begin excavation work"
}
```

#### Response
```json
{
  "id": "activity-uuid-222",
  "phase_id": "phase-uuid-111",
  "title": "Excavation",
  "activity_code": "EXC001",
  "deadline": "2026-05-15",
  "standard_duration_days": 5,
  "assigned_to": "contractor-uuid-789",
  "created_at": "2026-04-22T10:30:00Z"
}
```

---

### Endpoint 8: Approve Schedule (Project Owner)
**Endpoint:** `PATCH /api/v1/schedules/{scheduleId}/approve`

#### Request Payload
```json
{
  "owner_feedback": "Looks good, approved!"
}
```

#### Response
```
Status: 200 OK
```

---

### Endpoint 9: Request Schedule Revision (Project Owner)
**Endpoint:** `PATCH /api/v1/schedules/{scheduleId}/request-revision`

#### Request Payload
```json
{
  "owner_feedback": "Please adjust the timeline for Phase 2"
}
```

#### Response
```
Status: 200 OK
```

---

### Endpoint 10: Reject Schedule (Project Owner)
**Endpoint:** `PATCH /api/v1/schedules/{scheduleId}/reject`

#### Request Payload
```json
{
  "owner_feedback": "This doesn't meet our requirements"
}
```

#### Response
```
Status: 200 OK
```

---

## 🔄 Schedule Status Flow

```
┌─────────────────────────────────────────────────────────┐
│                  SCHEDULE LIFECYCLE                      │
└─────────────────────────────────────────────────────────┘

  draft (Initial state)
    ├─ Contractor edits, adds phases/activities
    ├─ Can save drafts without submitting
    └─ [Submit] → submitted

  submitted
    ├─ Locked - Contractor cannot edit
    ├─ Owner can: approve, request-revision, reject
    ├─ [Approve] → approved
    ├─ [Request Revision] → revision_requested
    └─ [Reject] → rejected

  revision_requested
    ├─ Contractor can edit again
    ├─ After changes: [Resubmit] → resubmitted
    └─ (Same as submitted, awaiting owner review)

  approved
    ├─ Final state - Contractor confirmed
    ├─ Cannot edit
    └─ Work proceeds per schedule

  rejected
    ├─ Final state - Contract may be terminated
    └─ Contractor can abandon or renegotiate
```

---

## 🛠️ Schedule Editable/Locked States

| Status | isEditable | isLocked | Can Submit | Can Edit |
|--------|-----------|---------|-----------|----------|
| draft | ✅ true | ❌ false | ✅ Yes | ✅ Yes |
| submitted | ❌ false | ✅ true | ❌ No | ❌ No |
| revision_requested | ✅ true | ❌ false | ✅ Yes | ✅ Yes |
| resubmitted | ❌ false | ✅ true | ❌ No | ❌ No |
| approved | ❌ false | ✅ true | ❌ No | ❌ No |
| rejected | ❌ false | ✅ true | ❌ No | ❌ No |

---

## 📱 Mobile App Implementation Files

### Core Files
- **`lib/features/marketplace/repositories/marketplace_repository.dart`** - Bid submission
- **`lib/features/projects/repositories/schedule_repository.dart`** - Schedule CRUD operations
- **`lib/features/projects/repositories/bidding_repository.dart`** - Bid-related operations
- **`lib/features/marketplace/models/marketplace_responses.dart`** - Bid payload models
- **`lib/features/projects/models/schedule.dart`** - Schedule data models

### Providers (State Management)
- **`lib/features/marketplace/providers/marketplace_providers.dart`** - Bid submission Riverpod
- **`lib/features/projects/providers/bidding_providers.dart`** - Bidding business logic
- **`lib/features/projects/providers/schedule_providers.dart`** - Schedule actions (CRUD, submit, etc.)

---

## 🚀 Quick Integration Checklist

- [ ] Use `POST /api/v1/projects/{projectId}/bids` for bid submission
- [ ] Include `SubmitBidPayload` with amount, proposal, and optional fields
- [ ] After bid approved, use `POST /api/v1/bids/{bidId}/schedule` to create schedule
- [ ] Let contractor add phases and activities in draft mode
- [ ] When ready, call `POST /api/v1/bids/{bidId}/schedule/submit`
- [ ] Owner receives notifications for pending schedules
- [ ] Owner can approve/request-revision/reject using PATCH endpoints
- [ ] Schedule becomes locked once submitted (contractor can't edit)
- [ ] Full revision cycle supported: submitted → revision_requested → resubmitted → approved

---

## ⚠️ Key Notes for Mobile App

1. **Schedule_ID is REQUIRED**: 
   - Contractors MUST select/create a schedule before submitting a bid
   - The `schedule_id` field must be included in `POST /api/v1/projects/{projectId}/bids`
   - If schedule_id is not provided, the API will return: `"The schedule id field is required."`

2. **Self-Contractor Flow**: When contractor is selected as "Self" (user creating project):
   - Endpoint: `POST /api/v1/projects/{projectId}/schedule`
   - **NOT** a bid-based schedule
   - User is both owner and contractor

3. **Schedule from Bid**: When contractor submits bid, then creates schedule:
   - First: Submit bid → `POST /api/v1/projects/{projectId}/bids` (with schedule_id)
   - Then: Create schedule → `POST /api/v1/bids/{bidId}/schedule`
   - Finally: Submit → `POST /api/v1/bids/{bidId}/schedule/submit`

4. **Handling Errors**: 
   - Check `response.data['status']` for bid endpoint
   - Bid endpoint returns wrapped response: `{ status, message, data }`
   - Schedule endpoints return data directly

5. **Multipart/Form Data**: 
   - If `documentPaths` provided in bid, use `FormData`
   - Otherwise, use JSON payload

