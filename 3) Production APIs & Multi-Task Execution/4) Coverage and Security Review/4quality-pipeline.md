# Quality Pipeline Checklist

Run this checklist before marking any feature production-ready. Each stage ensures your code meets professional standards for coverage, security, performance, and documentation.

## Stage 1: Coverage Enhancement (15 min)

- [ ] Run coverage: `pytest tests/ --cov=src --cov-report=term-missing`
- [ ] Record current coverage: ____%
- [ ] If below 95%:
  - Identify uncovered lines in terminal output
  - Add tests for missing coverage
  - Focus on: error paths, edge cases, boundary conditions, authorization failures
- [ ] Re-run coverage after adding tests
- [ ] Record final coverage: ____% (target: 95% or higher)

## Stage 2: Security Review (20 min)

### Authorization
- [ ] All protected endpoints require authentication (`Depends(get_current_user)`)
- [ ] Resource ownership verified before read/write operations
- [ ] Cross-user access properly blocked (403 Forbidden)
- [ ] Proper 401 (Unauthorized) vs 403 (Forbidden) responses

### Input Validation
- [ ] All request bodies use Pydantic schemas with validators
- [ ] String fields have min/max length constraints
- [ ] Required fields enforced (no None on required)
- [ ] Content sanitized (trim whitespace, check for empty strings)

### Data Protection
- [ ] No sensitive data exposed in error messages or logs
- [ ] Database sessions properly managed (use `Depends(get_db)`)
- [ ] No SQL injection vulnerabilities (use ORM, not raw SQL)

**Security Findings:** [Document any CRITICAL or HIGH issues found]

**All Issues Fixed:** [YES/NO]

## Stage 3: Performance Test (10 min)

- [ ] Run performance test: `python scripts/performance_test.py`
- [ ] Record p50 latency: ____ms
- [ ] Record p95 latency: ____ms (target: <500ms)
- [ ] Test status: [PASS/FAIL]
- [ ] If FAIL (p95 >500ms):
  - Check database query patterns (N+1 queries)
  - Add indexes for frequently queried columns
  - Review relationship loading (use joinedload if needed)
  - Profile slow endpoints with logging

## Stage 4: Documentation (5 min)

- [ ] OpenAPI docs current (verify at `/docs` endpoint)
- [ ] README.md updated with new feature (if user-facing)
- [ ] CLAUDE.md patterns followed (layered architecture, type hints, error handling)
- [ ] ADR created if architectural decision made (in `docs/adrs/`)

## Final Sign-Off

Review all stages before approving:

- [ ] Test coverage ≥95%
- [ ] No CRITICAL or HIGH security issues remaining
- [ ] p95 latency <500ms
- [ ] Documentation current and complete

**Production Ready:** [YES/NO]

**Reviewed By:** ____________

**Date:** ____________

---

## Notes

Use this checklist for every feature before it goes to production. Keep a copy of the completed checklist in your project's `docs/` folder for audit purposes.