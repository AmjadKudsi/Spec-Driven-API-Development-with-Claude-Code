# Complete get_parallel_groups() and calculate_critical_path() in task_plan.py.
# use Claude Code to patch only the TODO logic and verify tests.

========================================
  Task 1: Parallel Task Planning
========================================

Running tests...
============================= test session starts ==============================
platform linux -- Python 3.13.12, pytest-8.3.4, pluggy-1.6.0 -- /usr/bin/python
cachedir: .pytest_cache
rootdir: /usercode/FILESYSTEM
configfile: pytest.ini
plugins: asyncio-0.24.0, cov-6.0.0, anyio-4.12.1, typeguard-4.5.1
asyncio: mode=Mode.STRICT, default_loop_scope=function
collecting ... collected 9 items

test_task_plan.py::test_identifies_initial_parallel_tasks PASSED         [ 11%]
test_task_plan.py::test_identifies_second_wave_parallel PASSED           [ 22%]
test_task_plan.py::test_calculates_critical_path_sequential PASSED       [ 33%]
test_task_plan.py::test_calculates_critical_path_with_parallel PASSED    [ 44%]
test_task_plan.py::test_critical_path_uses_earliest_start_not_waves PASSED [ 55%]
test_task_plan.py::test_realistic_feature_scenario PASSED                [ 66%]
test_task_plan.py::test_convergence_point PASSED                         [ 77%]
test_task_plan.py::test_complex_diamond_dependency PASSED                [ 88%]
test_task_plan.py::test_multiple_independent_chains PASSED               [100%]

============================== 9 passed in 0.02s ===============================

✅ All tests passed!

Your implementation correctly:
  - Identifies parallel task groups
  - Uses earliest-start scheduling (not wave batching)
  - Calculates critical path accurately
  - Handles sequential dependencies
  - Optimizes for parallel execution