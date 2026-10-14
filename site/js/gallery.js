// Full-screen photo viewer for the gallery: tap a photo, then swipe, use the
// arrow buttons or the keyboard to move through the rest. Without JavaScript
// each gallery link still opens its photo (DECISION_001).
(function () {
  "use strict";

  var links = Array.prototype.slice.call(document.querySelectorAll(".gallery a"));
  if (!links.length || typeof HTMLDialogElement !== "function") {
    return;
  }

  var viewer = document.createElement("dialog");
  viewer.className = "viewer";
  viewer.setAttribute("aria-label", "Photo viewer");
  viewer.innerHTML =
    '<div class="viewer-track"></div>' +
    '<p class="viewer-count" aria-live="polite"></p>' +
    '<button class="viewer-close" type="button" aria-label="Close photos">&times;</button>' +
    '<button class="viewer-prev" type="button" aria-label="Previous photo">&#8249;</button>' +
    '<button class="viewer-next" type="button" aria-label="Next photo">&#8250;</button>';
  document.body.appendChild(viewer);

  var track = viewer.querySelector(".viewer-track");
  var count = viewer.querySelector(".viewer-count");
  var prev = viewer.querySelector(".viewer-prev");
  var next = viewer.querySelector(".viewer-next");

  // One slide per gallery link; the full-size photo loads only when it's
  // the current slide or next to it.
  var photos = links.map(function (link) {
    var figure = document.createElement("figure");
    var img = document.createElement("img");
    var caption = document.createElement("figcaption");
    img.alt = link.querySelector("img").alt;
    img.decoding = "async";
    img.setAttribute("data-src", link.getAttribute("href"));
    caption.textContent = img.alt;
    figure.appendChild(img);
    figure.appendChild(caption);
    track.appendChild(figure);
    return img;
  });

  var current = 0;
  // The photo a button or key is scrolling to. While set, the scroll events
  // of that animation don't change the current photo.
  var target = null;

  function load(i) {
    var img = photos[i];
    if (img && !img.getAttribute("src")) {
      img.src = img.getAttribute("data-src");
    }
  }

  function show(i) {
    current = i;
    load(i - 1);
    load(i);
    load(i + 1);
    count.textContent = i + 1 + " / " + photos.length;
    prev.disabled = i === 0;
    next.disabled = i === photos.length - 1;
  }

  function go(i, smooth) {
    i = Math.max(0, Math.min(photos.length - 1, i));
    var left = i * track.clientWidth;
    // Already there: no scroll event will come to clear the target.
    target = Math.abs(track.scrollLeft - left) < 2 ? null : i;
    track.scrollTo({ left: left, behavior: smooth ? "smooth" : "auto" });
    show(i);
  }

  links.forEach(function (link, i) {
    link.addEventListener("click", function (event) {
      event.preventDefault();
      document.documentElement.classList.add("viewer-open");
      viewer.showModal();
      go(i, false);
    });
  });

  function showPhotoInView() {
    var i = Math.round(track.scrollLeft / track.clientWidth);
    if (i !== current) {
      show(i);
    }
  }

  // Swiping scrolls the track; the counter follows the photo that snaps in.
  // Smooth scrolling can stop a fraction of a pixel short, hence the 2px.
  track.addEventListener("scroll", function () {
    if (target !== null) {
      if (Math.abs(track.scrollLeft - target * track.clientWidth) < 2) {
        target = null;
      }
      return;
    }
    showPhotoInView();
  });

  // Where supported, the end of any scroll settles the current photo.
  track.addEventListener("scrollend", function () {
    target = null;
    showPhotoInView();
  });

  // A swipe or wheel during a button's animation takes over from it.
  ["pointerdown", "touchstart", "wheel"].forEach(function (type) {
    track.addEventListener(type, function () {
      target = null;
    }, { passive: true });
  });

  prev.addEventListener("click", function () {
    go(current - 1, true);
  });

  next.addEventListener("click", function () {
    go(current + 1, true);
  });

  viewer.querySelector(".viewer-close").addEventListener("click", function () {
    viewer.close();
  });

  viewer.addEventListener("keydown", function (event) {
    if (event.key === "ArrowLeft") {
      go(current - 1, true);
    } else if (event.key === "ArrowRight") {
      go(current + 1, true);
    }
  });

  viewer.addEventListener("close", function () {
    document.documentElement.classList.remove("viewer-open");
  });

  window.addEventListener("resize", function () {
    if (viewer.open) {
      go(current, false);
    }
  });
})();
