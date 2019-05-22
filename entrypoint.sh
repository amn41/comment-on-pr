#!/usr/bin/env ruby

require "octokit"

push = File.read(ENV.fetch("GITHUB_EVENT_PATH"))

github = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

# TODO: check that this is a push event

if !ENV["GITHUB_TOKEN"]
  puts "Missing GITHUB_TOKEN"
  exit(1)
end

repo = push["repository"]["full_name"]
pulls = github.pull_requests(repo, state: "open")

branch_name = push["ref"].split("/").last
pr = pulls.find { |pr| pr.dig("head", "ref") == branch_name }

if !pr
  STDERR.puts "Couldn't find an open pull request for branch #{branch_name}."
  exit(1)
end

# TODO: configurable comment message.
github.add_comment(repo, pr["number"], "Schema changed!")