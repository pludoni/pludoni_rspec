### 0.20

- Added new default custom formatter instead of fuubar - Documentation based,
  but prints out duration and file paths of the group
- Disable Smooth Scrolling for Cuprite
- Fix: Rails 7.1 `fixture_path` or `fixture_paths`
- Add: 3 new global helpers: 
    - ``only_run_when_single_spec_and_local!``
      skip this example, only run if you are working on it and skip it later like special customers bugs etc., 
      long running crawler etc. that you want to run occasionally
    - ``local!``
      For System specs:
      prints the instructions to open the current page in your local browser if
      you run the specs remotely, create a SSH tunnel to the server during
      system specs and open the brOwser on your local machine

### 0.11

- Rails 7.1 fixture_paths deprecation
- Cuprite with ``LD_PRELOAD => ""`` to fix jmalloc errors
- Added ``PludoniRspec.coverage_enabled`` to make it possible to disable coverage
- Support Fabrication Gem versions

### 0.10

- Optional Vite build before first system spec
- Cuprite default
- ViewComponent TestHelper inclusion
- No rubocop
- local! helper to connect via ssh portforwarding
- screenshot full

### 0.9

- Gitlab artifacts integrated
- apparition revived
- Rubocop deps

### 0.5

* [9937c05c9c] - Firefox added as test driver with geckodriver-helper (Stefan Wienert)
* [4dc5ec45da] - Chrome Arguments configurable; disable-dev-shm-usage by default (Stefan Wienert)

### 0.4

* [bb76206bdf] - Headless optional; Wait-Time 30s default (Stefan Wienert)
* [22bda7c098] - Destroy_headless option + abort on production + Fuubar dependency (Stefan Wienert)

### 0.3

* [42fde09904] - Devise helper methods added; fix of screenshot method (Stefan Wienert)

### 0.2

* [26c4925347] - ChromeDriver + Configs + Contexts (Stefan Wienert)
* [4e3558a82d] - of/nf fixes; Puma added with Silence (Stefan Wienert)
* [208660cba7] - Docs; changes after first runs (Stefan Wienert)
* [b4e8767c85] - inital (Stefan Wienert)
