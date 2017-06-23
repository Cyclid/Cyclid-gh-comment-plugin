Cyclid Github Comments plugin
==========================

This is an Action  plugin for Cyclid which can add comments to Github Issues & Pull Requests.

# Installation

Install the plugin and restart Cyclid & Sidekiq

```
$ gem install cyclid-gh-comment-plugin
$ service cyclid restart
$ service sidekiq restart
```

# Usage

| Option | Required? | Default | Description |
| --- | --- | --- | --- |
| repo | Y | _None_ | Repository name |
| number | Y | _None_ | The Issue or Pull Request ID |
| comment | N | _None_ | The comment to add |
| path | N | _None_ | A path to the a file on the build host. The file contents will be used as the comment text |

One of either `comment` or `path` must be given. If both are given, `path` will take precedence.

The repository name must be in the form of owner/repository E.g. "Cyclid/Test". The plugin will
use the Github OAuth token is one is available to add comments to Private repositories.

The Github plugin will add the repository owner, repository name and Pull Request ID to the context as follows:

| Name | Description |
| --- | --- |
| github\_owner | The owner of the repository E.g. 'Cyclid' |
| github\_repository | The repository name E.g. 'Test' |
| github\_number | The Pull Request ID |

## Examples

Add a comment to Pull Request #1 for the Cyclid/Test repository:

```
{
  "name": "comment",
  "steps": [
    "action": "github_comment",
    "repo": "Cyclid/Test"
    "number": 1
    "comment": "This is a test message from inside %{name}"
  ]
}
```

(or in YAML)

```
- name: comment
  steps:
  - action: github_comment
    repo: Cyclid/Test
    number: 1
    comment: This is a test message from inside %{name}
``` 

Read the contents of a file and post it as a comment:

```
{
  "name": "comment",
  "steps": [
    "action": "github_comment",
    "repo": "Cyclid/Test"
    "number": 1
    "path": "/path/to/file"
  ]
}
```

Add a comment to the current Pull Request

```
{
  "name": "comment",
  "steps": [
    "action": "github_comment",
    "repo": "%{github_owner}/%{github_repo}"
    "number": %{github_number}
    "comment": "Hello from Cyclid"
  ]
}
```
