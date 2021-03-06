#!/usr/bin/env bats

load environment

@test "Split with no branches/commits fails" {
	git init
	! $GSB master split '*.c'
}

@test "Splitting linear repo" {
	git init
	make_linear_commits

	$GSB master split-a a

	run git rev-parse split-a
	[ "$status" -eq 0 ]
	[ "$output" = 2e177ee154aee27a2e10cf30b25acefbb752942c ]

	run git rev-parse master
	[ "$status" -eq 0 ]
	[ "$output" = 65f64808f13983e338c77cd9e5be9a921d187016 ]
}

@test "Splitting linear repo with remainder branch" {
	git init
	make_linear_commits

	$GSB -r rem master split-a a

	run git rev-parse split-a
	[ "$status" -eq 0 ]
	[ "$output" = 2e177ee154aee27a2e10cf30b25acefbb752942c ]

	run git rev-parse rem
	[ "$status" -eq 0 ]
	[ "$output" = 65f64808f13983e338c77cd9e5be9a921d187016 ]

	run git rev-parse master
	[ "$status" -eq 0 ]
	[ "$output" = 10e8418dfa6a9136da9368970b8954f2856362b8 ]
}

@test "-r option works without the following space" {
	git init
	make_linear_commits

	$GSB -rrem master split-a a

	run git rev-parse split-a
	[ "$status" -eq 0 ]
	[ "$output" = 2e177ee154aee27a2e10cf30b25acefbb752942c ]

	run git rev-parse rem
	[ "$status" -eq 0 ]
	[ "$output" = 65f64808f13983e338c77cd9e5be9a921d187016 ]

	run git rev-parse master
	[ "$status" -eq 0 ]
	[ "$output" = 10e8418dfa6a9136da9368970b8954f2856362b8 ]
}

@test "Splitting linear repo with multiple filenames" {
	git init
	make_linear_commits

	$GSB -r rem-c master split-ab a b

	run git rev-parse split-ab
	[ "$status" -eq 0 ]
	[ "$output" = ba2316913c0550b2ea7cb7f283afdfef8d7acfc2 ]

	run git rev-parse rem-c
	[ "$status" -eq 0 ]
	[ "$output" = 7032187efd8b43043460e2cc1391da56315e7ab9 ]
}

@test "Splitting linear repo into multiple branches" {
	git init
	make_linear_commits

	$GSB -r rem-c master split-a a -- split-b b

	run git rev-parse split-a
	[ "$status" -eq 0 ]
	[ "$output" = 2e177ee154aee27a2e10cf30b25acefbb752942c ]

	run git rev-parse split-b
	[ "$status" -eq 0 ]
	[ "$output" = 29cbbea5edd1c01131aff2cba75308061c1384f5 ]

	run git rev-parse rem-c
	[ "$status" -eq 0 ]
	[ "$output" = 7032187efd8b43043460e2cc1391da56315e7ab9 ]

	run git rev-parse master
	[ "$status" -eq 0 ]
	[ "$output" = 10e8418dfa6a9136da9368970b8954f2856362b8 ]
}

@test "Emptied source branch is deleted" {
	git init
	make_linear_commits

	$GSB master split-all a b c

	! git branch --list master | grep '' || false
}

@test "Empty remainder branch is not created" {
	git init
	make_linear_commits

	$GSB -r rem master split-all a b c

	! git branch --list rem | grep '' || false
}

@test "Untracked files remain in work tree if source is deleted" {
	git init
	make_linear_commits
	touch d

	$GSB master split-all a b c

	[ -e d ]
}
