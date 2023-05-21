# User stories
---
<!-- vim-markdown-toc GitLab -->

* [Summary](#summary)
* [Context](#context)
* [Acceptance Criteria](#acceptance-criteria)
* [Tests](#tests)
* [Resources:](#resources)

<!-- vim-markdown-toc -->
---

## Summary

<!---
A user story should typically have a summary structured this way:

1. **As a** [user concerned by the story]
1. **I want** [goal of the story]
1. **so that** [reason for the story]


The “so that” part is optional if more details are provided in the description.

This can then become “As a user managing my properties, I want notifications when adding or removing images.”

You can read about some reasons for this structure in this [nicely put article][1].
-->
1. **As a**
1. **I want**
1. **so that**


## Context
<!---
Describe the context when you want to do that.

Try to answer the following questions:
-->
- Who:
- What:
- When:
- Where:
- Why:


## Acceptance Criteria
<!---
Describe required behavior to close review cycle.
-->


## Tests
<!---
Whrite tests scenarios in gherkin:
```gherkin

Feature: Subscribers see different articles based on their subscription level

Scenario: Free subscribers see only the free articles
  Given Free Frieda has a free subscription
  When Free Frieda logs in with her valid credentials
  Then she sees a Free article

Scenario: Subscriber with a paid subscription can access both free and paid articles
  Given Paid Patty has a basic-level paid subscription
  When Paid Patty logs in with her valid credentials
  Then she sees a Free article and a Paid article
```

```gherkin
```
-->

## Resources:
<!---
* Mockups: [Here goes a URL to or the name of the mockup(s) in inVision];
* Testing URL: [Here goes a URL to the testing branch or IP];
* Staging URL: [Here goes a URL to the feature on staging];
* Data source: [where to find data];
* Tutorial: [Fancy tutorial];
-->

<!-- Actions -->
/label ~agle::user-story

/label ~agile::dor::to-refine
