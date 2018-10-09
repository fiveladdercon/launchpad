---
layout: default
title: Changes
permalink: /changes
---

Spacecraft Versions
===================

### 0.4.0 ###

- Major additions to the engine library: defines.pl, filter.pl, json.pl,
  logical.pl, pack.pl, verilog.pl
- Solid work in the tests directory, adding the run command, to run the
  local run.pl script and a mocha-like framework.

### 0.3.0 ###

- Fixed a fueling bug where descriptions and properties were getting added
  to the grand-parent region instead of the parent region for untyped regions.
- Fixed a bug in sc_set_children that failed when the space to insert in the
  region was the exact size of the region.
- Added sc_is_first_child & sc_is_last_child APIs.
- Renamed calc.pl to math.pl and EngineHelp.pm to EngineUtils.pm
- Tweaked map.pl
- Added data.pl & rf.pl
- Updated engine template
