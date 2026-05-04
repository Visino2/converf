# 🧪 Self-Contractor Feature Testing Checklist

## Test Device
- **Device**: Samsung Galaxy A56 (SM A566B)
- **Serial**: RZCY31VCKQK
- **App Status**: Building (Gradle assembleDebug in progress)
- **Estimated Build Time**: 5-10 minutes

---

## 📝 Testing Scenarios

### ✅ Scenario 1: Create Project with Self-Contractor

**Goal**: Verify that the "Self" contractor option appears and can be selected in Step 3

**Steps**:
1. Open app → Navigate to **Dashboard** (Product Owner view)
2. Click **"+ Create New Project"** button
3. Follow wizard steps:
   - **Step 1 (Type)**: Select any project type (e.g., "Construction", "Renovation")
   - **Step 2 (Details)**: Fill in project name, description
   - **Step 3 (Location)**: Select location
   - **Step 4 (Timeline & Budget)**: 
     - ⭐ **CRITICAL**: Look for **"Self" contractor card** at the TOP of contractor list
     - **Visual indicators**: 
       - Should show your avatar/initials in a crown badge 
       - Label should say "Self" or "Assign to Yourself"
       - Should appear BEFORE other contractors
     - Click on "Self" contractor card to select
     - Verify it's selected (highlighted/checked state)
   - **Step 5 (Specializations)**: Select required specializations
   - **Step 6 (Review)**: Review project details
4. Click **"Create Project"** button
5. Wait for success message

**Expected Results**:
- ✅ "Self" contractor card appears at top with crown badge
- ✅ Can click and select it without errors
- ✅ Project creation succeeds
- ✅ Project is created with you as the contractor

**Debug Logs to Check**:
```
Look for these logs in device terminal:
- "Self-contractor detected. Adding as project participant..."
- "Self-contractor participant added successfully"
```

---

### ✅ Scenario 2: Verify Schedule Creation Access

**Goal**: Confirm that as a self-contractor, you can now create schedules

**Steps**:
1. From previous test, open the created project
2. Navigate to **"Schedule"** or **"Project Details"** tab
3. Look for **"Create Schedule"** button or **"Schedule"** section
4. **Previously blocked**: Schedule creation would NOT be available
5. **Now should work**: Click on schedule section/button

**Expected Results**:
- ✅ Schedule creation button/section is VISIBLE and ENABLED
- ✅ Can open schedule creation flow
- ✅ No "Access Denied" or "Not Authorized" errors

**Debug Logs to Check**:
```
Look for HTTP calls:
- POST /api/v1/projects/{projectId}/schedule
- Should return 200 OK with schedule data
```

---

### ✅ Scenario 3: Create and Submit Schedule

**Goal**: Verify full schedule workflow works for self-contractors

**Steps**:
1. From Scenario 2, proceed with schedule creation
2. System should:
   - Create a blank schedule in "draft" status
   - Show schedule builder UI
3. **Add Phases** (optional for this test):
   - Click "+ Add Phase"
   - Enter phase name (e.g., "Phase 1: Foundation")
   - Optionally add activities
4. **Submit Schedule**:
   - Click "Submit for Approval" or "Submit Schedule" button
   - A dialog should appear asking for contractor notes (optional)
   - Confirm submission
5. Wait for success

**Expected Results**:
- ✅ Schedule created successfully
- ✅ Can add phases and activities
- ✅ Schedule submission succeeds
- ✅ Schedule status changes from "draft" to "submitted"
- ✅ Schedule becomes locked (read-only)

**Debug Logs to Check**:
```
Look for HTTP calls:
- POST /api/v1/projects/{projectId}/schedule (create)
- POST /api/v1/schedules/{scheduleId}/submit (submit)
- Both should return 200 OK
```

---

## 🔍 Things to Verify During Testing

### Visual Elements
- [ ] Self contractor card has crown badge/star icon
- [ ] Self contractor name displayed correctly (handle single names like "Daniel")
- [ ] Self contractor appears at top of list
- [ ] Selected state is visually distinct

### Functional Elements
- [ ] Can select self contractor in Step 3
- [ ] Project creation completes without errors
- [ ] Schedule becomes available after project creation
- [ ] Can create and submit schedules
- [ ] No "not authorized" or "access denied" errors

### API Calls (Check Device Logs)
- [ ] `POST /api/v1/projects/{projectId}/participants` called after Step 3
- [ ] Response is 200 OK
- [ ] Contractor ID matches current user ID

---

## 📱 Device Log Commands

### Monitor app logs in real-time:
```bash
adb logcat -s flutter | grep -E "(Self-contractor|ERROR|Exception)"
```

### Get all logs from current session:
```bash
adb logcat -d | tail -200
```

### Clear logs before testing:
```bash
adb logcat -c
```

---

## ❌ Expected Errors (OLD BEHAVIOR - Should NOT see these)

These are the errors that SHOULD NO LONGER APPEAR:

1. ❌ "Unable to create schedule" when logged in as contractor
2. ❌ "You don't have permission to create schedules"
3. ❌ "Schedule not available" for self-contractor projects
4. ❌ "RangeError" when contractor name is single word (e.g., "Daniel")
5. ❌ "Not found" 404 errors for project participants API

---

## ✅ Expected Success Indicators (NEW BEHAVIOR)

1. ✅ Self contractor card appears at top of Step 3
2. ✅ Can select self contractor
3. ✅ Project creation succeeds
4. ✅ Schedule is immediately available
5. ✅ Can create and submit schedules as self-contractor
6. ✅ All operations return 200 OK responses

---

## 🛠️ Troubleshooting

### If app crashes or won't launch:
```bash
# Clear app cache
adb shell pm clear com.converf.app

# Check device logs
adb logcat -d | tail -100

# Restart adb
adb kill-server && adb start-server && sleep 2
flutter run -d RZCY31VCKQK
```

### If you see missing asset errors:
```
Unable to load asset: "assets/images/field_inspection.svg"
```
- This is a UI asset issue, not related to self-contractor feature
- App should still function

### If API calls fail:
```bash
# Check if device can reach API
adb shell ping api-dev.converf.com

# Verify network connectivity
adb shell ip route
```

---

## 📊 Testing Results Template

After completing the tests, document results:

```
TEST DATE: _______________
DEVICE: Samsung Galaxy A56
BUILD: _______________

Scenario 1 (Self-Contractor Card): [PASS/FAIL]
- Notes: _______________

Scenario 2 (Schedule Access): [PASS/FAIL]
- Notes: _______________

Scenario 3 (Create & Submit): [PASS/FAIL]
- Notes: _______________

Issues Found: 
- _______________
- _______________

API Logs Verified:
- [YES/NO] Participant endpoint called
- [YES/NO] Schedule creation endpoint called
- [YES/NO] All endpoints returned 200 OK
```

---

## 💡 Key Points

✨ **What was fixed**:
1. Self-contractor selection UI with visual badge
2. RangeError for single-name contractors (initials handling)
3. Automatic project participant registration when self-contractor selected
4. Schedule availability after self-contractor project creation

🎯 **Current Code Changes**:
- `lib/screens/product_owner/widgets/dashboard/new_project/steps/step_timeline.dart` - Self-contractor card UI
- `lib/features/projects/repositories/project_repository.dart` - Add participant API call
- `lib/features/projects/providers/project_providers.dart` - Participant registration logic
- `lib/screens/product_owner/widgets/dashboard/new_project/new_project_wizard.dart` - Integration

📍 **Test Status**: ⏳ Waiting for Flutter build to complete on device
- Build started: `flutter run -d RZCY31VCKQK`
- Estimated completion: 5-10 minutes
- Terminal ID: `5b37b169-b52f-4c45-954e-6f995ff5e35f`

