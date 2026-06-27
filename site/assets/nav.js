// Neptune Odyssey — docs nav + global copy helper · © 2026 Neptune.Fintech (neptune.ly)
// Each page includes: <script src="assets/nav.js" data-active="components"></script>
// Injects a consistent top nav (with active state) into <header class="dnav"> (or body top),
// and wires any [data-copy] button to copy its target text.
(function () {
  var LINKS = [
    ["index.html", "Home", "home"],
    ["get-started.html", "Get started", "get-started"],
    ["foundations.html", "Foundations", "foundations"],
    ["components.html", "Components", "components"],
    ["templates.html", "Templates", "templates"],
    ["icons.html", "Icons", "icons"],
    ["develop.html", "Develop", "develop"],
    ["configurator/", "Theme builder", "configurator"],
  ];
  var me = document.currentScript;
  var active = (me && me.getAttribute("data-active")) || "";
  var repo = "https://github.com/neptune-ly/neptune_odyssey";

  function build() {
    var nav = document.querySelector("header.dnav");
    if (!nav) {
      nav = document.createElement("header");
      nav.className = "dnav";
      document.body.insertBefore(nav, document.body.firstChild);
    }
    var links = LINKS.map(function (l) {
      var cls = l[2] === active ? ' class="active"' : "";
      return '<a href="' + l[0] + '"' + cls + '>' + l[1] + "</a>";
    }).join("");
    nav.innerHTML =
      '<a class="dnav__logo" href="index.html" aria-label="Neptune Odyssey">Neptune<span class="dot"></span></a>' +
      '<button class="dnav__burger" aria-label="Menu" aria-expanded="false">☰</button>' +
      '<nav class="dnav__links" id="dnavLinks">' + links + "</nav>" +
      '<a class="dnav__gh" href="' + repo + '" target="_blank" rel="noopener">★ GitHub</a>';
    var burger = nav.querySelector(".dnav__burger");
    var linksEl = nav.querySelector("#dnavLinks");
    burger.addEventListener("click", function () {
      var open = linksEl.classList.toggle("open");
      burger.setAttribute("aria-expanded", String(open));
    });
  }

  // Delegated copy: any element with [data-copy="text"] or a .copy inside .code (copies the <pre>).
  function wireCopy() {
    document.addEventListener("click", function (e) {
      var b = e.target.closest("[data-copy], .code .copy");
      if (!b) return;
      var text = b.getAttribute("data-copy");
      if (!text) {
        var pre = b.closest(".code") && b.closest(".code").querySelector("pre");
        text = pre ? pre.textContent : "";
      }
      var done = function () {
        var prev = b.textContent;
        b.textContent = "Copied!";
        b.classList.add("copied");
        setTimeout(function () { b.textContent = prev === "Copied!" ? "Copy" : prev; b.classList.remove("copied"); }, 1400);
      };
      if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(done, done);
      else { var ta = document.createElement("textarea"); ta.value = text; document.body.appendChild(ta); ta.select(); try { document.execCommand("copy"); } catch (_) {} ta.remove(); done(); }
    });
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", function () { build(); wireCopy(); });
  else { build(); wireCopy(); }
})();
