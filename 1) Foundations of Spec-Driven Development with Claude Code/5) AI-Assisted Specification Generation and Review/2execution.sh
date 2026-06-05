# Use Claude Code to inspect file-attachment-api-flawed.md, find at least 2 ambiguous phrases, and explain how different AI tools might implement them differently
# make Claude Code fill ambiguity-analysis.md with vague language, impact, and precise replacement text


╭─── Claude Code v2.0.42 ────────────────────────────────────────────────────────────────────────────────╮
│                                    │ Tips for getting started                                          │
│            Welcome back!           │ Run /init to create a CLAUDE.md file with instructions for Claude │
│                                    │ ───────────────────────────────────────────────────────────────── │
│               ▐▛███▜▌              │ Recent activity                                                   │
│              ▝▜█████▛▘             │ No recent activity                                                │
│                ▘▘ ▝▝               │                                                                   │
│                                    │                                                                   │
│   Sonnet 4.5 · API Usage Billing   │                                                                   │
│        /usercode/FILESYSTEM        │                                                                   │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────╯

> Read file-attachment-api-flawed.md and ambiguity-analysis.md.

Identify ambiguous language in the File Attachment API spec.
Find phrases that could cause different AI tools to generate different implementations.

Do not edit files yet.
List at least 4 candidate ambiguities with:

Exact quote
Section/location
What is unclear
Why implementation could differ 

● I'll read both files to identify ambiguous language in the File Attachment API spec.

● Read(file-attachment-api-flawed.md)
  ⎿  Error reading file

● Read(ambiguity-analysis.md)
  ⎿  Error reading file

● Let me search for these files in the filesystem.

● Search(pattern: "**/*file-attachment-api*.md")
  ⎿  Found 1 file (ctrl+o to expand)

● Search(pattern: "**/*ambiguity*.md")
  ⎿  Found 1 file (ctrl+o to expand)

● Read(workspace/unit-5/task-2/file-attachment-api-flawed.md)
  ⎿  Read 100 lines

● Read(workspace/unit-5/task-2/ambiguity-analysis.md)
  ⎿  Read 113 lines

● Based on my analysis of the File Attachment API specification, here are 4+ candidate ambiguities
  that could cause different AI implementations:

  Ambiguity #1: "Supported Formats: PDF, images, text files"

  Exact quote: "Supported Formats: PDF, images, text files" (line 67)

  Section/location: File Handling section

  What is unclear:
  - Which exact MIME types should be accepted?
  - What specific image formats? (JPEG, PNG, GIF, BMP, WebP, SVG, TIFF?)
  - What text file types? (TXT, MD, CSV, JSON, XML, HTML?)
  - How should format validation occur? (extension only, MIME type, magic bytes?)
  - What error response when format is invalid?

  Why implementation could differ:
  - AI Tool A might implement: ['application/pdf', 'image/jpeg', 'image/png', 'text/plain']
  - AI Tool B might implement: ['application/pdf', 'image/*', 'text/*'] (wildcard matching)
  - AI Tool C might validate by file extension only: .pdf, .jpg, .jpeg, .png, .txt
  - AI Tool D might not implement validation at all, just mention it in comments
  - Different tools would reject different valid files, causing inconsistent user experience

  ---
  Ambiguity #2: "Maximum Size: 5MB per file"

  Exact quote: "Maximum Size: 5MB per file" (line 68)

  Section/location: File Handling section

  What is unclear:
  - Is this 5,000,000 bytes (decimal MB) or 5,242,880 bytes (binary MiB)?
  - What HTTP status code when exceeded? (400, 413, 422?)
  - What error message format and text?
  - Should check happen before or during upload?
  - What about the multipart overhead - is that included?

  Why implementation could differ:
  - AI Tool A: if file.size > 5000000: returns 400 Bad Request
  - AI Tool B: if file.size > 5 * 1024 * 1024: returns 413 Payload Too Large
  - AI Tool C: MAX_SIZE = 5242880 returns 422 Unprocessable Entity with JSON error
  - AI Tool D: Configures web server limit without application-level check
  - Files between 5MB and 5MiB would be accepted by some implementations but rejected by others

  ---
  Ambiguity #3: "Virus scanning"

  Exact quote: "Virus scanning" (line 76)

  Section/location: Security section

  What is unclear:
  - Which virus scanning service/library? (ClamAV, Windows Defender, VirusTotal API, third-party
  service?)
  - When does scanning occur? (synchronous before response, asynchronous after upload?)
  - What happens when virus detected? (Delete file? Return error? Log and quarantine?)
  - What status code and error message for infected files?
  - What if scanning service is unavailable?

  Why implementation could differ:
  - AI Tool A: Adds clamav library, scans synchronously, returns 400 Bad Request with "Infected file
  detected"
  - AI Tool B: Adds comment # TODO: Integrate virus scanning and skips implementation
  - AI Tool C: Uses async queue with AWS S3 virus scanning, uploads first then scans, sends webhook
  notification
  - AI Tool D: Validates file extension only and considers that "virus prevention"
  - Users uploading the same file would get completely different results: immediate rejection,
  acceptance then later deletion, or no scanning at all

  ---
  Ambiguity #4: "Access control"

  Exact quote: "Access control" (line 77)

  Section/location: Security section

  What is unclear:
  - What permissions are checked? (task owner only, team members, any authenticated user?)
  - How are permissions verified? (database query, JWT claims, permission service?)
  - Different permissions per operation? (upload vs. view vs. delete?)
  - What about the DELETE endpoint - who can delete attachments?
  - What status code when forbidden? (403 vs 404 to avoid leaking existence?)

  Why implementation could differ:
  - AI Tool A: Checks if current_user.id == task.owner_id only
  - AI Tool B: Checks if current_user in task.team_members
  - AI Tool C: Checks if current_user.has_permission('attachments.write')
  - AI Tool D: Only checks authentication exists, no authorization
  - Same user could upload to a task in one implementation but be blocked in another

  ---
  Ambiguity #5: "Cloud storage"

  Exact quote: "Cloud storage" (line 69)

  Section/location: File Handling section

  What is unclear:
  - Which cloud provider? (AWS S3, Azure Blob, Google Cloud Storage, Cloudflare R2?)
  - Bucket/container name? Region?
  - Public or private storage? Signed URLs or direct access?
  - How long should signed URLs be valid?
  - File naming strategy to avoid collisions?
  - Encryption at rest configuration?

  Why implementation could differ:
  - AI Tool A: Implements AWS S3 with public bucket and direct URLs
  - AI Tool B: Implements local filesystem storage as "simpler cloud alternative"
  - AI Tool C: Implements Azure Blob with SAS tokens valid for 1 hour
  - AI Tool D: Hardcodes boto3 with bucket name 'attachments-prod'
  - URLs in responses would have completely different formats and lifespans

  ---
  Ambiguity #6: "Authentication required"

  Exact quote: "Authentication required" (line 75)

  Section/location: Security section

  What is unclear:
  - What authentication mechanism? (JWT, session cookies, API keys, OAuth2 bearer tokens?)
  - What header name? (Authorization? X-API-Key?)
  - What token format validation?
  - What status code when missing? (401 Unauthorized vs 403 Forbidden?)
  - What error response format?

  Why implementation could differ:
  - AI Tool A: Expects Authorization: Bearer <jwt> header, returns 401 with {"error": "Unauthorized"}
  - AI Tool B: Expects session cookie, redirects to login page with 302
  - AI Tool C: Expects X-API-Key header, returns 403 with {"message": "Forbidden"}
  - AI Tool D: Assumes authentication handled by API gateway, doesn't implement
  - Same client with same credentials might work with one implementation but fail with others

  ---
  Summary

  These ambiguities would cause AI tools to generate incompatible implementations even though they're
  all following the "same" specification. The most critical issues are around security (#3, #4, #6)
  where missing details could lead to vulnerabilities or broken authentication flows.

> Fill ambiguity-analysis.md using the strongest 2 ambiguities from your analysis.

For each ambiguity, include:

Exact vague language
Missing details
Different possible AI implementations
Resulting problem
Precise replacement text

Keep it concise and focused only on the exercise requirements. 

● I'll fill out the ambiguity-analysis.md file with the 2 strongest ambiguities from my analysis.

● Read(workspace/unit-5/task-2/ambiguity-analysis.md)
  ⎿  Read 113 lines

● Update(workspace/unit-5/task-2/ambiguity-analysis.md)
  ⎿  Updated workspace/unit-5/task-2/ambiguity-analysis.md with 2 additions and 2 removals
       1    # Ambiguity Analysis: File Attachment API
       2    
       3 -  **Student**: [Your Name]
       4 -  **Date**: [Date]
       3 +  **Student**: Claude Code Analysis
       4 +  **Date**: 2026-06-05
       5    **Specification Analyzed**: file-attachment-api-flawed.md
       6    
       7    ---

● Update(workspace/unit-5/task-2/ambiguity-analysis.md)
  ⎿  Updated workspace/unit-5/task-2/ambiguity-analysis.md with 46 additions and 19 removals   
       29    
       30    ---
       31    
       32 -  ## Ambiguity #1: [Vague Term or Phrase]
       32 +  ## Ambiguity #1: "Virus scanning"
       33    
       34 -  **Location**: [Which section of the spec?]
       35 -  **Severity**: [Critical/High/Medium/Low]
       36 -  **Category**: [Security/Validation/Implementation/Error Handling]
       34 +  **Location**: Security section (line 76)
       35 +  **Severity**: Critical
       36 +  **Category**: Security/Implementation
       37    
       38    ### The Ambiguous Language
       39 -  [Quote the exact text from spec that's vague]
       39 +  > "Virus scanning"
       40    
       41 -  [What specific details are missing? What questions can't you answer?]
       41 +  Missing details:
       42 +  - Which virus scanning service/library should be used?
       43 +  - When does scanning occur (synchronous/asynchronous)?
       44 +  - What happens when a virus is detected?
       45 +  - What status code and error message for infected files?
       46 +  - What if the scanning service is unavailable?
       47    
       48    ### How Different AI Tools Would Interpret This
       49    
       50    **AI Tool A might generate:**
       51 -  """python
       52 -  # [Show one possible interpretation]
       53 -  """
       51 +  ```python
       52 +  # Synchronous ClamAV integration
       53 +  import pyclamd
       54 +  cd = pyclamd.ClamdUnixSocket()
       55 +  if cd.scan_stream(file_data)['stream'][0] == 'FOUND':
       56 +      return jsonify({"error": "Virus detected"}), 400
       57 +  ```
       58    
       59    **AI Tool B might generate:**
       60 -  """python
       61 -  # [Show different interpretation]
       62 -  """
       60 +  ```python
       61 +  # TODO: Integrate virus scanning service
       62 +  # For now, just accept all files
       63 +  def upload_file(file):
       64 +      # Virus scanning would go here
       65 +      save_to_storage(file)
       66 +  ```
       67    
       68    **AI Tool C might generate:**
       69 -  """python
       70 -  # [Show third interpretation]
       71 -  """
       69 +  ```python
       70 +  # Async S3 virus scanning with SNS notifications
       71 +  s3.upload_file(file, bucket, key)
       72 +  # Virus scan happens asynchronously via Lambda
       73 +  # File may be quarantined later if infected
       74 +  return jsonify(attachment_data), 201
       75 +  ```
       76    
       77 -  **Result**: [Explain how these differences cause problems]
       77 +  **Result**: Three completely different security postures. Tool A rejects infected 
          + files immediately. Tool B skips scanning entirely (security vulnerability). Tool C 
          + accepts files first, then scans (infected files may be accessed before removal).
       78    
       79    ### Required Specification
       80 -  """markdown
       81 -  [Provide precise, unambiguous replacement text with all details]
       82 -  """
       80 +  ```markdown
       81 +  **Virus Scanning**:
       82 +  - Use ClamAV via `clamd` daemon (version 0.103+)
       83 +  - Scan files synchronously before storage upload
       84 +  - If virus detected:
       85 +    - Return HTTP 400 Bad Request
       86 +    - Response: `{"error": "FILE_INFECTED", "message": "File failed virus scan"}`
       87 +    - Do not store the file
       88 +  - If ClamAV unavailable:
       89 +    - Return HTTP 503 Service Unavailable
       90 +    - Response: `{"error": "SCAN_UNAVAILABLE", "message": "Virus scanning service 
          + temporarily unavailable"}`
       91 +    - Do not store the file
       92 +  ```
       93    
       94    ---
       95    

● Update(workspace/unit-5/task-2/ambiguity-analysis.md)
  ⎿  Updated workspace/unit-5/task-2/ambiguity-analysis.md with 38 additions and 16 removals       
        93    
        94    ---
        95    
        96 -  ## Ambiguity #2: [Vague Term or Phrase]
        96 +  ## Ambiguity #2: "Maximum Size: 5MB per file"
        97    
        98 -  **Location**: [Which section?]
        99 -  **Severity**: [Critical/High/Medium/Low]
       100 -  **Category**: [Security/Validation/Implementation/Error Handling]
        98 +  **Location**: File Handling section (line 68)
        99 +  **Severity**: High
       100 +  **Category**: Validation/Error Handling
       101    
       102    ### The Ambiguous Language
       103 -  [Quote vague text]
       103 +  > "Maximum Size: 5MB per file"
       104    
       105 -  [What's unclear?]
       105 +  Missing details:
       106 +  - Is "5MB" decimal (5,000,000 bytes) or binary (5,242,880 bytes)?
       107 +  - What HTTP status code when size exceeded?
       108 +  - What error response format and message?
       109 +  - Should validation occur before or during upload?
       110 +  - Does the limit include multipart form overhead?
       111    
       112    ### How Different AI Tools Would Interpret This
       113    
       114    **AI Tool A might generate:**
       115 -  """python
       116 -  # [First interpretation]
       117 -  """
       115 +  ```python
       116 +  MAX_FILE_SIZE = 5_000_000  # 5MB decimal
       117 +  if file.size > MAX_FILE_SIZE:
       118 +      return jsonify({"error": "File too large"}), 400
       119 +  ```
       120    
       121    **AI Tool B might generate:**
       122 -  """python
       123 -  # [Second interpretation]
       124 -  """
       122 +  ```python
       123 +  MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 MiB = 5,242,880 bytes
       124 +  if len(file.read()) > MAX_FILE_SIZE:
       125 +      abort(413)  # Payload Too Large
       126 +  ```
       127    
       128 -  **Result**: [Impact of differences]
       128 +  **AI Tool C might generate:**
       129 +  ```python
       130 +  # Configure at web server level
       131 +  # nginx: client_max_body_size 5M;
       132 +  # No application-level validation
       133 +  ```
       134    
       135 +  **Result**: Files between 5,000,000 and 5,242,880 bytes would be accepted by Tool B/C
           +  but rejected by Tool A. Different status codes (400 vs 413) break client error 
           + handling. Tool C has no validation if web server config is missing.
       136 +  
       137    ### Required Specification
       138 -  """markdown
       139 -  [Precise replacement]
       140 -  """
       138 +  ```markdown
       139 +  **Maximum File Size**:
       140 +  - Limit: 5,242,880 bytes (5 MiB) per file
       141 +  - Validation must occur in application code before storage
       142 +  - If file exceeds limit:
       143 +    - Return HTTP 413 Payload Too Large
       144 +    - Response: `{"error": "FILE_TOO_LARGE", "message": "File size exceeds maximum of 5
           +  MiB (5,242,880 bytes)", "max_size_bytes": 5242880}`
       145 +  - Size check applies to file content only (excludes multipart overhead)
       146 +  ```
       147    
       148    ---
       149    

● Update(workspace/unit-5/task-2/ambiguity-analysis.md)
  ⎿  Updated workspace/unit-5/task-2/ambiguity-analysis.md with 12 additions and 5 removals        
       149    
       150    ## Summary
       151    
       152 -  **Total Ambiguities Found**: [Number]
       152 +  **Total Ambiguities Found**: 2 (plus 4 additional identified: "Supported Formats", 
           + "Cloud storage", "Access control", "Authentication required")
       153    
       154    **Critical Impact Areas**:
       155 -  1. [Which area and why it matters]
       156 -  2. [Which area and why it matters]
       155 +  1. **Security** - Vague "virus scanning" could lead to no implementation at all, 
           + creating exploitable vulnerabilities
       156 +  2. **Validation** - Ambiguous "5MB" causes incompatible implementations where same 
           + files succeed/fail on different systems
       157    
       158    ### Key Learning
       159 -  [What did you learn about ambiguous language? How is it different from missing 
           - sections? Why is it more dangerous?]
       159 +  Ambiguous language is more dangerous than missing sections because it **creates the 
           + illusion of completeness**. When something is missing, AI tools might ask for 
           + clarification or make it obvious they're guessing. But when language appears specific 
           + ("virus scanning", "5MB"), AI tools confidently generate wildly different 
           + implementations - all believing they followed the spec correctly.
       160    
       161 +  Unlike missing sections, ambiguities cause **silent divergence**. Two implementations
           +  can both claim spec compliance yet be completely incompatible. This is especially 
           + dangerous for security features where one tool might skip implementation entirely 
           + while another tool properly enforces it.
       162 +  
       163    ### What Makes Language Precise?
       164 -  [List principles you learned about making specs unambiguous]
       164   \ No newline at end of file
       165 +  1. **Exact values**: Use specific byte counts (5,242,880), not ambiguous units (5MB)
       166 +  2. **Concrete technologies**: Name the library/service (ClamAV 0.103+), not generic 
           + categories ("virus scanning")
       167 +  3. **Error specifications**: Define exact status codes (413) and response formats, 
           + not just "return error"
       168 +  4. **Behavioral details**: Specify synchronous/asynchronous, before/after conditions,
           +  success/failure paths
       169 +  5. **Enumerated options**: List exact MIME types or formats instead of categories 
           + like "images" or "text files"
       170 +  6. **Implementation location**: Specify where validation occurs (application code vs 
           + web server config)
       171   \ No newline at end of file

● Done! I've filled out the ambiguity-analysis.md file with the 2 strongest ambiguities:

  Ambiguity #1: "Virus scanning" (Critical Security)

  - Problem: Could be implemented as synchronous ClamAV, skipped entirely with a TODO comment, or
  async cloud scanning
  - Impact: Three completely different security postures - some would have no protection at all
  - Fix: Specified ClamAV daemon, synchronous scanning, exact error codes and responses

  Ambiguity #2: "Maximum Size: 5MB per file" (High Validation)

  - Problem: Could be 5,000,000 bytes (decimal) or 5,242,880 bytes (binary), with different status
  codes (400 vs 413)
  - Impact: Files between these sizes accepted by some implementations, rejected by others
  - Fix: Specified exact byte count (5,242,880), HTTP 413 status, structured error response

  Key Insight

  Ambiguous language is more dangerous than missing sections because it creates the illusion of 
  completeness. AI tools confidently generate wildly different implementations - all believing they
  followed the spec correctly - causing silent divergence.

  The analysis is complete at /usercode/FILESYSTEM/workspace/unit-5/task-2/ambiguity-analysis.md

> Check ambiguity-analysis.md against the task requirements.

Confirm:

At least 2 ambiguities are documented
Each ambiguity quotes exact vague language
Each explains what is unclear
Each shows different AI interpretations
Each includes precise replacement language
Summary and key learning are filled

Show only the checklist result. 

● Read(workspace/unit-5/task-2/ambiguity-analysis.md)
  ⎿  Read 169 lines

● Task Requirements Checklist ✓

  ✅ At least 2 ambiguities documented - 2 ambiguities present (lines 32-93, 96-146)

  ✅ Each quotes exact vague language
  - Ambiguity #1: "Virus scanning" (line 39)
  - Ambiguity #2: "Maximum Size: 5MB per file" (line 103)

  ✅ Each explains what is unclear
  - Ambiguity #1: 5 missing details listed (lines 41-46)
  - Ambiguity #2: 5 missing details listed (lines 105-110)

  ✅ Each shows different AI interpretations
  - Ambiguity #1: 3 AI tools with code examples + result explanation (lines 48-77)
  - Ambiguity #2: 3 AI tools with code examples + result explanation (lines 112-135)

  ✅ Each includes precise replacement language
  - Ambiguity #1: Complete specification in markdown (lines 80-92)
  - Ambiguity #2: Complete specification in markdown (lines 138-146)

  ✅ Summary and key learning filled
  - Total ambiguities count (line 152)
  - Critical impact areas (lines 154-156)
  - Key learning section (lines 158-161)
  - "What Makes Language Precise?" with 6 principles (lines 163-169)

  All requirements met.

───────────────────────────────────────────────────────────────────────────────────────────────────────────
>  
───────────────────────────────────────────────────────────────────────────────────────────────────────────
  ⏵⏵ accept edits on (shift+tab to cycle)