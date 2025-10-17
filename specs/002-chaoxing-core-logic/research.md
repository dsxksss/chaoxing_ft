# Research: Chaoxing Core Logic Implementation

**Created**: 2025-01-27  
**Purpose**: Technical research and decision documentation for implementing chaoxing_py core logic in Flutter

## API Endpoints and Network Architecture

### Decision: Replicate chaoxing_py API endpoints exactly
**Rationale**: Must maintain 100% compatibility with Chaoxing platform to ensure identical behavior
**Alternatives considered**: 
- Custom API wrapper (rejected - violates API fidelity principle)
- Simplified API calls (rejected - would break functionality)

### Key API Endpoints Identified:
1. **Authentication**: `https://passport2.chaoxing.com/fanyalogin`
2. **Course List**: `https://mooc2-ans.chaoxing.com/mooc2-ans/visit/courselistdata`
3. **Course Points**: `https://mooc2-ans.chaoxing.com/mooc2-ans/mycourse/studentcourse`
4. **Video Tasks**: `https://mooc1.chaoxing.com/ananas/modules/video/index.html`
5. **Document Tasks**: `https://mooc1.chaoxing.com/ananas/job/document`
6. **Quiz Tasks**: Various endpoints for question retrieval and submission

## Data Encryption and Security

### Decision: Implement AES encryption identical to chaoxing_py
**Rationale**: Chaoxing platform requires AES encryption for login credentials
**Implementation**: 
- AES Key: "u2oh6Vu^HWe4_AES"
- Encrypt username and password before login
- Use same encryption logic as chaoxing_py

**Alternatives considered**:
- Plain text transmission (rejected - security violation)
- Different encryption method (rejected - platform incompatibility)

## Session Management

### Decision: Implement singleton session manager pattern
**Rationale**: chaoxing_py uses singleton pattern for session management to maintain cookies and headers
**Implementation**:
- Singleton SessionManager class
- Automatic cookie persistence
- Header management with User-Agent and platform-specific headers
- Rate limiting: 0.4s for general requests, 2s for video progress updates

**Alternatives considered**:
- Stateless requests (rejected - breaks session continuity)
- Multiple session instances (rejected - cookie conflicts)

## Data Parsing and Decoding

### Decision: Replicate chaoxing_py data parsing logic
**Rationale**: Chaoxing platform returns complex HTML/JSON that requires specific parsing
**Key Parsing Functions**:
- `decode_course_list()`: Parse course list from HTML response
- `decode_course_point()`: Parse chapter structure from HTML
- `decode_course_card()`: Parse task cards from HTML
- `decode_questions_info()`: Parse quiz questions and answers

**Alternatives considered**:
- Generic JSON parsing (rejected - Chaoxing uses HTML responses)
- Simplified parsing (rejected - would miss critical data)

## Task Processing Logic

### Decision: Implement identical task processing workflow
**Rationale**: Must handle all task types exactly as chaoxing_py for compatibility
**Task Types**:
1. **Video Tasks**: Progress tracking, speed control, completion detection
2. **Document Tasks**: Document loading and completion marking
3. **Quiz Tasks**: Question bank integration, answer submission
4. **Reading Tasks**: Page navigation and completion tracking

**Processing Flow**:
- Get job list for each chapter
- Process tasks in parallel (max 5 concurrent)
- Handle task-specific completion logic
- Implement retry mechanism for failed tasks

## Question Bank Integration

### Decision: Implement question bank system identical to chaoxing_py
**Rationale**: High quiz accuracy requires question bank integration
**Implementation**:
- Support multiple question bank providers (TikuYanxi, TikuLike, etc.)
- Cache questions locally for offline access
- Implement answer matching and validation logic
- Support both automatic submission and manual review modes

**Alternatives considered**:
- Manual answer entry (rejected - low accuracy)
- AI-based answering (rejected - violates API fidelity)

## Error Handling and Retry Logic

### Decision: Implement chaoxing_py error handling patterns
**Rationale**: Must handle network errors, rate limiting, and platform-specific issues
**Error Scenarios**:
- Network timeouts (5s timeout)
- Rate limiting (automatic retry with backoff)
- Captcha challenges (OCR integration)
- Session expiration (automatic re-login)
- Task completion failures (retry with rollback)

## Configuration Management

### Decision: Support chaoxing_py configuration options
**Rationale**: Users need same configuration flexibility as Python version
**Configuration Options**:
- Playback speed (1.0-2.0x)
- Retry behavior (retry/ask/continue)
- Question bank settings
- Notification preferences
- Course selection

## Performance Optimization

### Decision: Implement Flutter-specific optimizations while maintaining logic fidelity
**Rationale**: Must meet performance requirements while preserving functionality
**Optimizations**:
- Async/await for network requests
- Background task processing
- Efficient state management with Provider
- Memory management for large course lists
- Platform-specific video player integration

## Testing Strategy

### Decision: Implement comprehensive testing matching chaoxing_py behavior
**Rationale**: Must ensure identical functionality through testing
**Testing Levels**:
- Unit tests for individual functions
- Integration tests for API interactions
- End-to-end tests for complete workflows
- Performance tests for timing requirements
- Cross-platform tests for consistency

**Test Coverage Target**: ≥80% as per constitution requirements
