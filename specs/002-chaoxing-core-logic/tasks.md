# Tasks: Chaoxing Core Logic Implementation

**Input**: Design documents from `/specs/002-chaoxing-core-logic/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are included as this is a TDD project with ≥80% coverage requirement.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **Flutter multi-platform**: `lib/` for Dart code, `test/` for tests
- **Platform-specific**: `android/`, `ios/`, `windows/`, `web/` for platform code
- **Architecture layers**: `lib/data/`, `lib/domain/`, `lib/presentation/`
- Paths shown below follow Flutter clean architecture pattern

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialization and basic structure

- [x] T001 Create Flutter project structure per implementation plan
- [x] T002 Initialize Flutter project with required dependencies (dio, provider, shared_preferences, hive, mockito)
- [x] T003 [P] Configure Flutter linting and formatting tools in analysis_options.yaml
- [x] T004 [P] Setup platform-specific configurations for Android/iOS/Windows
- [x] T005 [P] Create project documentation structure in docs/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Flutter infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Flutter-specific foundational tasks:

- [x] T006 [P] Setup network layer with Dio in lib/core/network/dio_client.dart
- [x] T007 [P] Implement AES encryption service in lib/core/crypto/aes_cipher.dart
- [x] T008 [P] Create session manager singleton in lib/core/session/session_manager.dart
- [x] T009 [P] Setup local storage with SharedPreferences in lib/data/datasources/local/shared_prefs_datasource.dart
- [x] T010 [P] Setup Hive storage for complex data in lib/data/datasources/local/hive_datasource.dart
- [x] T011 [P] Configure error handling and logging infrastructure in lib/core/errors/
- [x] T012 [P] Setup state management with Provider in lib/presentation/providers/
- [x] T013 [P] Create base UI components and theme in lib/presentation/widgets/
- [x] T014 [P] Setup navigation and routing in lib/app/routes.dart
- [ ] T015 [P] Create rate limiter utility in lib/core/utils/rate_limiter.dart
- [ ] T016 [P] Implement data parsing utilities in lib/core/utils/data_parser.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - User Authentication and Course Access (Priority: P1) 🎯 MVP

**Goal**: Enable users to log into Chaoxing platform and access their course list

**Independent Test**: Can be fully tested by providing valid credentials and verifying successful login with course list retrieval

### Tests for User Story 1 ⚠️

**NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T017 [P] [US1] Unit test for User entity in test/unit/entities/user_test.dart
- [ ] T018 [P] [US1] Unit test for Course entity in test/unit/entities/course_test.dart
- [ ] T019 [P] [US1] Unit test for AES encryption in test/unit/core/aes_cipher_test.dart
- [ ] T020 [P] [US1] Unit test for session manager in test/unit/core/session_manager_test.dart
- [ ] T021 [P] [US1] Unit test for auth service in test/unit/services/auth_service_test.dart
- [ ] T022 [P] [US1] Unit test for course service in test/unit/services/course_service_test.dart
- [ ] T023 [P] [US1] Widget test for login page in test/widget/pages/login_page_test.dart
- [ ] T024 [P] [US1] Widget test for course list page in test/widget/pages/course_list_page_test.dart
- [ ] T025 [P] [US1] Integration test for login flow in test/integration/auth_integration_test.dart
- [ ] T026 [P] [US1] Integration test for course list retrieval in test/integration/course_integration_test.dart

### Implementation for User Story 1

- [x] T027 [P] [US1] Create User entity in lib/domain/entities/user.dart
- [x] T028 [P] [US1] Create Course entity in lib/domain/entities/course.dart
- [x] T029 [P] [US1] Create Session entity in lib/domain/entities/session.dart
- [x] T030 [US1] Implement User model in lib/data/models/user_model.dart (depends on T027)
- [x] T031 [US1] Implement Course model in lib/data/models/course_model.dart (depends on T028)
- [x] T032 [US1] Implement Session model in lib/data/models/session_model.dart (depends on T029)
- [x] T033 [US1] Create User repository interface in lib/domain/repositories/user_repository.dart
- [x] T034 [US1] Create Course repository interface in lib/domain/repositories/course_repository.dart
- [x] T035 [US1] Implement User repository in lib/data/repositories/user_repository_impl.dart (depends on T033)
- [x] T036 [US1] Implement Course repository in lib/data/repositories/course_repository_impl.dart (depends on T034)
- [x] T037 [US1] Create Login use case in lib/domain/usecases/login_usecase.dart
- [x] T038 [US1] Create GetCourseList use case in lib/domain/usecases/get_course_list_usecase.dart
- [x] T039 [US1] Implement Auth service in lib/services/auth/auth_service.dart
- [x] T040 [US1] Implement Course service in lib/services/course/course_service.dart
- [x] T041 [US1] Create Auth provider in lib/presentation/providers/auth_provider.dart
- [x] T042 [US1] Create Course provider in lib/presentation/providers/course_provider.dart
- [x] T043 [US1] Implement Login page UI in lib/presentation/pages/auth/login_page.dart
- [x] T044 [US1] Implement Course list page UI in lib/presentation/pages/course/course_list_page.dart
- [x] T045 [US1] Add authentication validation and error handling
- [x] T046 [US1] Add logging for authentication operations

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Video Learning Task Completion (Priority: P1)

**Goal**: Enable users to complete video learning tasks with proper playback controls and progress tracking

**Independent Test**: Can be fully tested by selecting a video task and verifying playback starts, progresses correctly, and completes successfully

### Tests for User Story 2 ⚠️

- [ ] T047 [P] [US2] Unit test for Task entity in test/unit/entities/task_test.dart
- [ ] T048 [P] [US2] Unit test for video service in test/unit/services/video_service_test.dart
- [ ] T049 [P] [US2] Unit test for task repository in test/unit/repositories/task_repository_test.dart
- [ ] T050 [P] [US2] Widget test for video player in test/widget/widgets/video_player_test.dart
- [ ] T051 [P] [US2] Widget test for task list in test/widget/pages/task_list_page_test.dart
- [ ] T052 [P] [US2] Integration test for video task completion in test/integration/video_integration_test.dart

### Implementation for User Story 2

- [x] T053 [P] [US2] Create Task entity in lib/domain/entities/task.dart
- [x] T054 [US2] Implement Task model in lib/data/models/task_model.dart (depends on T053)
- [x] T055 [US2] Create Task repository interface in lib/domain/repositories/task_repository.dart
- [x] T056 [US2] Implement Task repository in lib/data/repositories/task_repository_impl.dart (depends on T055)
- [x] T057 [US2] Create ProcessVideoTask use case in lib/domain/usecases/process_video_task_usecase.dart
- [x] T058 [US2] Implement Video service in lib/services/video/video_service.dart
- [x] T059 [US2] Create Task provider in lib/presentation/providers/task_provider.dart
- [x] T060 [US2] Implement Video player widget in lib/presentation/widgets/video_player.dart
- [x] T061 [US2] Implement Task list page UI in lib/presentation/pages/task/task_list_page.dart
- [x] T062 [US2] Add video progress tracking and completion logic
- [x] T063 [US2] Add video playback speed control
- [x] T064 [US2] Add logging for video task operations

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Document Reading Task Completion (Priority: P2)

**Goal**: Enable users to complete document reading tasks to fulfill course requirements

**Independent Test**: Can be fully tested by selecting a document task and verifying it loads and marks as completed

### Tests for User Story 3 ⚠️

- [ ] T065 [P] [US3] Unit test for document service in test/unit/services/document_service_test.dart
- [ ] T066 [P] [US3] Widget test for document viewer in test/widget/widgets/document_viewer_test.dart
- [ ] T067 [P] [US3] Integration test for document task completion in test/integration/document_integration_test.dart

### Implementation for User Story 3

- [x] T068 [US3] Create ProcessDocumentTask use case in lib/domain/usecases/process_document_task_usecase.dart
- [x] T069 [US3] Implement Document service in lib/services/document/document_service.dart
- [x] T070 [US3] Implement Document viewer widget in lib/presentation/widgets/document_viewer.dart
- [x] T071 [US3] Add document loading and completion logic
- [x] T072 [US3] Add document page navigation
- [x] T073 [US3] Add logging for document task operations

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work independently

---

## Phase 6: User Story 4 - Quiz and Assessment Completion (Priority: P2)

**Goal**: Enable users to complete chapter quizzes and assessments using question bank integration

**Independent Test**: Can be fully tested by selecting a quiz task and verifying questions are answered correctly using the question bank

### Tests for User Story 4 ⚠️

- [ ] T074 [P] [US4] Unit test for Question entity in test/unit/entities/question_test.dart
- [ ] T075 [P] [US4] Unit test for question bank service in test/unit/services/question_bank_service_test.dart
- [ ] T076 [P] [US4] Unit test for quiz service in test/unit/services/quiz_service_test.dart
- [ ] T077 [P] [US4] Widget test for quiz page in test/widget/pages/quiz_page_test.dart
- [ ] T078 [P] [US4] Integration test for quiz completion in test/integration/quiz_integration_test.dart

### Implementation for User Story 4

- [ ] T079 [P] [US4] Create Question entity in lib/domain/entities/question.dart
- [ ] T080 [US4] Implement Question model in lib/data/models/question_model.dart (depends on T079)
- [ ] T081 [US4] Create Question repository interface in lib/domain/repositories/question_repository.dart
- [ ] T082 [US4] Implement Question repository in lib/data/repositories/question_repository_impl.dart (depends on T081)
- [ ] T083 [US4] Create ProcessQuizTask use case in lib/domain/usecases/process_quiz_task_usecase.dart
- [ ] T084 [US4] Implement Question bank service in lib/services/question_bank/question_bank_service.dart
- [ ] T085 [US4] Implement Quiz service in lib/services/quiz/quiz_service.dart
- [ ] T086 [US4] Create Quiz provider in lib/presentation/providers/quiz_provider.dart
- [ ] T087 [US4] Implement Quiz page UI in lib/presentation/pages/quiz/quiz_page.dart
- [ ] T088 [US4] Add question bank integration and answer matching
- [ ] T089 [US4] Add quiz submission and validation logic
- [ ] T090 [US4] Add logging for quiz operations

**Checkpoint**: At this point, User Stories 1, 2, 3, AND 4 should all work independently

---

## Phase 7: User Story 5 - Chapter Progress Management (Priority: P3)

**Goal**: Enable users to navigate through course chapters and handle various chapter states

**Independent Test**: Can be fully tested by navigating through course chapters and verifying proper handling of different chapter states

### Tests for User Story 5 ⚠️

- [ ] T091 [P] [US5] Unit test for Chapter entity in test/unit/entities/chapter_test.dart
- [ ] T092 [P] [US5] Unit test for chapter service in test/unit/services/chapter_service_test.dart
- [ ] T093 [P] [US5] Widget test for chapter navigation in test/widget/pages/chapter_page_test.dart
- [ ] T094 [P] [US5] Integration test for chapter progression in test/integration/chapter_integration_test.dart

### Implementation for User Story 5

- [ ] T095 [P] [US5] Create Chapter entity in lib/domain/entities/chapter.dart
- [ ] T096 [US5] Implement Chapter model in lib/data/models/chapter_model.dart (depends on T095)
- [ ] T097 [US5] Create Chapter repository interface in lib/domain/repositories/chapter_repository.dart
- [ ] T098 [US5] Implement Chapter repository in lib/data/repositories/chapter_repository_impl.dart (depends on T097)
- [ ] T099 [US5] Create ProcessChapter use case in lib/domain/usecases/process_chapter_usecase.dart
- [ ] T100 [US5] Implement Chapter service in lib/services/chapter/chapter_service.dart
- [ ] T101 [US5] Create Chapter provider in lib/presentation/providers/chapter_provider.dart
- [ ] T102 [US5] Implement Chapter navigation page UI in lib/presentation/pages/chapter/chapter_page.dart
- [ ] T103 [US5] Add chapter state management and unlock logic
- [ ] T104 [US5] Add chapter completion tracking
- [ ] T105 [US5] Add logging for chapter operations

**Checkpoint**: All user stories should now be independently functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T106 [P] Update documentation in docs/
- [ ] T107 [P] Code cleanup and refactoring across all modules
- [ ] T108 [P] Performance optimization across all stories
- [ ] T109 [P] Additional unit tests to reach 80% coverage in test/unit/
- [ ] T110 [P] Security hardening for credential storage
- [ ] T111 [P] Run quickstart.md validation
- [ ] T112 [P] Cross-platform testing on Android/iOS/Windows
- [ ] T113 [P] Memory usage optimization
- [ ] T114 [P] Network error handling improvements
- [ ] T115 [P] Configuration management enhancements

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Depends on US1 entities
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Depends on US1 entities
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Depends on US1 entities
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Depends on US1 entities

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before UI
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit test for User entity in test/unit/entities/user_test.dart"
Task: "Unit test for Course entity in test/unit/entities/course_test.dart"
Task: "Unit test for AES encryption in test/unit/core/aes_cipher_test.dart"
Task: "Unit test for session manager in test/unit/core/session_manager_test.dart"

# Launch all models for User Story 1 together:
Task: "Create User entity in lib/domain/entities/user.dart"
Task: "Create Course entity in lib/domain/entities/course.dart"
Task: "Create Session entity in lib/domain/entities/session.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Add User Story 4 → Test independently → Deploy/Demo
6. Add User Story 5 → Test independently → Deploy/Demo
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
   - Developer D: User Story 4
   - Developer E: User Story 5
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All tasks follow Flutter clean architecture pattern
- TDD approach: Write tests first, ensure they fail, then implement
- Target: ≥80% test coverage as per constitution requirements
