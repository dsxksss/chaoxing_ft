# Data Model: Chaoxing Core Logic Implementation

**Created**: 2025-01-27  
**Purpose**: Define data entities and relationships for Chaoxing learning platform

## Core Entities

### User
Represents authenticated user with credentials and session data
```dart
class User {
  final String username;
  final String password;
  final String uid;
  final DateTime lastLogin;
  final bool isAuthenticated;
  final Map<String, String> sessionCookies;
  final UserPreferences preferences;
}
```

**Validation Rules**:
- Username must be valid phone number format
- Password must be non-empty
- UID must be valid after successful authentication
- Session cookies must be maintained for API requests

**State Transitions**:
- Unauthenticated → Authenticating → Authenticated
- Authenticated → Session Expired → Re-authenticating

### Course
Represents a learning course with metadata and progress tracking
```dart
class Course {
  final String courseId;
  final String clazzId;
  final String cpi;
  final String title;
  final String teacher;
  final String school;
  final CourseStatus status;
  final List<Chapter> chapters;
  final CourseProgress progress;
  final DateTime lastAccessed;
}
```

**Validation Rules**:
- CourseId, clazzId, cpi must be valid identifiers
- Title must be non-empty
- Progress must be between 0.0 and 1.0

**State Transitions**:
- Not Started → In Progress → Completed
- In Progress → Paused → In Progress

### Chapter
Represents course chapters with tasks and completion status
```dart
class Chapter {
  final String chapterId;
  final String title;
  final int index;
  final ChapterStatus status;
  final List<Task> tasks;
  final bool hasFinished;
  final bool isOpen;
  final DateTime? completedAt;
  final ChapterProgress progress;
}
```

**Validation Rules**:
- ChapterId must be unique within course
- Index must be sequential
- Status must be valid enum value
- Progress must be between 0.0 and 1.0

**State Transitions**:
- Locked → Open → In Progress → Completed
- Open → Closed (if prerequisites not met)

### Task
Represents individual learning tasks with completion tracking
```dart
class Task {
  final String taskId;
  final String jobId;
  final TaskType type;
  final String title;
  final String description;
  final TaskStatus status;
  final Map<String, dynamic> metadata;
  final DateTime? completedAt;
  final int retryCount;
  final TaskProgress progress;
}
```

**Task Types**:
- Video: Video playback tasks
- Document: Document reading tasks
- Quiz: Question answering tasks
- Reading: Page reading tasks

**Validation Rules**:
- TaskId and jobId must be valid identifiers
- Type must be valid enum value
- RetryCount must be non-negative
- Progress must be between 0.0 and 1.0

**State Transitions**:
- Pending → In Progress → Completed
- In Progress → Failed → Retrying → Completed/Failed

### Question
Represents quiz questions with answers and validation logic
```dart
class Question {
  final String questionId;
  final String questionText;
  final QuestionType type;
  final List<AnswerOption> options;
  final String correctAnswer;
  final String? userAnswer;
  final bool isAnswered;
  final DateTime? answeredAt;
  final QuestionBankSource source;
}
```

**Question Types**:
- Single Choice: Multiple choice with one correct answer
- Multiple Choice: Multiple choice with multiple correct answers
- True/False: Boolean questions
- Fill in Blank: Text input questions

**Validation Rules**:
- QuestionId must be unique
- QuestionText must be non-empty
- Options must contain at least 2 choices for choice questions
- CorrectAnswer must be valid for question type

### Session
Represents user session with authentication state and API session management
```dart
class Session {
  final String sessionId;
  final User user;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;
  final Map<String, String> headers;
  final Map<String, String> cookies;
  final RateLimiter rateLimiter;
  final SessionConfig config;
}
```

**Validation Rules**:
- SessionId must be unique
- User must be authenticated
- Headers must include required User-Agent and platform headers
- Cookies must be valid for API requests

**State Transitions**:
- Created → Active → Expired → Renewed
- Active → Idle → Active/Expired

### Configuration
Represents user settings for playback speed, retry behavior, and question bank preferences
```dart
class Configuration {
  final double playbackSpeed;
  final RetryBehavior retryBehavior;
  final QuestionBankConfig questionBank;
  final NotificationConfig notifications;
  final List<String> selectedCourses;
  final bool useCookies;
  final Map<String, dynamic> customSettings;
}
```

**Validation Rules**:
- PlaybackSpeed must be between 1.0 and 2.0
- RetryBehavior must be valid enum value
- SelectedCourses must contain valid course IDs

## Enums and Value Objects

### TaskType
```dart
enum TaskType {
  video,
  document,
  quiz,
  reading,
}
```

### TaskStatus
```dart
enum TaskStatus {
  pending,
  inProgress,
  completed,
  failed,
  skipped,
}
```

### ChapterStatus
```dart
enum ChapterStatus {
  locked,
  open,
  inProgress,
  completed,
  closed,
}
```

### CourseStatus
```dart
enum CourseStatus {
  notStarted,
  inProgress,
  completed,
  paused,
}
```

### RetryBehavior
```dart
enum RetryBehavior {
  retry,
  ask,
  continue,
}
```

### QuestionBankSource
```dart
enum QuestionBankSource {
  tikuYanxi,
  tikuLike,
  localCache,
  none,
}
```

## Relationships

### One-to-Many Relationships
- User → Courses (one user has many courses)
- Course → Chapters (one course has many chapters)
- Chapter → Tasks (one chapter has many tasks)
- Task → Questions (quiz tasks have many questions)

### Many-to-One Relationships
- Course → User (many courses belong to one user)
- Chapter → Course (many chapters belong to one course)
- Task → Chapter (many tasks belong to one chapter)
- Question → Task (many questions belong to one quiz task)

### One-to-One Relationships
- User → Session (one user has one active session)
- User → Configuration (one user has one configuration)

## Data Persistence Strategy

### Local Storage (SharedPreferences)
- User credentials (encrypted)
- Configuration settings
- Session tokens
- Basic preferences

### Complex Data Storage (Hive)
- Course data and progress
- Chapter completion status
- Task completion history
- Question bank cache

### Network Data (API)
- Real-time course list
- Current task status
- Live progress updates
- Question bank queries

## Validation and Business Rules

### Authentication Rules
- Credentials must be encrypted before transmission
- Session must be validated before API requests
- Automatic re-authentication on session expiry

### Progress Tracking Rules
- Task completion must be verified through API
- Progress updates must respect rate limiting
- Failed tasks must implement retry logic

### Data Consistency Rules
- Course data must be refreshed from API
- Local cache must be synchronized with server
- Progress conflicts must be resolved in favor of server
