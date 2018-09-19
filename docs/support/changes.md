---
layout: default
title: Changes
permalink: /changes/
---

Spacecraft Versions
===================

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
