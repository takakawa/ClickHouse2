#!/usr/bin/env python

"""Script for automatic sync PRs handling in private repos"""

import argparse
import sys

from get_robot_token import get_best_robot_token
from pr_info import PRInfo
from github_helper import GitHub
from commit_status_helper import get_commit, post_commit_status
from report import FAILURE, SUCCESS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description="Script for handling sync PRs",
    )
    parser.add_argument(
        "--merge",
        action="store_true",
        help="merge sync pr",
    )
    parser.add_argument(
        "--status",
        action="store_true",
        help="check and set sync pr status",
    )
    args = parser.parse_args()
    return args


def merge_sync_pr(gh, sync_pr):
    if not sync_pr:
        print("Sync PR not found - exiting")
        return

    if sync_pr.state == "closed":
        print(f"Sync PR [{sync_pr.number}] already closed - exiting")
        sys.exit(0)

    if sync_pr.state != "open":
        print(
            f"WARNING: Unknown Sync PR [{sync_pr.number}] state [{sync_pr.state}] - exiting"
        )
        sys.exit(0)

    print(f"Trying to merge Sync PR [{sync_pr.number}]")
    if sync_pr.draft:
        gh.toggle_pr_draft(sync_pr)
    sync_pr.merge()


def set_sync_status(gh, pr_info, sync_pr):
    if not sync_pr or not sync_pr.mergeable:
        post_commit_status(
            get_commit(gh, pr_info.sha), FAILURE, "", "Sync PR failure", "A Sync"
        )
    else:
        post_commit_status(get_commit(gh, pr_info.sha), SUCCESS, "", "", "A Sync")


def main():
    args = parse_args()

    assert args.merge ^ args.status

    gh = GitHub(get_best_robot_token())

    pr_info = PRInfo()
    assert pr_info.merged_pr, "BUG. merged PR number could not been determined"

    prs = gh.get_pulls_from_search(
        query=f"head:sync-upstream/pr/{pr_info.merged_pr} org:ClickHouse type:pr",
        repo="ClickHouse/clickhouse-private",
    )

    sync_pr = None

    if len(prs) > 1:
        print(f"WARNING: More than one PR found [{prs}] - exiting")
    elif len(prs) == 0:
        print("WARNING: No Sync PR found")
    else:
        sync_pr = prs[0]

    if args.merge:
        merge_sync_pr(gh, sync_pr)
    elif args.status:
        set_sync_status(gh, pr_info, sync_pr)


if __name__ == "__main__":
    main()
