#!/usr/bin/env python3
"""Performance testing script for Task Comments API."""
import asyncio
import httpx
import time
import statistics
from typing import List


BASE_URL = "http://localhost:8000"
CONCURRENT_USERS = 5
ITERATIONS = 10


async def user_session() -> float:
    """Simulate a single user's API interactions."""
    try:
        async with httpx.AsyncClient(base_url=BASE_URL, timeout=10.0) as client:
            start = time.time()

            # 1. Login
            login_resp = await client.post("/api/auth/login", json={
                "email": "test@example.com",
                "password": "test"
            })
            login_resp.raise_for_status()

            # 2. Get token
            token = login_resp.json().get("access_token") or login_resp.json().get("token")
            headers = {"Authorization": f"Bearer {token}"}

            # 3. List tasks
            list_resp = await client.get("/api/tasks", headers=headers)
            list_resp.raise_for_status()

            # 4. Create task
            create_resp = await client.post("/api/tasks", headers=headers, json={
                "title": "Performance test task",
                "description": "Testing API performance"
            })
            create_resp.raise_for_status()
            task_id = create_resp.json()["id"]

            # 5. Add comment to task
            comment_resp = await client.post(f"/api/tasks/{task_id}/comments", headers=headers, json={
                "content": "Test comment"
            })
            comment_resp.raise_for_status()

            duration_ms = (time.time() - start) * 1000
            return duration_ms
    except Exception as e:
        return e


async def run_load_test() -> tuple[List[float], List[Exception]]:
    """Run concurrent user sessions."""
    print(f"🔥 Starting load test: {CONCURRENT_USERS} concurrent users × {ITERATIONS} iterations")

    all_times = []
    all_errors = []

    for i in range(ITERATIONS):
        # Create list of concurrent tasks
        tasks = [user_session() for _ in range(CONCURRENT_USERS)]

        # Run them with asyncio.gather()
        results = await asyncio.gather(*tasks)

        # Separate successful timings from errors
        for result in results:
            if isinstance(result, Exception):
                all_errors.append(result)
            else:
                all_times.append(result)

        # Log progress
        if (i + 1) % 10 == 0:
            print(f"  [{i+1}/{ITERATIONS}] iterations complete")

    return all_times, all_errors


def calculate_metrics(timings: List[float]) -> dict:
    """Calculate performance metrics from timing data."""
    if not timings:
        return {"error": "No timing data collected"}

    sorted_timings = sorted(timings)
    quantiles = statistics.quantiles(sorted_timings, n=100)

    return {
        "min": min(sorted_timings),
        "p50": statistics.median(sorted_timings),
        "p95": quantiles[94],
        "p99": quantiles[98],
        "max": max(sorted_timings),
        "mean": statistics.mean(sorted_timings),
        "total_requests": len(sorted_timings)
    }


def print_results(metrics: dict, errors: List[Exception], target_p95: float = 1000.0):
    """Print formatted performance results."""
    # Check if metrics has error
    if "error" in metrics:
        print(f"\n❌ {metrics['error']}")
        return

    # Print formatted table with all metrics
    print("\n" + "="*50)
    print("Performance Test Results")
    print("="*50)
    print(f"Total Requests:  {metrics['total_requests']}")
    print(f"Min:             {metrics['min']:.2f}ms")
    print(f"Mean:            {metrics['mean']:.2f}ms")
    print(f"Median (p50):    {metrics['p50']:.2f}ms")
    print(f"p95:             {metrics['p95']:.2f}ms")
    print(f"p99:             {metrics['p99']:.2f}ms")
    print(f"Max:             {metrics['max']:.2f}ms")

    # Show warning if there were any errors
    if errors:
        print(f"\n⚠️  {len(errors)} request(s) failed")

    # PASS/FAIL based on p95 vs target
    print("\n" + "-"*50)
    if metrics['p95'] < target_p95:
        print(f"✅ PASS - p95 ({metrics['p95']:.2f}ms) < target ({target_p95}ms)")
    else:
        print(f"❌ FAIL - p95 ({metrics['p95']:.2f}ms) >= target ({target_p95}ms)")
        # Suggest optimizations
        print("\nSuggested optimizations:")
        print("  - Add database indexes on frequently queried fields")
        print("  - Implement connection pooling")
        print("  - Add caching layer (Redis)")
        print("  - Optimize N+1 query patterns")
    print("="*50)


async def main():
    """Main entry point."""
    print("Starting API performance test...")
    print(f"Target: p95 latency < 1000ms\n")

    # Call run_load_test()
    timings, errors = await run_load_test()

    # Call calculate_metrics()
    metrics = calculate_metrics(timings)

    # Call print_results()
    print_results(metrics, errors)


if __name__ == "__main__":
    asyncio.run(main())