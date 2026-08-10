/* ────────────────────────────────────────────────────────────
 *  ryanscherbarth.com
 *
 *  No framework, no build step. Everything scroll-linked runs
 *  through ONE rAF pass that reads measurements from a cache and
 *  writes only CSS custom properties — so scrolling never forces
 *  a synchronous layout.
 * ──────────────────────────────────────────────────────────── */

(function () {
  "use strict";

  var root = document.documentElement;
  var body = document.body;

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  function clamp(v, lo, hi) { return v < lo ? lo : v > hi ? hi : v; }

  // Ease used wherever a value should hang back and then resolve fast.
  function easeInOutCubic(t) {
    return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
  }

  function on(el, type, fn, opts) {
    if (el) el.addEventListener(type, fn, opts || false);
  }

  function $(sel, ctx) { return (ctx || document).querySelector(sel); }
  function $$(sel, ctx) {
    return Array.prototype.slice.call((ctx || document).querySelectorAll(sel));
  }

  /* ══════════════════════════════════════════════════════════
   *  The address bar
   *
   *  Two modules want to write it: the section index, which
   *  tracks the section you are reading, and the frame viewer,
   *  which names the photograph you are looking at. They cannot
   *  both own it, so the viewer claims it for as long as it is
   *  open and the section index stands down — a photograph is the
   *  more specific answer to "where am I" than the section it
   *  happens to sit in.
   *
   *  Both write with replaceState, never pushState: a scroll or a
   *  walk through a plate must not stuff the back button.
   * ══════════════════════════════════════════════════════════ */

  var canReplace = !!(window.history && history.replaceState);

  // #photo=<collection>/<frame>. Neither half moves when a photograph is
  // added: the collection is its own data-frame-key (or a slug of its
  // title), and the frame is the source basename — not a packed index,
  // which renumbers, and not the href, which carries a Sprockets digest.
  var PHOTO_HASH = "#photo=";

  // Set by the viewer, read by the section index.
  var viewerHoldsUrl = false;

  function slug(s) {
    return String(s == null ? "" : s)
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "");
  }

  function replaceUrl(url) {
    if (!canReplace) return;
    // Some browsers rate-limit replaceState; never fatal.
    try { history.replaceState(history.state, "", url); } catch (e) { /* noop */ }
  }

  /* ══════════════════════════════════════════════════════════
   *  Scroll bus
   *
   *  Modules register a read-free writer here. measure() is the
   *  only place allowed to touch layout.
   * ══════════════════════════════════════════════════════════ */

  var writers = [];
  var measurers = [];
  var ticking = false;
  var scrollY = 0;

  function registerScroll(measureFn, writeFn) {
    if (measureFn) measurers.push(measureFn);
    if (writeFn) writers.push(writeFn);
  }

  function measureAll() {
    for (var i = 0; i < measurers.length; i++) measurers[i]();
    schedule();
  }

  function frame() {
    ticking = false;
    scrollY = window.pageYOffset || root.scrollTop || 0;
    for (var i = 0; i < writers.length; i++) writers[i](scrollY);
  }

  function schedule() {
    if (!ticking) {
      ticking = true;
      requestAnimationFrame(frame);
    }
  }

  on(window, "scroll", schedule, { passive: true });

  var resizeTimer;
  on(window, "resize", function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(measureAll, 120);
  }, { passive: true });

  // Fonts landing changes text metrics, which moves every anchor.
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(measureAll).catch(function () {});
  }

  /* ══════════════════════════════════════════════════════════
   *  Scroll progress
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var bar = $(".progress");
    if (!bar) return;

    var max = 1;

    registerScroll(
      function () {
        max = Math.max(1, root.scrollHeight - window.innerHeight);
      },
      function (y) {
        bar.style.setProperty("--scroll-p", clamp(y / max, 0, 1).toFixed(4));
      }
    );
  })();

  /* ══════════════════════════════════════════════════════════
   *  Nav morph
   *
   *  --nav-p : linear 0→1. Drives position only. Because it is
   *            linear against scroll, translate = travel − scrollY,
   *            so the link row stays visually pinned to the photo
   *            while the photo scrolls away.
   *  --nav-s : eased and back-loaded. Drives size, tracking, the
   *            bar tint and the brand fade, so the row compresses
   *            into the bar right at the end of the journey rather
   *            than shrinking the whole way up.
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var nav = $(".nav");
    var masthead = $(".masthead");
    if (!nav) return;

    if (!masthead) {
      // Interior page: the bar is simply there.
      body.classList.add("is-docked");
      return;
    }

    body.classList.add("has-masthead");

    // The plate opens on nothing but the photograph, and the bar stays out
    // of it for most of the way. It starts arriving a little over halfway
    // down the hero and is fully in exactly as the hero clears the screen —
    // so the bar lands at the same moment the profile takes over.
    //
    // Measured off the masthead itself rather than innerHeight: the hero is
    // 100svh, and on mobile svh and innerHeight disagree by the height of
    // the URL bar, which would leave the fade finishing early or late.
    var START = 0;
    var END = 1;
    var docked = false;

    registerScroll(
      function () {
        var h = masthead.offsetHeight || window.innerHeight;
        START = h * 0.55;
        END = h;
      },
      function (y) {
        var s = easeInOutCubic(clamp((y - START) / Math.max(1, END - START), 0, 1));

        root.style.setProperty("--nav-s", s.toFixed(4));

        var isDocked = s > 0.5;
        if (isDocked !== docked) {
          docked = isDocked;
          body.classList.toggle("is-docked", isDocked);
        }
      }
    );
  })();

  /* ══════════════════════════════════════════════════════════
   *  Favicon
   *
   *  A green dot that breathes, matching the pip beside the brand.
   *  Drawn to a canvas and swapped in as a data URI each frame: SVG
   *  favicons do not animate outside Firefox, and an APNG cannot be
   *  paused for reduced-motion. This can.
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var link = document.querySelector('link[rel="icon"]');
    if (!link || !window.HTMLCanvasElement) return;

    var S = 64;
    var canvas = document.createElement("canvas");
    canvas.width = canvas.height = S;
    var ctx = canvas.getContext && canvas.getContext("2d");
    if (!ctx) return;

    var mid = S / 2;
    var still =
      window.matchMedia &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    function draw(t) {
      // Cosine, so the turn at each end of the cycle is soft — a linear
      // ramp would tick at the top and bottom of every breath.
      var pulse = still ? 0.35 : (1 - Math.cos(t * Math.PI * 2)) / 2;

      ctx.clearRect(0, 0, S, S);

      // The halo grows AND brightens together. Brightness alone reads as a
      // blinking light; adding radius is what makes it radiate.
      var r = 12 + pulse * 15;
      var halo = ctx.createRadialGradient(mid, mid, 0, mid, mid, r);
      halo.addColorStop(0, "rgba(124,195,154," + (0.34 + pulse * 0.3) + ")");
      halo.addColorStop(0.5, "rgba(124,195,154," + (0.14 + pulse * 0.18) + ")");
      halo.addColorStop(1, "rgba(124,195,154,0)");
      ctx.fillStyle = halo;
      ctx.beginPath();
      ctx.arc(mid, mid, r, 0, Math.PI * 2);
      ctx.fill();

      // The core is fixed. A dot that changes size reads as a zoom.
      ctx.fillStyle = "#5faa80";
      ctx.beginPath();
      ctx.arc(mid, mid, 11, 0, Math.PI * 2);
      ctx.fill();

      link.href = canvas.toDataURL("image/png");
    }

    draw(0);
    if (still) return;

    // Slow on purpose. Background tabs throttle timers to roughly 1s, so a
    // long cycle degrades to a coarser version of the same breath instead
    // of stuttering.
    var PERIOD = 5200;
    var t0 = Date.now();
    setInterval(function () {
      draw(((Date.now() - t0) % PERIOD) / PERIOD);
    }, 140);
  })();

  /* ══════════════════════════════════════════════════════════
   *  Menu
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var toggle = $(".nav__toggle");
    var menu = $(".menu");
    if (!toggle || !menu) return;

    var lastFocus = null;

    function open() {
      lastFocus = document.activeElement;
      body.classList.add("menu-open", "is-locked");
      toggle.setAttribute("aria-expanded", "true");
      var first = $(".menu__link", menu);
      if (first) first.focus();
    }

    function close() {
      body.classList.remove("menu-open", "is-locked");
      toggle.setAttribute("aria-expanded", "false");
      if (lastFocus && lastFocus.focus) lastFocus.focus();
    }

    on(toggle, "click", function (e) {
      e.stopPropagation();
      body.classList.contains("menu-open") ? close() : open();
    });

    on(menu, "click", function (e) {
      if (e.target === menu) close();
    });

    on(document, "keydown", function (e) {
      if (!body.classList.contains("menu-open")) return;

      if (e.key === "Escape") { close(); return; }

      if (e.key === "Tab") {
        var focusables = $$("a[href], button:not([disabled])", menu);
        if (!focusables.length) return;
        var first = focusables[0];
        var last = focusables[focusables.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    });
  })();

  /* ══════════════════════════════════════════════════════════
   *  Reveal on scroll
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var items = $$(".reveal");
    if (!items.length) return;

    if (!("IntersectionObserver" in window) || reduceMotion.matches) {
      items.forEach(function (el) { el.classList.add("is-in"); });
      return;
    }

    // threshold 0 — NOT a fraction. A .reveal wrapping a long list can be
    // many viewports tall, and no fractional threshold is reachable once the
    // element is taller than viewport / threshold: the section would sit at
    // opacity 0 forever. rootMargin alone gives the "slightly into view" feel.
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-in");
        io.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -6% 0px", threshold: 0 });

    items.forEach(function (el, i) {
      // Stagger only within a group, never across the whole page.
      var n = parseInt(el.getAttribute("data-reveal-i"), 10);
      if (isNaN(n)) n = i % 6;
      el.style.transitionDelay = (n * 0.055).toFixed(3) + "s";
      el.classList.add("is-armed");
      io.observe(el);
    });

    // Failsafe. Anything still hidden two seconds in is revealed outright:
    // a deep-link that lands mid-page, a browser that never fires the
    // observer, an element scrolled past during load. Content wins.
    setTimeout(function () {
      items.forEach(function (el) {
        if (!el.classList.contains("is-in")) {
          el.style.transitionDelay = "0s";
          el.classList.add("is-in");
        }
      });
    }, 2000);
  })();

  /* ══════════════════════════════════════════════════════════
   *  Gallery
   *
   *  Scroll-snap owns the interaction; JS only mirrors state into
   *  the segment bar and runs the optional dwell clock.
   * ══════════════════════════════════════════════════════════ */

  function initGallery(gallery) {
    var viewport = $(".gallery__viewport", gallery);
    var slides = $$(".gallery__slide", gallery);
    var segs = $$(".gallery__seg", gallery);
    var prev = $(".gallery__arrow--prev", gallery);
    var next = $(".gallery__arrow--next", gallery);
    var counter = $(".gallery__count", gallery);
    if (!viewport || slides.length < 1) return;

    var index = 0;
    var autoplay = parseInt(gallery.getAttribute("data-autoplay"), 10);
    var canPlay = !isNaN(autoplay) && autoplay > 0 && !reduceMotion.matches && slides.length > 1;

    function paint() {
      segs.forEach(function (seg, i) {
        seg.classList.toggle("is-active", i === index);
        seg.classList.toggle("is-done", i < index);
        seg.setAttribute("aria-current", i === index ? "true" : "false");
        if (i !== index) seg.style.removeProperty("--seg-p");
      });

      slides.forEach(function (slide, i) {
        // Keep off-screen slides out of the a11y tree and tab order.
        slide.setAttribute("aria-hidden", i === index ? "false" : "true");
      });

      if (counter) {
        counter.textContent = (index + 1) + " / " + slides.length;
      }

      if (prev) prev.disabled = index === 0 && !canPlay;
      if (next) next.disabled = index === slides.length - 1 && !canPlay;

      // A segment that is not animating should read as fully drawn.
      if (!canPlay && segs[index]) segs[index].style.setProperty("--seg-p", "1");
    }

    function goTo(i, smooth) {
      index = clamp(i, 0, slides.length - 1);
      var left = slides[index].offsetLeft - viewport.offsetLeft;
      if (smooth === false && "scrollTo" in viewport) {
        viewport.scrollTo({ left: left, behavior: "auto" });
      } else {
        viewport.scrollLeft = left;
      }
      paint();
      resetClock();
    }

    // Sync index from native scrolling (touch swipe, trackpad, keys).
    var syncing = false;
    on(viewport, "scroll", function () {
      if (syncing) return;
      syncing = true;
      requestAnimationFrame(function () {
        syncing = false;
        var w = viewport.clientWidth || 1;
        var i = Math.round(viewport.scrollLeft / w);
        if (i !== index) {
          index = clamp(i, 0, slides.length - 1);
          paint();
          resetClock();
        }
      });
    }, { passive: true });

    on(prev, "click", function () {
      goTo(index === 0 ? slides.length - 1 : index - 1);
    });

    on(next, "click", function () {
      goTo(index === slides.length - 1 ? 0 : index + 1);
    });

    segs.forEach(function (seg, i) {
      on(seg, "click", function () { goTo(i); });
    });

    on(viewport, "keydown", function (e) {
      if (e.key === "ArrowRight") { e.preventDefault(); goTo(index + 1); }
      if (e.key === "ArrowLeft")  { e.preventDefault(); goTo(index - 1); }
    });

    /* ── Dwell clock ────────────────────────────────────────
     * The segment bar doubles as the timer: the active segment
     * fills across its dwell, then hands off to the next.       */

    var elapsed = 0;
    var last = 0;
    var playing = false;
    var raf = 0;
    var paused = false;
    var visible = false;

    function resetClock() { elapsed = 0; last = 0; }

    function step(ts) {
      if (!playing) return;
      if (!last) last = ts;
      var dt = ts - last;
      last = ts;

      if (!paused) {
        elapsed += dt;
        var p = clamp(elapsed / autoplay, 0, 1);
        if (segs[index]) segs[index].style.setProperty("--seg-p", p.toFixed(4));
        if (p >= 1) {
          goTo(index === slides.length - 1 ? 0 : index + 1);
        }
      }

      raf = requestAnimationFrame(step);
    }

    function play() {
      if (playing || !canPlay) return;
      playing = true;
      last = 0;
      gallery.classList.add("is-playing");
      raf = requestAnimationFrame(step);
    }

    function stop() {
      playing = false;
      gallery.classList.remove("is-playing");
      cancelAnimationFrame(raf);
    }

    if (canPlay) {
      // Only run the clock while the gallery is on screen.
      var io = new IntersectionObserver(function (entries) {
        visible = entries[0].isIntersecting;
        visible && !document.hidden ? play() : stop();
      }, { threshold: 0.35 });
      io.observe(gallery);

      on(document, "visibilitychange", function () {
        document.hidden || !visible ? stop() : play();
      });

      // Reading the caption or hovering should not cost you the slide.
      on(gallery, "mouseenter", function () { paused = true; });
      on(gallery, "mouseleave", function () { paused = false; });
      on(gallery, "focusin", function () { paused = true; });
      on(gallery, "focusout", function () { paused = false; });
      on(gallery, "touchstart", function () { paused = true; }, { passive: true });
    }

    registerScroll(function () {
      // Re-align after a resize changes slide width.
      if (slides[index]) viewport.scrollLeft = slides[index].offsetLeft - viewport.offsetLeft;
    }, null);

    paint();
  }

  $$(".gallery").forEach(initGallery);

  /* ══════════════════════════════════════════════════════════
   *  Disclosure
   * ══════════════════════════════════════════════════════════ */

  $$("[data-disclosure]").forEach(function (trigger) {
    var panel = document.getElementById(trigger.getAttribute("aria-controls"));
    if (!panel) return;

    panel.classList.remove("is-open");
    trigger.setAttribute("aria-expanded", "false");

    on(trigger, "click", function () {
      var open = trigger.getAttribute("aria-expanded") === "true";
      trigger.setAttribute("aria-expanded", open ? "false" : "true");
      panel.classList.toggle("is-open", !open);
      // Height changed — every downstream offset just moved.
      setTimeout(measureAll, 620);
    });
  });

  /* ══════════════════════════════════════════════════════════
   *  Trajectory timeline
   *
   *  The axis runs newest at the top: scrolling down walks backwards
   *  through the record. The chart's geometry is entirely CSS —
   *  pixels-per-month is the plot height over the span, and every bar
   *  is a transform on its own --t / --d / --lane. Nothing here
   *  writes layout.
   *
   *  What JS owns is the coupling between the two columns. measure()
   *  banks the document band each entry occupies; write() finds the
   *  band under the reading line and parks the playhead on the month
   *  that engagement began. It parks rather than glides on purpose —
   *  the playhead is then always inside the bar you are reading, so
   *  the lit bars beside it are exactly the things that were running
   *  alongside it. The hop between entries is a CSS transition.
   *
   *  The record cannot be positioned by date — four engagements start
   *  in the same month and the next starts the month after, so an
   *  honest per-date layout would need an axis tens of thousands of
   *  pixels tall. The chart stays honest instead, and the playhead
   *  carries the correspondence.
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var tl = $("[data-timeline]");
    if (!tl) return;

    var plot = $(".tl__plot", tl);
    var play = $(".tl__play", tl);
    var gaugeDate = $(".tl__gauge-date", tl);
    var gaugeCount = $(".tl__gauge-count", tl);
    var items = $$(".tl-entry", tl);
    var bars = $$(".tl-bar", tl);
    if (!plot || !items.length) return;

    var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    var span = parseFloat(tl.getAttribute("data-span")) || 1;
    var year0 = parseInt(tl.getAttribute("data-y0"), 10) || 2022;
    var month0 = (parseInt(tl.getAttribute("data-m0"), 10) || 1) - 1;

    var mpx = 12;      // pixels per month inside the plot
    var bands = [];    // {top, bottom, t, i} per visible entry
    var bounds = [];   // {t, d} per bar, in months
    var navH = 68;
    var viewH = 800;
    var cur = -2;      // entry the reading line last landed on

    registerScroll(
      function () {
        var i;

        navH = parseFloat(getComputedStyle(root).getPropertyValue("--nav-h")) || 68;
        viewH = window.innerHeight || 800;
        mpx = plot.offsetHeight / span;

        bands = [];
        var page = window.pageYOffset || 0;

        for (i = 0; i < items.length; i++) {
          if (items[i].classList.contains("is-hidden")) continue;
          var box = items[i].getBoundingClientRect();
          bands.push({
            top: box.top + page,
            bottom: box.bottom + page,
            t: parseFloat(items[i].getAttribute("data-t")) || 0,
            i: i
          });
        }

        bounds = [];
        for (i = 0; i < bars.length; i++) {
          bounds.push({
            t: parseFloat(bars[i].getAttribute("data-t")) || 0,
            d: parseFloat(bars[i].getAttribute("data-d")) || 1
          });
        }

        cur = -2;
      },

      function (y) {
        if (!bands.length) return;

        // Read a little above centre — where the eye actually sits.
        var line = y + navH + (viewH - navH) * 0.38;
        var head = bands[0];
        var foot = bands[bands.length - 1];

        var on = line > head.top - 160 && line < foot.bottom + 160;
        tl.classList.toggle("is-scanning", on);
        if (!on) {
          if (cur !== -1) paint(-1);
          return;
        }

        var k = 0;
        if (line >= foot.bottom) {
          k = bands.length - 1;
        } else {
          while (k < bands.length - 1 && bands[k + 1].top <= line) k++;
        }

        if (bands[k].i !== cur) paint(k);
      }
    );

    function paint(k) {
      var t = k < 0 ? -1 : bands[k].t;
      var running = 0;
      var i;

      cur = k < 0 ? -1 : bands[k].i;

      // Time runs down the axis into the past, so the playhead is
      // measured from the present at the top.
      if (k >= 0) {
        play.style.setProperty("--tl-play", ((span - t) * mpx).toFixed(1) + "px");
      }

      for (i = 0; i < bars.length; i++) {
        var off = bars[i].classList.contains("is-off");
        var hit = !off && t >= 0 && t >= bounds[i].t && t < bounds[i].t + bounds[i].d;
        bars[i].classList.toggle("is-live", hit);
        bars[i].classList.toggle("is-read", !off && i === cur);
        items[i].classList.toggle("is-read", i === cur);
        if (hit) running++;
      }

      if (!gaugeDate || t < 0) return;

      var abs = month0 + Math.floor(t);
      gaugeDate.textContent =
        MONTHS[((abs % 12) + 12) % 12] + " " + (year0 + Math.floor(abs / 12));
      gaugeCount.textContent =
        running + (running === 1 ? " thing running" : " things running");
    }

    /* ── Track filter ───────────────────────────────────────── */

    var filters = $$("[data-filter]");
    if (!filters.length) return;

    filters.forEach(function (btn) {
      on(btn, "click", function () {
        var want = btn.getAttribute("data-filter");

        filters.forEach(function (b) {
          b.setAttribute("aria-pressed", b === btn ? "true" : "false");
        });

        items.forEach(function (el, i) {
          // data-track is a space-separated list, so an entry can answer to
          // more than one pill. Match a whole token — a plain indexOf on the
          // string would let "pro" match "professional".
          var tracks = (el.getAttribute("data-track") || "").split(/\s+/);
          var keep = want === "all" || tracks.indexOf(want) !== -1;
          el.classList.toggle("is-hidden", !keep);
          if (!keep) el.classList.remove("is-read");
          if (!bars[i]) return;
          bars[i].classList.toggle("is-off", !keep);
          if (!keep) bars[i].classList.remove("is-live", "is-read");
        });

        // Hiding entries moves every band below them.
        measureAll();
      });
    });
  })();

  /* ══════════════════════════════════════════════════════════
   *  Frame viewer
   *
   *  Nothing here knows what a mosaic is. Any collection marked
   *  [data-frames] hands the viewer its own frames — a packed
   *  contact sheet, a carousel, whatever comes next — and prev/next
   *  walk that collection alone.
   *
   *  A frame is [data-frame] and names the file to open on its href
   *  or in data-full. Every tile on a mosaic is a real link, so with
   *  no JS the plate still opens photographs; this upgrades that into
   *  a modal. Anything with no [data-frame] — a clip, say — is simply
   *  not in the walk.
   *
   *  Every open frame also has an address: #photo=<sheet>/<frame>,
   *  written as you walk and honoured on load, so any photograph on
   *  the site can be sent to somebody.
   *
   *  Nothing here is scroll-linked; the layout of the sheet itself
   *  is entirely CSS.
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var viewer = $("#plate-viewer");
    var sheets = $$("[data-frames]");
    if (!viewer || !sheets.length) return;

    // Only reliable from the body: an ancestor mid-transform would
    // otherwise become the containing block for position: fixed.
    body.appendChild(viewer);

    var img = $(".viewer__img", viewer);
    var plateEl = $(".viewer__plate", viewer);
    var metaEl = $(".viewer__meta", viewer);
    var countEl = $(".viewer__count", viewer);
    var capEl = $(".viewer__cap", viewer);
    var clipEl = $(".viewer__clip", viewer);
    var frameEl = $(".viewer__frame", viewer);
    var prevBtn = $(".viewer__nav--prev", viewer);
    var nextBtn = $(".viewer__nav--next", viewer);

    var group = [];   // the frames of the collection being read
    var sheetOf = null;
    var index = 0;
    var opener = null;
    var hideTimer = 0;
    var restoreUrl = "";  // the address to hand back when the viewer closes

    // Sheets that share a data-frame-group are read as ONE collection, so
    // prev/next walks straight through every plate in the section instead
    // of dead-ending at the edge of each. The plate headings stay — only
    // the walk is joined.
    function sheetsOf(sheet) {
      var g = sheet.getAttribute("data-frame-group");
      if (!g) return [sheet];

      return sheets.filter(function (s) { return s.getAttribute("data-frame-group") === g; });
    }

    function framesOf(sheet) {
      return sheetsOf(sheet).reduce(function (all, s) {
        return all.concat($$("[data-frame]", s));
      }, []);
    }

    // The sheet a given frame actually belongs to — the head shows that
    // plate's title even while the walk spans several.
    function ownerOf(frame) {
      for (var i = 0; i < sheets.length; i++) {
        if (sheets[i].contains(frame)) return sheets[i];
      }
      return sheetOf;
    }

    // A mosaic tile is a link and carries the file on href; a carousel
    // slide is not, and carries it in data-full.
    function srcOf(frame) {
      return frame.getAttribute("data-full") || frame.getAttribute("href") || "";
    }

    // A frame is a clip when its tile holds one. Nothing else needs saying:
    // the tile already carries the poster and the source.
    function clipOf(frame) { return $("video", frame); }

    // The frame's own alt is the caption. It is the one piece of writing
    // about that photograph the site already has; a clip keeps the same
    // sentence on the tile's own label.
    function altOf(frame) {
      var pic = $("img", frame);
      if (pic) return pic.getAttribute("alt") || "";

      var clip = clipOf(frame);
      return (clip && clip.getAttribute("aria-label")) ||
             frame.getAttribute("aria-label") || "";
    }

    // Silence and unload. Called before every move and on close, so a clip
    // can never be left running behind a shut dialog.
    function stopClip() {
      if (!clipEl.getAttribute("src")) return;

      try {
        clipEl.pause();
        clipEl.removeAttribute("src");
        clipEl.removeAttribute("poster");
        clipEl.load();  // drops what has already been buffered
      } catch (e) { /* nothing here is worth failing the close over */ }

      clipEl.hidden = true;
    }

    /* ── Pinch and pan ──────────────────────────────────────
     *
     * Native page zoom is not blocked anywhere — the viewport meta sets no
     * maximum-scale and nothing calls preventDefault on a touch — but it is
     * the wrong tool here. The viewer is position: fixed, so the browser
     * zooms the whole pinned dialog: the caption, the Close button and the
     * bar all magnify together, panning fights the locked body, and the
     * scale is capped at whatever the browser allows. What is wanted is the
     * photograph on its own, as far in as the file goes.
     *
     * So the still carries its own transform, and the stage claims the
     * gesture with touch-action so two things are never zooming at once.
     * Pointer Events, not touch: one code path covers finger, pen and
     * trackpad, and pointer capture keeps a drag alive off the element.
     *
     * A clip is left alone — the stage there belongs to its transport.  */

    var stage = $(".viewer__stage", viewer);

    var zoom = 1;
    var panX = 0;
    var panY = 0;
    var points = [];      // live pointers over the stage
    var pinch = null;     // baseline of a two-finger gesture
    var travelled = false; // this gesture moved, so the click ending it is not a tap
    var lastTap = 0;

    // Deliberately no upper bound: "as far in as they want". The lower
    // bound is 1, which is the frame fitted to the stage.
    var TAP_ZOOM = 2.5;

    function paintZoom(eased) {
      img.classList.toggle("is-eased", !!eased);
      img.style.transform = zoom === 1 && !panX && !panY
        ? ""
        : "translate(" + panX.toFixed(2) + "px," + panY.toFixed(2) + "px) scale(" + zoom.toFixed(4) + ")";
    }

    function resetZoom() {
      zoom = 1;
      panX = 0;
      panY = 0;
      points = [];
      pinch = null;
      paintZoom(false);
    }

    // Only as far as there is frame left to reveal. At fit there is no
    // travel at all, so a swipe over an unzoomed photograph does nothing.
    function clampPan() {
      var mx = Math.max(0, (img.offsetWidth * zoom - stage.clientWidth) / 2);
      var my = Math.max(0, (img.offsetHeight * zoom - stage.clientHeight) / 2);
      panX = clamp(panX, -mx, mx);
      panY = clamp(panY, -my, my);
    }

    // Pointer position relative to the middle of the stage, which is where
    // the frame's transform-origin sits.
    function atCentre(x, y) {
      var r = stage.getBoundingClientRect();
      return { x: x - r.left - r.width / 2, y: y - r.top - r.height / 2 };
    }

    function spread() {
      var dx = points[0].x - points[1].x;
      var dy = points[0].y - points[1].y;
      return Math.sqrt(dx * dx + dy * dy);
    }

    function midpoint() {
      return atCentre((points[0].x + points[1].x) / 2, (points[0].y + points[1].y) / 2);
    }

    // Scale about a point and keep whatever was under it there.
    function zoomTo(next, c) {
      if (!isFinite(next)) return;
      next = next < 1 ? 1 : next;

      var px = (c.x - panX) / zoom;
      var py = (c.y - panY) / zoom;

      zoom = next;
      panX = c.x - next * px;
      panY = c.y - next * py;
      clampPan();
    }

    function zoomable() { return !img.hidden && !!img.getAttribute("src"); }

    on(stage, "pointerdown", function (e) {
      if (!zoomable()) return;
      if (e.pointerType === "mouse" && e.button !== 0) return;

      if (!points.length) travelled = false;
      points.push({ id: e.pointerId, x: e.clientX, y: e.clientY });

      try { stage.setPointerCapture(e.pointerId); } catch (err) { /* pen quirks */ }

      if (points.length === 2) {
        pinch = { d: spread(), c: midpoint(), zoom: zoom, panX: panX, panY: panY };
      }
    });

    on(stage, "pointermove", function (e) {
      var p = null;
      for (var i = 0; i < points.length; i++) {
        if (points[i].id === e.pointerId) p = points[i];
      }
      if (!p) return;

      var dx = e.clientX - p.x;
      var dy = e.clientY - p.y;
      p.x = e.clientX;
      p.y = e.clientY;
      if (Math.abs(dx) > 1 || Math.abs(dy) > 1) travelled = true;

      if (points.length >= 2 && pinch && pinch.d > 0) {
        // Measured from the gesture's own baseline rather than accumulated
        // frame to frame, so the scale cannot drift over a long pinch.
        var next = pinch.zoom * (spread() / pinch.d);
        var here = midpoint();
        var px = (pinch.c.x - pinch.panX) / pinch.zoom;
        var py = (pinch.c.y - pinch.panY) / pinch.zoom;

        zoom = isFinite(next) && next > 1 ? next : 1;
        // The current midpoint, not the baseline one — that is what lets a
        // two-finger gesture pan and scale in the same movement.
        panX = here.x - zoom * px;
        panY = here.y - zoom * py;
        clampPan();
        paintZoom(false);
        return;
      }

      // One pointer. Below fit there is nothing to pan, and the drag is
      // left to the page — nothing in the viewer advances on a swipe, and
      // clampPan is what guarantees it stays that way.
      if (zoom <= 1) return;

      panX += dx;
      panY += dy;
      clampPan();
      paintZoom(false);
    });

    function releasePointer(e) {
      var kept = [];
      for (var i = 0; i < points.length; i++) {
        if (points[i].id !== e.pointerId) kept.push(points[i]);
      }
      points = kept;
      if (points.length < 2) pinch = null;

      // Double tap toggles. Only on the frame itself: a tap on the table
      // around it still closes the viewer, which is the older gesture.
      if (!travelled && !points.length && e.target === img) {
        var now = Date.now();

        if (now - lastTap < 320) {
          lastTap = 0;
          if (zoom > 1) {
            zoom = 1;
            panX = 0;
            panY = 0;
          } else {
            zoomTo(TAP_ZOOM, atCentre(e.clientX, e.clientY));
          }
          paintZoom(true);
        } else {
          lastTap = now;
        }
      }
    }

    on(stage, "pointerup", releasePointer);
    on(stage, "pointercancel", releasePointer);

    /* ── Addresses ──────────────────────────────────────────
     *
     * A sheet answers to its data-frame-key, or failing that to a slug
     * of the title it already prints in the viewer's head; a frame
     * answers to data-frame-id, which the server sets from the source
     * basename. Both are stable across a deploy, which an array index
     * is not — every photograph added above a frame would renumber it
     * and break every link anybody had kept.                          */

    function tokenOf(sheet, frame) {
      var k = sheet.getAttribute("data-frame-key") || slug(sheet.getAttribute("data-plate"));
      var f = frame.getAttribute("data-frame-id");
      return k && f ? k + "/" + f : "";
    }

    function findToken(token) {
      var hit = null;

      sheets.some(function (sheet) {
        return framesOf(sheet).some(function (frame) {
          if (tokenOf(sheet, frame) !== token) return false;
          hit = { sheet: sheet, frame: frame };
          return true;
        });
      });

      return hit;
    }

    function show(i) {
      index = (i % group.length + group.length) % group.length;

      var frame = group[index];
      var alt = altOf(frame);
      var clip = clipOf(frame);

      // The walk can span several plates, so the head follows the frame's
      // own sheet rather than whichever one happened to open the viewer.
      var owner = ownerOf(frame);
      if (owner) {
        plateEl.textContent = owner.getAttribute("data-plate") || "";
        metaEl.textContent = owner.getAttribute("data-meta") || "";
      }

      // Whatever was playing stops here — moving off a clip has to silence
      // it, and moving onto one has to start from a clean element.
      stopClip();

      // A new frame always arrives at fit.
      resetZoom();
      viewer.classList.toggle("is-still", !clip);

      if (clip) {
        img.hidden = true;
        img.removeAttribute("src");

        // The poster is the placeholder: the clip stands still until it is
        // asked to run, so arrowing through a plate never starts audio.
        clipEl.setAttribute("poster", clip.getAttribute("poster") || "");
        clipEl.setAttribute("src", srcOf(frame));
        clipEl.setAttribute("aria-label", alt);
        clipEl.hidden = false;
        clipEl.load();
      } else {
        img.hidden = false;
        img.setAttribute("src", srcOf(frame));
        img.setAttribute("alt", alt);
      }

      capEl.textContent = alt;
      countEl.textContent = (index + 1) + " / " + group.length;

      var token = tokenOf(sheetOf, frame);
      if (token) replaceUrl(PHOTO_HASH + token);

      // The frame either side is almost certainly the next thing wanted.
      preload(index + 1);
      preload(index - 1);
    }

    function preload(i) {
      if (group.length < 2) return;

      var frame = group[(i % group.length + group.length) % group.length];
      // A clip is megabytes and is not warmed; pulling one through an
      // Image() would fetch it and then throw it away undecoded.
      if (clipOf(frame)) return;

      var warm = new Image();
      warm.src = srcOf(frame);
    }

    function open(sheet, frame) {
      group = framesOf(sheet);
      if (group.indexOf(frame) === -1) return;
      sheetOf = sheet;

      // Focus has to go back to something that can hold it. A mosaic tile
      // is a link; a carousel slide is not, so there it returns to the
      // viewport, which is that carousel's own focus stop.
      opener = frame.hasAttribute("href") ? frame : ($(".gallery__viewport", sheet) || frame);

      // Bank the address to hand back on close — but never a photo hash.
      // Arriving on a permalink and pressing Escape should leave a clean
      // URL, not the frame you just closed.
      var hash = window.location.hash;
      restoreUrl = window.location.pathname + window.location.search +
                   (hash.indexOf(PHOTO_HASH) === 0 ? "" : hash);

      // From here the address bar is the viewer's; the section index
      // stops writing it until close() hands it back.
      viewerHoldsUrl = true;

      plateEl.textContent = sheet.getAttribute("data-plate") || "";
      metaEl.textContent = sheet.getAttribute("data-meta") || "";

      var alone = group.length < 2;
      prevBtn.hidden = alone;
      nextBtn.hidden = alone;

      show(group.indexOf(frame));

      clearTimeout(hideTimer);
      viewer.hidden = false;
      body.classList.add("is-locked");
      requestAnimationFrame(function () { viewer.classList.add("is-open"); });
      // The dialog itself, since it no longer has a Close button to land
      // on. It is aria-describedby the line that says Escape closes it.
      frameEl.focus();
    }

    function close() {
      if (viewer.hidden) return;

      viewer.classList.remove("is-open");
      body.classList.remove("is-locked");

      // Immediately, not on the fade-out timer: a clip still audible for a
      // quarter of a second after the dialog has gone is the whole failure.
      stopClip();
      resetZoom();

      hideTimer = setTimeout(function () {
        viewer.hidden = true;
        img.removeAttribute("src");
      }, reduceMotion.matches ? 0 : 260);

      // Hand the address bar back, then let the scroll bus run so the
      // section index can pick section tracking up again from here.
      viewerHoldsUrl = false;
      if (restoreUrl) replaceUrl(restoreUrl);
      restoreUrl = "";
      sheetOf = null;
      schedule();

      if (opener && opener.focus) opener.focus();
      opener = null;
    }

    // Frame → viewer. Bound on the collection rather than the document so
    // it runs before the page-transition handler and can claim the click.
    sheets.forEach(function (sheet) {
      var viewport = $(".gallery__viewport", sheet);
      var down = null;

      // A scroll-snap viewport can be dragged, and the click that ends a
      // drag is a click on the carousel, not on the photograph. Compare
      // both the pointer's travel and the viewport's.
      if (viewport) {
        on(sheet, "pointerdown", function (e) {
          down = { x: e.clientX, y: e.clientY, left: viewport.scrollLeft };
        }, { passive: true });
      }

      function dragged(e) {
        if (!down) return false;
        return Math.abs(e.clientX - down.x) > 8 ||
               Math.abs(e.clientY - down.y) > 8 ||
               Math.abs(viewport.scrollLeft - down.left) > 2;
      }

      on(sheet, "click", function (e) {
        if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button !== 0) return;

        var frame = e.target.closest ? e.target.closest("[data-frame]") : null;
        if (!frame || !sheet.contains(frame)) return;
        if (viewport && dragged(e)) return;

        e.preventDefault();
        open(sheet, frame);
      });

      // A carousel slide is not a link, so the viewport is the only focus
      // stop it has. Enter there opens whichever frame is snapped into it —
      // without this a keyboard could not reach the viewer from a carousel.
      if (viewport) {
        on(viewport, "keydown", function (e) {
          if (e.key !== "Enter" && e.key !== " ") return;

          var frames = framesOf(sheet);
          if (!frames.length) return;

          e.preventDefault();
          var w = viewport.clientWidth || 1;
          open(sheet, frames[clamp(Math.round(viewport.scrollLeft / w), 0, frames.length - 1)]);
        });
      }
    });

    // The stage closes, but the frame standing on it does not — and a clip
    // least of all: every press on its transport lands on the video itself.
    // A pan that happens to finish over the table is not a tap on it.
    on(viewer, "click", function (e) {
      if (e.target === img || e.target === clipEl) return;
      if (travelled) return;
      var hit = e.target.closest ? e.target.closest("[data-close]") : null;
      if (hit) close();
    });

    on(prevBtn, "click", function () { show(index - 1); });
    on(nextBtn, "click", function () { show(index + 1); });

    // Capture, not bubble. A focused <video> answers the arrow keys itself
    // by seeking, and it would swallow the walk through the plate before
    // this ever saw the press.
    on(document, "keydown", function (e) {
      if (viewer.hidden) return;

      if (e.key === "Escape") { e.preventDefault(); close(); return; }

      if (group.length > 1) {
        if (e.key === "ArrowRight") { e.preventDefault(); show(index + 1); return; }
        if (e.key === "ArrowLeft")  { e.preventDefault(); show(index - 1); return; }
        if (e.key === "Home")       { e.preventDefault(); show(0); return; }
        if (e.key === "End")        { e.preventDefault(); show(group.length - 1); return; }
      }

      if (e.key !== "Tab") return;

      // The clip is a stop in its own right when it is the frame on show —
      // otherwise its transport would be unreachable from the keyboard —
      // and it is only ever one stop, so Tab always leads back out of the
      // video rather than circling inside it.
      var stops = [clipEl, prevBtn, nextBtn].filter(function (el) {
        return el && !el.hidden;
      });

      // A lone still has no controls at all now that Close is gone, so the
      // dialog itself is the resting stop. Focus is never left nowhere, and
      // Escape — which #viewer-help announces — is still the way out.
      if (!stops.length) {
        e.preventDefault();
        frameEl.focus();
        return;
      }

      var first = stops[0];
      var last = stops[stops.length - 1];

      if (stops.indexOf(document.activeElement) === -1) {
        e.preventDefault();
        (e.shiftKey ? last : first).focus();
      } else if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }, true);

    /* ── Arriving on a permalink ────────────────────────────
     *
     * If the hash names a frame that is on this page, open on it.
     *
     * Straight away, not on a later frame. The script is deferred, so the
     * whole sheet is parsed and every tile is already standing — the
     * mosaic's geometry is CSS and needs no measuring pass — and opening
     * here is what claims the address bar before the scroll bus takes its
     * first pass at the bottom of this file. Deferring instead would let
     * the section index write #profile over the very hash being read.   */

    if (window.location.hash.indexOf(PHOTO_HASH) === 0) {
      var wanted = findToken(decodeURIComponent(window.location.hash.slice(PHOTO_HASH.length)));
      if (wanted) open(wanted.sheet, wanted.frame);
    }
  })();

  /* ══════════════════════════════════════════════════════════
   *  Movements
   *
   *  The three opening screens cross-fade as they pass the
   *  viewport centre, so a snap between them reads as a
   *  dissolve rather than a cut. One custom property per
   *  section; the transition itself is CSS.
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var movements = $$(".movement");
    if (!movements.length || reduceMotion.matches) return;

    var bands = [];
    var vh = 1;

    registerScroll(
      function () {
        vh = Math.max(1, window.innerHeight);
        bands = movements.map(function (el) {
          var r = el.getBoundingClientRect();
          return { top: r.top + (window.pageYOffset || 0), h: r.height };
        });
      },
      function (y) {
        // Fade on the way IN and on the way OUT only — never by distance
        // from the section's midpoint. The record is many screens tall, and
        // a midpoint measure would leave it dimmed the whole time you read it.
        var ramp = vh * 0.6;

        for (var i = 0; i < bands.length; i++) {
          var top = bands[i].top - y;          // top edge, viewport-relative
          var bottom = top + bands[i].h;       // bottom edge

          var entering = clamp((vh - top) / ramp, 0, 1);
          var leaving = clamp(bottom / ramp, 0, 1);
          var m = entering < leaving ? entering : leaving;

          // Travel: 0 while the section's top is still at or below the
          // viewport top, rising to 1 over one screen of scrolling past it.
          // This is what drives the layered parallax inside each screen.
          var sp = clamp(-top / vh, 0, 1);

          movements[i].style.setProperty("--m", m.toFixed(3));
          movements[i].style.setProperty("--sp", sp.toFixed(3));
        }
      }
    );
  })();

  /* ══════════════════════════════════════════════════════════
   *  Timeline bars → their entry
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var bars = $$(".tl-bar[data-jump]");
    if (!bars.length) return;

    bars.forEach(function (bar) {
      on(bar, "click", function () {
        var target = document.getElementById("tl-" + bar.getAttribute("data-jump"));
        if (!target) return;
        target.scrollIntoView({
          behavior: reduceMotion.matches ? "auto" : "smooth",
          block: "center"
        });
        // Make the landing obvious — the entry is mid-list, not at an edge.
        target.classList.add("is-targeted");
        setTimeout(function () { target.classList.remove("is-targeted"); }, 1600);
      });
    });
  })();

  /* ══════════════════════════════════════════════════════════
   *  Section index
   *
   *  The address bar tracks the section you are reading, so any
   *  part of the page can be linked to. replaceState, never
   *  pushState — otherwise a single scroll would stuff the back
   *  button with dozens of entries.
   *
   *  While the frame viewer is open it owns the address instead, and
   *  this stands down: a photograph's permalink is the more specific
   *  answer, and the page cannot be scrolled behind the viewer anyway,
   *  so the section this last landed on is still the right one to
   *  resume from the moment the viewer hands it back.
   * ══════════════════════════════════════════════════════════ */

  (function () {
    if (!canReplace) return;

    var sections = $$("main [id]").filter(function (el) {
      return el.matches("section, [class*='section'], header, article");
    });
    if (sections.length < 2) return;

    var bands = [];
    var current = null;
    var navH = 68;

    registerScroll(
      function () {
        navH = parseFloat(getComputedStyle(root).getPropertyValue("--nav-h")) || 68;
        bands = sections.map(function (el) {
          var r = el.getBoundingClientRect();
          return { id: el.id, top: r.top + (window.pageYOffset || 0), h: r.height };
        });
      },
      function (y) {
        // The viewer is showing one photograph and its hash names it.
        // Leave it alone until it closes.
        if (viewerHoldsUrl) return;

        // The section under the reading line, just below the bar.
        var line = y + navH + 8;
        var found = null;

        for (var i = 0; i < bands.length; i++) {
          if (line >= bands[i].top && line < bands[i].top + bands[i].h) found = bands[i].id;
        }

        // Above the first section is the top of the document, not a section.
        if (!found && y < 4) found = "";

        if (found === null || found === current) return;
        current = found;

        replaceUrl(found ? "#" + found : window.location.pathname + window.location.search);
      }
    );
  })();

  /* ══════════════════════════════════════════════════════════
   *  Elapsed-time toy
   *
   *  The footer says how long ago the site last changed. Clicking
   *  the figure walks it down the units — a compound reading, then
   *  years, months, days, hours, and on down to nanoseconds. The
   *  elapsed value is fixed at render time, so every unit agrees.
   * ══════════════════════════════════════════════════════════ */

  (function () {
    var el = $(".footer__elapsed");
    if (!el) return;

    var ms = parseFloat(el.getAttribute("data-elapsed"));
    if (!isFinite(ms) || ms < 0) return;

    var MIN = 60000, HOUR = 3600000, DAY = 86400000;
    var MONTH = DAY * 30.4375, YEAR = DAY * 365.25;

    function trim(n, dp) {
      return n.toFixed(dp).replace(/\.?0+$/, "");
    }

    // The resting reading stops at days — nobody needs the site's age to
    // the minute until they ask for it. Clicking is asking.
    function compound() {
      var rest = ms, parts = [];
      [["yr", YEAR], ["mo", MONTH], ["d", DAY]].forEach(function (u) {
        var n = Math.floor(rest / u[1]);
        if (n > 0) { parts.push(n + " " + u[0]); rest -= n * u[1]; }
      });
      return (parts.length ? parts.join(" ") : "today") + (parts.length ? " ago" : "");
    }

    var units = [
      compound,
      function () { return trim(ms / YEAR, 3) + " years ago"; },
      function () { return trim(ms / MONTH, 3) + " months ago"; },
      function () { return trim(ms / (DAY * 7), 3) + " weeks ago"; },
      function () { return trim(ms / DAY, 3) + " days ago"; },
      function () { return trim(ms / HOUR, 2) + " hours ago"; },
      function () { return trim(ms / MIN, 1) + " minutes ago"; },
      function () { return Math.round(ms / 1000).toLocaleString() + " seconds ago"; },
      function () { return Math.round(ms).toLocaleString() + " ms ago"; },
      function () { return Math.round(ms * 1e3).toLocaleString() + " \u00b5s ago"; },
      function () { return Math.round(ms * 1e6).toLocaleString() + " ns ago"; },
      function () { return Math.round(ms * 1e9).toLocaleString() + " ps ago"; }
    ];

    var i = 0;

    function paint() {
      el.textContent = "(" + units[i]() + ")";
      el.setAttribute("aria-label", "Last updated " + units[i]() + ". Activate to change units.");
    }

    on(el, "click", function () {
      i = (i + 1) % units.length;
      paint();
    });

    paint();
  })();

  /* ══════════════════════════════════════════════════════════
   *  Page transition
   * ══════════════════════════════════════════════════════════ */

  (function () {
    if (reduceMotion.matches) return;

    on(document, "click", function (e) {
      if (e.defaultPrevented || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
      if (e.button !== 0) return;

      var link = e.target.closest ? e.target.closest("a[href]") : null;
      if (!link) return;

      var href = link.getAttribute("href");
      if (!href) return;

      if (
        href.charAt(0) === "#" ||
        link.target === "_blank" ||
        link.hasAttribute("download") ||
        link.origin !== window.location.origin ||
        link.pathname === window.location.pathname
      ) return;

      e.preventDefault();
      body.classList.add("is-leaving");
      setTimeout(function () { window.location.href = href; }, 190);
    });

    // Restoring from bfcache must not leave the page faded out.
    on(window, "pageshow", function (evt) {
      if (evt.persisted) body.classList.remove("is-leaving");
    });
  })();

  /* ══════════════════════════════════════════════════════════
   *  Go
   * ══════════════════════════════════════════════════════════ */

  measureAll();

})();
