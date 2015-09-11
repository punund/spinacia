# Popeye solving server

## WebSockets API

### Client messages

#### solve

    token: (normally email)
    input: popeye input

### Server messages

#### queued

    id: task id

Accepted for solving

#### rejected

    errors: [ error text ]

Not accepted

#### solved

    stdout: popeye stdout

Popeye finished successfully

#### failed

    stderr: popeye srderr
    code: popeye exit code

There was a sysntax or logical error in input

## REST API (not implemented)

All requests must be made with `Content-Type: application/vnd.api+json` header.

### Submitting task

    POST /tasks

    { "data":
      { "user": "User id string"
      , "input": "BeginProblem Stipulation hs#2 Pieces White ..."  // popeye input
      , "type": "single"
      }
    }

response if successful:

  { "data":
    "id": "588ad0f8-5346-11e5-b16f-74d4351821c3"
  }

response if errors were encountered:

    {"errors":
      [ "title": "quota exceeded"
      , "detail": "You may not submit more problems"
      ]
    }


### Checking existing task

    GET /tasks/588ad0f8-5346-11e5-b16f-74d4351821c3

response if found:

    { "data":
      { "state": "started" | "queued" | "finished"
      , "stdout": "Popeye Linux-3.19.0-21-generic-x86_64-32Bit v4.69 (1024 MB)..."
      , "stderr": "Both sides need a king..." | ""
      }
    }

response if not found:

    {"errors":
      [ "title": "Task not found"
      , "detail": "No such task."
      ]
    }
