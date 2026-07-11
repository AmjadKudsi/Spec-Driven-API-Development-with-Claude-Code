# Improve CommentService unit test coverage from about 85% to 95% or higher by testing missing error paths.

 ▐▛███▜▌   Claude Code v2.0.42
▝▜█████▛▘  Sonnet 4.5 · API Usage Billing
  ▘▘ ▝▝    /usercode/FILESYSTEM

> Run this coverage command and summarize missing coverage only:
pytest --cov=src.services.comment_service --cov-report=term tests/unit/ 

● I'll run the coverage command for the comment service.

● Bash(pytest --cov=src.services.comment_service --cov-report=term tests/unit/)
  ⎿  Error: Exit code 1
     /opt/python/3.13.12/lib/python3.13/site-packages/coverage/inorout.py:577: CoverageWarning: Module src.services.comment_service was
      previously imported, but not measured (module-not-measured); see 
     https://coverage.readthedocs.io/en/7.15.0/messages.html#warning-module-not-measured
       self.warn(msg, slug="module-not-measured")

     ============================= test session starts ==============================
     platform linux -- Python 3.13.12, pytest-7.4.0, pluggy-1.6.0
     rootdir: /usercode/FILESYSTEM
     configfile: pytest.ini
     plugins: cov-4.1.0, anyio-4.12.1, typeguard-4.5.1
     collected 4 items
     … +13 lines (ctrl+o to see all)

● The coverage is at 83% (48 statements, 8 missing). Let me get the detailed line-by-line report to see exactly which lines are
  missing coverage:

● Bash(pytest --cov=src.services.comment_service --cov-report=term-missing tests/unit/)
  ⎿  Error: Exit code 1
     /opt/python/3.13.12/lib/python3.13/site-packages/coverage/inorout.py:577: CoverageWarning: Module src.services.comment_service was
      previously imported, but not measured (module-not-measured); see 
     https://coverage.readthedocs.io/en/7.15.0/messages.html#warning-module-not-measured
       self.warn(msg, slug="module-not-measured")

     ============================= test session starts ==============================
     platform linux -- Python 3.13.12, pytest-7.4.0, pluggy-1.6.0
     rootdir: /usercode/FILESYSTEM
     configfile: pytest.ini
     plugins: cov-4.1.0, anyio-4.12.1, typeguard-4.5.1
     collected 4 items
     … +13 lines (ctrl+o to see all)

● Read(src/services/comment_service.py)
  ⎿  Read 85 lines

● Missing Coverage Summary

  Current Coverage: 83% (8 lines missing)

  All missing coverage is in error handling paths:

  create_comment() - Lines 24, 28, 32

  - Line 24: Empty/whitespace content validation
  - Line 28: Content exceeds 5000 characters validation
  - Line 32: Invalid task_id (≤ 0) validation

  update_comment() - Lines 52, 56, 59

  - Line 52: Authorization check (user doesn't own comment)
  - Line 56: Empty/whitespace content validation
  - Line 59: Content exceeds 5000 characters validation

  delete_comment() - Line 71

  - Line 71: Authorization check (user doesn't own comment)

  _find_comment() - Line 85

  - Line 85: Comment not found error

  To reach 95% coverage, you need to add tests for these error scenarios:
  - Invalid inputs (empty content, too long content, invalid task_id)
  - Authorization failures (updating/deleting other users' comments)
  - Resource not found (comment doesn't exist)

> Open tests/unit/test_comment_service.py and inspect the TODOs. Do not edit yet. List the exact tests needed. 

● Read(tests/unit/test_comment_service.py)
  ⎿  Read 72 lines

● Exact Tests Needed (from TODOs)

  Based on the TODOs in tests/unit/test_comment_service.py, here are the 7 missing tests:

  1. Test content exceeding 5000 characters (Lines 9-10)

  - Create a string with 5001+ characters
  - Expect ValueError with message about content length

  2. Test empty content (Lines 12-13)

  - Pass "" as content to create_comment()
  - Expect ValueError about empty content

  3. Test whitespace-only content (Lines 15-16)

  - Pass "   \n\t  " as content to create_comment()
  - Expect ValueError about empty content

  4. Test invalid task_id (Lines 18-19)

  - Pass 0 or negative number as task_id
  - Expect ValueError about invalid task_id

  5. Test unauthorized update attempt (Lines 21-22)

  - Create comment with user_id=1
  - Try to update with user_id=2
  - Expect ValueError about authorization

  6. Test unauthorized delete attempt (Lines 24-25)

  - Create comment with user_id=1
  - Try to delete with user_id=2
  - Expect ValueError about authorization

  7. Test task with no comments (Lines 27-28)

  - Create comments for task_id=1
  - Query for task_id=2
  - Expect empty list []

  These 7 tests will cover all 8 missing lines and push coverage from 83% to 95%+.

> Add only the TODO tests in tests/unit/test_comment_service.py. Use pytest.raises() for expected errors. Do not change production
 code. 

● I'll add the 7 TODO tests to the test file using pytest.raises() for error cases.

● Update(tests/unit/test_comment_service.py)
  ⎿  Updated tests/unit/test_comment_service.py with 58 additions and 21 removals                                      
        6    class TestCommentService:
        7        """Test suite for CommentService with full edge case coverage."""
        8        
        9 -      # TODO: Add test for content that exceeds 5000 characters
       10 -      # Hint: Create a string with 5001 characters and use pytest.raises(ValueError)
       11 -      
       12 -      # TODO: Add test for empty content
       13 -      # Hint: Pass an empty string "" as content and expect a ValueError
       14 -      
       15 -      # TODO: Add test for whitespace-only content
       16 -      # Hint: Pass "   \n\t  " as content and expect a ValueError
       17 -      
       18 -      # TODO: Add test for invalid task_id
       19 -      # Hint: Pass 0 or negative number as task_id and expect a ValueError
       20 -      
       21 -      # TODO: Add test for unauthorized update attempt
       22 -      # Hint: Create a comment with user_id=1, then try to update it with user_id=2
       23 -      
       24 -      # TODO: Add test for unauthorized delete attempt
       25 -      # Hint: Create a comment with user_id=1, then try to delete it with user_id=2
       26 -      
       27 -      # TODO: Add test for task with no comments
       28 -      # Hint: Create comments for task_id=1, then get comments for task_id=2 and check it returns empty list
       29 -      
        9 +      def test_create_comment_with_content_exceeding_5000_characters(self):
       10 +          """Test that creating a comment with content > 5000 characters raises ValueError."""
       11 +          service = CommentService()
       12 +          long_content = "a" * 5001
       13 +  
       14 +          with pytest.raises(ValueError, match="Comment content cannot exceed 5000 characters"):
       15 +              service.create_comment(task_id=1, content=long_content, user_id=1)
       16 +  
       17 +      def test_create_comment_with_empty_content(self):
       18 +          """Test that creating a comment with empty content raises ValueError."""
       19 +          service = CommentService()
       20 +  
       21 +          with pytest.raises(ValueError, match="Comment content cannot be empty"):
       22 +              service.create_comment(task_id=1, content="", user_id=1)
       23 +  
       24 +      def test_create_comment_with_whitespace_only_content(self):
       25 +          """Test that creating a comment with whitespace-only content raises ValueError."""
       26 +          service = CommentService()
       27 +  
       28 +          with pytest.raises(ValueError, match="Comment content cannot be empty"):
       29 +              service.create_comment(task_id=1, content="   \n\t  ", user_id=1)
       30 +  
       31 +      def test_create_comment_with_invalid_task_id(self):
       32 +          """Test that creating a comment with invalid task_id raises ValueError."""
       33 +          service = CommentService()
       34 +  
       35 +          with pytest.raises(ValueError, match="Invalid task_id"):
       36 +              service.create_comment(task_id=0, content="Valid content", user_id=1)
       37 +  
       38 +          with pytest.raises(ValueError, match="Invalid task_id"):
       39 +              service.create_comment(task_id=-1, content="Valid content", user_id=1)
       40 +  
       41 +      def test_update_comment_unauthorized(self):
       42 +          """Test that updating another user's comment raises ValueError."""
       43 +          service = CommentService()
       44 +          comment = service.create_comment(task_id=1, content="Original", user_id=1)
       45 +  
       46 +          with pytest.raises(ValueError, match="Not authorized to update this comment"):
       47 +              service.update_comment(comment.id, "Hacked content", user_id=2)
       48 +  
       49 +      def test_delete_comment_unauthorized(self):
       50 +          """Test that deleting another user's comment raises ValueError."""
       51 +          service = CommentService()
       52 +          comment = service.create_comment(task_id=1, content="Original", user_id=1)
       53 +  
       54 +          with pytest.raises(ValueError, match="Not authorized to delete this comment"):
       55 +              service.delete_comment(comment.id, user_id=2)
       56 +  
       57 +      def test_get_comments_by_task_with_no_comments(self):
       58 +          """Test that getting comments for a task with no comments returns empty list."""
       59 +          service = CommentService()
       60 +          service.create_comment(task_id=1, content="First comment", user_id=1)
       61 +          service.create_comment(task_id=1, content="Second comment", user_id=2)
       62 +  
       63 +          comments = service.get_comments_by_task(task_id=2)
       64 +          assert comments == []
       65 +          assert len(comments) == 0
       66 +  
       67        # Happy path tests below
       68        
       69        def test_create_comment_success(self):

● Done! I've added all 7 TODO tests. Now let me verify the coverage improved:

● Bash(pytest --cov=src.services.comment_service --cov-report=term-missing tests/unit/test_comment_service.py -v)
  ⎿  Error: Exit code 1
     /opt/python/3.13.12/lib/python3.13/site-packages/coverage/inorout.py:577: CoverageWarning: Module src.services.comment_service was
      previously imported, but not measured (module-not-measured); see 
     https://coverage.readthedocs.io/en/7.15.0/messages.html#warning-module-not-measured
       self.warn(msg, slug="module-not-measured")

     ============================= test session starts ==============================
     platform linux -- Python 3.13.12, pytest-7.4.0, pluggy-1.6.0 -- /opt/python/3.13.12/bin/python3
     cachedir: .pytest_cache
     rootdir: /usercode/FILESYSTEM
     configfile: pytest.ini
     plugins: cov-4.1.0, anyio-4.12.1, typeguard-4.5.1
     … +24 lines (ctrl+o to see all)

● Perfect! All 11 tests pass. Coverage improved from 83% to 94% (only 3 lines missing now).

  Results Summary

  ✅ Added 7 tests (all TODOs completed)
  ✅ All tests passing (11/11)
  ✅ Coverage: 83% → 94% (+11%)

  Remaining 3 uncovered lines (to reach 95%):

  - Line 56: Empty content validation in update_comment()
  - Line 59: Content > 5000 chars validation in update_comment()
  - Line 85: Comment not found error in _find_comment()

  The TODO tests covered 5 of 8 missing lines. To reach 95%+, you'd need 3 more tests:
  1. Update comment with empty/whitespace content
  2. Update comment with 5001+ characters
  3. Update/delete non-existent comment

> Run:
pytest --cov=src.services.comment_service --cov-report=term tests/unit/
Report pass/fail and coverage percentage only. 

● Bash(pytest --cov=src.services.comment_service --cov-report=term tests/unit/)
  ⎿  Error: Exit code 1
     /opt/python/3.13.12/lib/python3.13/site-packages/coverage/inorout.py:577: CoverageWarning: Module src.services.comment_service was
      previously imported, but not measured (module-not-measured); see 
     https://coverage.readthedocs.io/en/7.15.0/messages.html#warning-module-not-measured
       self.warn(msg, slug="module-not-measured")

     ============================= test session starts ==============================
     platform linux -- Python 3.13.12, pytest-7.4.0, pluggy-1.6.0
     rootdir: /usercode/FILESYSTEM
     configfile: pytest.ini
     plugins: cov-4.1.0, anyio-4.12.1, typeguard-4.5.1
     collected 11 items
     … +13 lines (ctrl+o to see all)

● Tests: ✅ 11 passed
  Coverage: 94% (fails 95% threshold)

> Identify only remaining uncovered lines in src/services/comment_service.py and add the minimum tests needed. Do not change 
production code. 

● Bash(pytest --cov=src.services.comment_service --cov-report=term-missing tests/unit/ -q)
  ⎿  Error: Exit code 1
     /opt/python/3.13.12/lib/python3.13/site-packages/coverage/inorout.py:577: CoverageWarning: Module src.services.comment_service was
      previously imported, but not measured (module-not-measured); see 
     https://coverage.readthedocs.io/en/7.15.0/messages.html#warning-module-not-measured
       self.warn(msg, slug="module-not-measured")

     ...........                                                              [100%]

     ---------- coverage: platform linux, python 3.13.12-final-0 ----------
     Name                              Stmts   Miss  Cover   Missing
     ---------------------------------------------------------------
     src/services/comment_service.py      48      3    94%   56, 59, 85
     … +5 lines (ctrl+o to see all)

● Remaining Uncovered Lines

  - Line 56: Empty content validation in update_comment()
  - Line 59: Content > 5000 characters validation in update_comment()
  - Line 85: Comment not found error in _find_comment()

  Adding 3 minimum tests:

● Update(tests/unit/test_comment_service.py)
  ⎿  Updated tests/unit/test_comment_service.py with 25 additions                                          
       64            assert comments == []
       65            assert len(comments) == 0
       66    
       67 +      def test_update_comment_with_empty_content(self):
       68 +          """Test that updating a comment with empty content raises ValueError."""
       69 +          service = CommentService()
       70 +          comment = service.create_comment(task_id=1, content="Original", user_id=1)
       71 +  
       72 +          with pytest.raises(ValueError, match="Comment content cannot be empty"):
       73 +              service.update_comment(comment.id, "", user_id=1)
       74 +  
       75 +      def test_update_comment_with_content_exceeding_5000_characters(self):
       76 +          """Test that updating a comment with content > 5000 characters raises ValueError."""
       77 +          service = CommentService()
       78 +          comment = service.create_comment(task_id=1, content="Original", user_id=1)
       79 +          long_content = "a" * 5001
       80 +  
       81 +          with pytest.raises(ValueError, match="Comment content cannot exceed 5000 characters"):
       82 +              service.update_comment(comment.id, long_content, user_id=1)
       83 +  
       84 +      def test_update_nonexistent_comment(self):
       85 +          """Test that updating a non-existent comment raises ValueError."""
       86 +          service = CommentService()
       87 +          non_existent_id = uuid4()
       88 +  
       89 +          with pytest.raises(ValueError, match="Comment not found"):
       90 +              service.update_comment(non_existent_id, "New content", user_id=1)
       91 +  
       92        # Happy path tests below
       93        
       94        def test_create_comment_success(self):

● Now verifying coverage:

● Bash(pytest --cov=src.services.comment_service --cov-report=term tests/unit/ -q)
  ⎿  ..............                                                           [100%]

     ---------- coverage: platform linux, python 3.13.12-final-0 ----------
     … +12 lines (ctrl+o to expand)

● ✅ Complete!

  Added 3 tests covering lines 56, 59, and 85:
  1. test_update_comment_with_empty_content() → Line 56
  2. test_update_comment_with_content_exceeding_5000_characters() → Line 59
  3. test_update_nonexistent_comment() → Line 85

  Result: 14 tests passed, 100% coverage (48/48 statements covered)

> Run the coverage command again. Confirm all tests pass and coverage is 95% or higher. 

● Bash(pytest --cov=src.services.comment_service --cov-report=term tests/unit/)
  ⎿  ============================= test session starts ==============================
     platform linux -- Python 3.13.12, pytest-7.4.0, pluggy-1.6.0
     rootdir: /usercode/FILESYSTEM
     … +20 lines (ctrl+o to expand)

● ✅ Confirmed

  - All tests pass: 14/14 passed
  - Coverage: 100% (exceeds 95% requirement)
  - Statements covered: 48/48 (0 missed)

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
>  
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  ⏵⏵ accept edits on (shift+tab to cycle)