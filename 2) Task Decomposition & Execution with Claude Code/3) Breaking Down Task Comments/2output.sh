# Execute T002 using mocked tests for CommentRepository.
# Prove tests fail first, implement CRUD methods, verify pass, then commit.

========================================
  Task 2: Comment Repository
========================================

✅ Comment repository found
✅ Repository tests found
✅ Commit found with task ID

Running tests...
============================= test session starts ==============================
platform linux -- Python 3.13.12, pytest-8.3.4, pluggy-1.6.0 -- /usr/bin/python
cachedir: .pytest_cache
rootdir: /usercode/FILESYSTEM
configfile: pytest.ini
plugins: asyncio-0.24.0, cov-6.0.0, anyio-4.12.1, typeguard-4.5.1
asyncio: mode=Mode.STRICT, default_loop_scope=function
collecting ... collected 7 items

tests/unit/test_comment_repository.py::TestCommentRepository::test_create_comment PASSED [ 14%]
tests/unit/test_comment_repository.py::TestCommentRepository::test_get_by_id_found PASSED [ 28%]
tests/unit/test_comment_repository.py::TestCommentRepository::test_get_by_id_not_found PASSED [ 42%]
tests/unit/test_comment_repository.py::TestCommentRepository::test_get_task_comments PASSED [ 57%]
tests/unit/test_comment_repository.py::TestCommentRepository::test_get_task_comments_empty PASSED [ 71%]
tests/unit/test_comment_repository.py::TestCommentRepository::test_delete_comment PASSED [ 85%]
tests/unit/test_comment_repository.py::TestCommentRepository::test_delete_comment_not_found PASSED [100%]

=============================== warnings summary ===============================
../../opt/python/3.13.12/lib/python3.13/site-packages/pydantic/_internal/_config.py:295
  /opt/python/3.13.12/lib/python3.13/site-packages/pydantic/_internal/_config.py:295: PydanticDeprecatedSince20: Support for class-based `config` is deprecated, use ConfigDict instead. Deprecated in Pydantic V2.0 to be removed in V3.0. See Pydantic V2 Migration Guide at https://errors.pydantic.dev/2.10/migration/
    warnings.warn(DEPRECATION_MESSAGE, DeprecationWarning)

src/database.py:15
  /usercode/FILESYSTEM/src/database.py:15: MovedIn20Warning: The ``declarative_base()`` function is now available as sqlalchemy.orm.declarative_base(). (deprecated since: 2.0) (Background on SQLAlchemy 2.0 at: https://sqlalche.me/e/b8d9)
    Base = declarative_base()

src/main.py:31
  /usercode/FILESYSTEM/src/main.py:31: DeprecationWarning: 
          on_event is deprecated, use lifespan event handlers instead.
  
          Read more about it in the
          [FastAPI docs for Lifespan Events](https://fastapi.tiangolo.com/advanced/events/).
          
    @app.on_event("startup")

../../opt/python/3.13.12/lib/python3.13/site-packages/fastapi/applications.py:4495
  /opt/python/3.13.12/lib/python3.13/site-packages/fastapi/applications.py:4495: DeprecationWarning: 
          on_event is deprecated, use lifespan event handlers instead.
  
          Read more about it in the
          [FastAPI docs for Lifespan Events](https://fastapi.tiangolo.com/advanced/events/).
          
    return self.router.on_event(event_type)

tests/unit/test_comment_repository.py::TestCommentRepository::test_create_comment
tests/unit/test_comment_repository.py::TestCommentRepository::test_get_by_id_found
tests/unit/test_comment_repository.py::TestCommentRepository::test_get_task_comments
tests/unit/test_comment_repository.py::TestCommentRepository::test_get_task_comments
tests/unit/test_comment_repository.py::TestCommentRepository::test_delete_comment
  /usercode/FILESYSTEM/src/models/comment.py:23: DeprecationWarning: datetime.datetime.utcnow() is deprecated and scheduled for removal in a future version. Use timezone-aware objects to represent datetimes in UTC: datetime.datetime.now(datetime.UTC).
    kwargs['created_at'] = datetime.utcnow()

-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html
======================== 7 passed, 9 warnings in 0.04s =========================

✅ All tests passed!