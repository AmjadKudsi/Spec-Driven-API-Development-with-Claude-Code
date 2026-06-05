# Use Claude Code to inspect file-attachment-api-flawed.md, find at least 2 ambiguous phrases, and explain how different AI tools might implement them differently
# make Claude Code fill ambiguity-analysis.md with vague language, impact, and precise replacement text

# Ambiguity Analysis: File Attachment API

**Student**: Amjad Kudsi
**Date**: 2026-06-05
**Specification Analyzed**: file-attachment-api-flawed.md

---

## Instructions

This specification looks more complete than the previous ones - it has endpoints, security mentions, file handling rules. But it uses **vague language** that forces AI to guess implementation details.

Your job: Find instances where terms sound clear to humans but are ambiguous for implementation.

**Look for phrases like:**
- "Virus scanning" - Which service? What happens on detection?
- "Access control" - JWT? Session? Which permissions?
- "Supported formats" - Exact MIME types?
- "Cloud storage" - Which provider? Bucket name?
- "Maximum 5MB" - Exact bytes? Which status code?

**For each ambiguity:**
1. Quote the vague language
2. List what's unclear
3. Show how different AI tools would interpret it differently
4. Provide precise replacement language

**Find at least 2 ambiguities.**

---

## Ambiguity #1: "Virus scanning"

**Location**: Security section (line 76)
**Severity**: Critical
**Category**: Security/Implementation

### The Ambiguous Language
> "Virus scanning"

Missing details:
- Which virus scanning service/library should be used?
- When does scanning occur (synchronous/asynchronous)?
- What happens when a virus is detected?
- What status code and error message for infected files?
- What if the scanning service is unavailable?

### How Different AI Tools Would Interpret This

**AI Tool A might generate:**
```python
# Synchronous ClamAV integration
import pyclamd
cd = pyclamd.ClamdUnixSocket()
if cd.scan_stream(file_data)['stream'][0] == 'FOUND':
    return jsonify({"error": "Virus detected"}), 400
```

**AI Tool B might generate:**
```python
# TODO: Integrate virus scanning service
# For now, just accept all files
def upload_file(file):
    # Virus scanning would go here
    save_to_storage(file)
```

**AI Tool C might generate:**
```python
# Async S3 virus scanning with SNS notifications
s3.upload_file(file, bucket, key)
# Virus scan happens asynchronously via Lambda
# File may be quarantined later if infected
return jsonify(attachment_data), 201
```

**Result**: Three completely different security postures. Tool A rejects infected files immediately. Tool B skips scanning entirely (security vulnerability). Tool C accepts files first, then scans (infected files may be accessed before removal).

### Required Specification
```markdown
**Virus Scanning**:
- Use ClamAV via `clamd` daemon (version 0.103+)
- Scan files synchronously before storage upload
- If virus detected:
  - Return HTTP 400 Bad Request
  - Response: `{"error": "FILE_INFECTED", "message": "File failed virus scan"}`
  - Do not store the file
- If ClamAV unavailable:
  - Return HTTP 503 Service Unavailable
  - Response: `{"error": "SCAN_UNAVAILABLE", "message": "Virus scanning service temporarily unavailable"}`
  - Do not store the file
```

---

## Ambiguity #2: "Maximum Size: 5MB per file"

**Location**: File Handling section (line 68)
**Severity**: High
**Category**: Validation/Error Handling

### The Ambiguous Language
> "Maximum Size: 5MB per file"

Missing details:
- Is "5MB" decimal (5,000,000 bytes) or binary (5,242,880 bytes)?
- What HTTP status code when size exceeded?
- What error response format and message?
- Should validation occur before or during upload?
- Does the limit include multipart form overhead?

### How Different AI Tools Would Interpret This

**AI Tool A might generate:**
```python
MAX_FILE_SIZE = 5_000_000  # 5MB decimal
if file.size > MAX_FILE_SIZE:
    return jsonify({"error": "File too large"}), 400
```

**AI Tool B might generate:**
```python
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 MiB = 5,242,880 bytes
if len(file.read()) > MAX_FILE_SIZE:
    abort(413)  # Payload Too Large
```

**AI Tool C might generate:**
```python
# Configure at web server level
# nginx: client_max_body_size 5M;
# No application-level validation
```

**Result**: Files between 5,000,000 and 5,242,880 bytes would be accepted by Tool B/C but rejected by Tool A. Different status codes (400 vs 413) break client error handling. Tool C has no validation if web server config is missing.

### Required Specification
```markdown
**Maximum File Size**:
- Limit: 5,242,880 bytes (5 MiB) per file
- Validation must occur in application code before storage
- If file exceeds limit:
  - Return HTTP 413 Payload Too Large
  - Response: `{"error": "FILE_TOO_LARGE", "message": "File size exceeds maximum of 5 MiB (5,242,880 bytes)", "max_size_bytes": 5242880}`
- Size check applies to file content only (excludes multipart overhead)
```

---

## Summary

**Total Ambiguities Found**: 2 (plus 4 additional identified: "Supported Formats", "Cloud storage", "Access control", "Authentication required")

**Critical Impact Areas**:
1. **Security** - Vague "virus scanning" could lead to no implementation at all, creating exploitable vulnerabilities
2. **Validation** - Ambiguous "5MB" causes incompatible implementations where same files succeed/fail on different systems

### Key Learning
Ambiguous language is more dangerous than missing sections because it **creates the illusion of completeness**. When something is missing, AI tools might ask for clarification or make it obvious they're guessing. But when language appears specific ("virus scanning", "5MB"), AI tools confidently generate wildly different implementations - all believing they followed the spec correctly.

Unlike missing sections, ambiguities cause **silent divergence**. Two implementations can both claim spec compliance yet be completely incompatible. This is especially dangerous for security features where one tool might skip implementation entirely while another tool properly enforces it.

### What Makes Language Precise?
1. **Exact values**: Use specific byte counts (5,242,880), not ambiguous units (5MB)
2. **Concrete technologies**: Name the library/service (ClamAV 0.103+), not generic categories ("virus scanning")
3. **Error specifications**: Define exact status codes (413) and response formats, not just "return error"
4. **Behavioral details**: Specify synchronous/asynchronous, before/after conditions, success/failure paths
5. **Enumerated options**: List exact MIME types or formats instead of categories like "images" or "text files"
6. **Implementation location**: Specify where validation occurs (application code vs web server config)