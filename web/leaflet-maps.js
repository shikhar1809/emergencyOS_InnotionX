/**
 * EmergencyOS – Leaflet helpers (single place for L normalization, basemap fallbacks, resize).
 * Loaded after ./vendor/leaflet.js — no duplicate CDN Leaflet scripts in index.html.
 */
(function () {
  "use strict";

  function getL() {
    if (typeof window === "undefined") return null;
    if (window.L && typeof window.L.map === "function") return window.L;
    var p = window.leaflet;
    if (!p && typeof globalThis !== "undefined") p = globalThis.leaflet;
    if (p && typeof p.map === "function") {
      window.L = p;
      return p;
    }
    return null;
  }

  var BASEMAPS = {
    cartoDark: {
      url: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
      opts: {
        maxZoom: 20,
        subdomains: "abcd",
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> ' +
          '&copy; <a href="https://carto.com/attributions">CARTO</a>',
      },
    },
    osm: {
      url: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      opts: {
        maxZoom: 19,
        subdomains: "abc",
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      },
    },
    wiki: {
      url: "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png",
      opts: {
        maxZoom: 19,
        attribution: '&copy; <a href="https://wikimediafoundation.org/wiki/Maps_Terms_of_Use">Wikimedia</a>',
      },
    },
    cartoLight: {
      url: "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
      opts: {
        maxZoom: 20,
        subdomains: "abcd",
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> ' +
          '&copy; <a href="https://carto.com/attributions">CARTO</a>',
      },
    },
  };

  /**
   * Attach first working raster basemap. If tiles fail (blocked CDN, etc.), swap to next candidate.
   */
  function attachBasemap(map, preferDark) {
    var L = getL();
    if (!L || !map) return;

    var order = preferDark
      ? [BASEMAPS.cartoDark, BASEMAPS.osm, BASEMAPS.wiki, BASEMAPS.cartoLight]
      : [BASEMAPS.osm, BASEMAPS.cartoLight, BASEMAPS.wiki, BASEMAPS.cartoDark];

    var index = 0;
    var current = null;

    function tryNext() {
      if (index >= order.length) return;
      var def = order[index];
      index += 1;
      if (current) {
        try {
          map.removeLayer(current);
        } catch (e) {}
        current = null;
      }
      current = L.tileLayer(def.url, def.opts);
      var advanced = false;
      current.on("tileerror", function onErr() {
        if (advanced) return;
        advanced = true;
        current.off("tileerror", onErr);
        try {
          map.removeLayer(current);
        } catch (e) {}
        current = null;
        tryNext();
      });
      current.addTo(map);
    }

    tryNext();
  }

  function bindResize(map, el) {
    if (!map || !el) return;
    function inv() {
      try {
        map.invalidateSize({ animate: false });
      } catch (e) {}
    }
    requestAnimationFrame(inv);
    [0, 50, 200, 600].forEach(function (ms) {
      setTimeout(inv, ms);
    });
    if (typeof ResizeObserver !== "undefined") {
      try {
        if (el._eosMapResizeObserver) {
          el._eosMapResizeObserver.disconnect();
        }
        var ro = new ResizeObserver(inv);
        ro.observe(el);
        el._eosMapResizeObserver = ro;
      } catch (e) {}
    }
  }

  window.EOSLeafletMaps = {
    getL: getL,
    attachBasemap: attachBasemap,
    bindResize: bindResize,
  };
})();
