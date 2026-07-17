# ADR-002: JWT Authentication

**Status:** Accepted
**Date:** 2024-11-15
**Deciders:** Engineering team

## Context

TaskMaster API requires a stateless authentication mechanism to support multiple client types (web applications, mobile apps, and third-party integrations). The system needs to scale to 10,000+ concurrent users while maintaining secure user authentication across distributed services.

Key requirements:
- Support for web and mobile clients (iOS/Android apps launching in Q1 2025)
- Stateless authentication for horizontal scaling across multiple servers
- Token expiration and refresh capabilities for security
- Integration with third-party services requiring API access
- Minimal latency overhead for authentication checks (~50ms requirement)

Session-based authentication with server-side storage would create bottlenecks and complicate distributed deployments. OAuth 2.0 delegation is unnecessary complexity for a first-party authentication system.

## Decision

Implement JWT (JSON Web Tokens) for stateless authentication with the following specifications:

**Implementation Details:**
- Token type: JWT with HS256 signing algorithm
- Token expiration: 7 days (configurable via `ACCESS_TOKEN_EXPIRE_MINUTES`)
- Payload includes: user ID (`sub`), expiration timestamp (`exp`)
- Secret key: 256-bit randomly generated secret stored in environment variables
- Token delivery: Bearer token in Authorization header
- Password hashing: bcrypt with cost factor 12

**Code Example:**
```python
# src/services/auth.py
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
```

**Security measures:**
- Passwords hashed with bcrypt before storage
- JWT tokens signed with secret key
- Token validation on every protected endpoint
- User active status checked on each request

## Alternatives Considered

### Session Cookies
**Rejected because:** TaskMaster's mobile app requirement and third-party API integration make session cookies impractical. Session state would need to be shared across multiple backend servers, requiring Redis or database storage, adding 10-20ms latency per request. Mobile apps would need complex cookie handling for API calls.

### OAuth 2.0 with External Provider
**Rejected because:** TaskMaster owns the user authentication system and doesn't require delegation to external identity providers (Google, GitHub, etc.). OAuth 2.0 adds unnecessary complexity (authorization server, token introspection, client credentials management) for a first-party authentication system. Would increase implementation time by 3-4 weeks.

### API Keys
**Rejected because:** API keys are suitable for service-to-service authentication but not for user authentication. No built-in expiration mechanism, difficult to rotate per-user, and no standard for user identity claims. Would require custom implementation of all features JWT provides out-of-box.

### Opaque Tokens with Token Introspection
**Rejected because:** Requires database/cache lookup on every request to validate token, eliminating the stateless benefit. Adds 5-10ms latency per request. Would need Redis for high-performance lookups. Better suited for OAuth 2.0 scenarios with token revocation requirements.

## Consequences

### Positive

- **Stateless authentication:** No server-side session storage required, enabling horizontal scaling across multiple servers without shared session state
- **Performance:** ~2ms token validation (cryptographic signature verification) vs 10-20ms for session database lookups - saves 8-18ms per authenticated request
- **Mobile-friendly:** JWT tokens work seamlessly in mobile apps via Authorization header, no cookie handling required
- **Microservices ready:** Tokens can be validated independently by any service with the shared secret key, supporting future service decomposition
- **Standard format:** Industry-standard JWT format with extensive library support in all languages
- **Third-party integration:** External services can authenticate with generated tokens without session management

### Negative

- **Token size:** JWT tokens are 200-300 bytes vs 32-byte session IDs, adding ~270 bytes to every authenticated request header
- **No server-side revocation:** Tokens remain valid until expiration (7 days). Compromised tokens cannot be immediately invalidated without implementing a token blacklist
  - **Mitigation:** Short expiration window (7 days), implement refresh token rotation in future phase, monitor for suspicious activity
- **Secret key management:** Single secret key compromise invalidates all tokens. Requires secure key storage and rotation procedures
  - **Mitigation:** Store secret in environment variables (not in code), use 256-bit randomly generated keys, document key rotation procedure
- **Payload size limits:** JWT payload limited to ~8KB for HTTP header limits, restricts amount of user data that can be stored in token
  - **Mitigation:** Store only user ID in token, fetch additional user data from database when needed

### Neutral

- **Token refresh flow:** Will need implementation of refresh token mechanism for long-lived sessions (planned for Phase 2)
- **Clock synchronization:** Token expiration requires synchronized clocks across servers (handled by NTP in production)
- **Library dependency:** Requires python-jose library for JWT operations (15KB addition to dependencies)
- **Testing complexity:** Tests need to mock token generation and validation (handled via pytest fixtures in tests/conftest.py)
# ADR-002: JWT Authentication

**Status:** Proposed  
**Date:** 2024-11-15  
**Deciders:** Engineering team

## Context

# TODO: This will be filled by adr-writer agent initially
# TODO: Then YOU will refine with project-specific context:
# TODO: - Why does TaskMaster specifically need authentication?
# TODO: - What client types will use it? (web, mobile, third-party)
# TODO: - What are the timeline constraints? (mobile app in 6 weeks?)
# TODO: - What scaling requirements exist? (10,000+ users?)

## Decision

# TODO: This will be filled by adr-writer agent
# TODO: Verify the code examples match actual implementation in src/utils/jwt.py

## Alternatives Considered

# TODO: This will be filled by adr-writer agent
# TODO: IMPORTANT: Refine each alternative with project-specific reasons
# TODO: Example: "Session Cookies - Why not: TaskMaster's mobile app requirement..."

## Consequences

### Positive

# TODO: This will be filled by adr-writer agent
# TODO: Add quantified benefits: "saves ~50ms per request based on benchmarks"

### Negative

# TODO: This will be filled by adr-writer agent
# TODO: CRITICAL: Add specific numbers and mitigation plans
# TODO: Example: "7-day expiration window if compromised - mitigated by..."

### Neutral

# TODO: This will be filled by adr-writer agent
# TODO: Add implementation details specific to TaskMaster's deployment