// https://old.reddit.com/r/privacytoolsIO/comments/d3of43/firefox_privacy_guide/
// https://github.com/pyllyukko/user.js/
// https://github.com/arkenfox/user.js/
//
// ADD THESE TO OS' HOSTS FILE:
// 127.0.0.1 accounts.firefox.com
// 127.0.0.1 firefox.settings.services.mozilla.com
// 127.0.0.1 content-signature-1.cdn.mozilla.net
// 127.0.0.1 content-signature-2.cdn.mozilla.net
// 127.0.0.1 content-signature-3.cdn.mozilla.net
// 127.0.0.1 search.services.mozilla.com
// 127.0.0.1 contile.services.mozilla.com
//
// PUT THESE INTO "network.proxy.no_proxies_on":
// .services.mozilla.com
// accounts.firefox.com

// General
user_pref("accessibility.force_disabled", 1);
user_pref("browser.download.autohideButton", false);
user_pref("browser.download.panel.shown", true); // Show download button
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false); // Performance detection
user_pref("browser.shell.checkDefaultBrowser", false); // Disable default browser check
user_pref("browser.uidensity", 1); // Use compact ui density (unsupported)
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org"); // Dark theme
user_pref("devtools.theme", "dark");
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("browser.in-content.dark-mode", true);
user_pref("layout.css.prefers-color-scheme.content-override", 2); // 0=dark;1=light;2=system
// user_pref("browser.theme.toolbar-theme", 2);  // ^
// user_pref("browser.theme.content-theme", 2); // ^
user_pref("extensions.allowPrivateBrowsingByDefault", true);
user_pref("findbar.highlightAll", true); // Highlight text search
user_pref("general.autoScroll", true); // Scroll by clicking middle mouse button
user_pref("general.smoothScroll", false); // Smooth scrolling off
user_pref("general.warnOnAboutConfig", false); // Disable modify warning
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // Turn on userChrome.css
user_pref("browser.tabs.selectOwnerOnClose", false);   // Non-retarded tab behavior
user_pref("browser.ctrlTab.recentlyUsedOrder", false); // ^^
user_pref("browser.tabs.warnOnClose", true); // Warn when closing a window with multiple tabs
user_pref("browser.privatebrowsing.searchUI", false);
user_pref("browser.tabs.closeWindowWithLastTab", false); // Don't kill a window upon closing its last tab
user_pref("network.IDN_show_punycode", true); // Decode non-ascii URLs
user_pref("browser.download.lastDir.savePerSite", true); // Last download location per domain
user_pref("browser.tabs.closeTabByDblclick", true); // Close tabs by double-clicking them
user_pref("toolkit.tabbox.switchByScrolling", true); // Switch tabs with scroll wheel
user_pref("media.default_volume", "0.1"); // Set default media volume to 10%
user_pref("reader.parse-on-load.enabled", false); // Disable reader view
user_pref("browser.link.open_newwindow.restriction", 0); // Open pop-ups in new tabs
user_pref("layers.acceleration.force-enabled", true); // Forced hwaccel
user_pref("gfx.webrender.all", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("layout.omtp.enabled", true); // Off-main-thread painting
user_pref("layout.display-list.retain", true);
user_pref("browser.aboutConfig.showWarning", false); // Disable about:config warning
user_pref("ui.prefersReducedMotion", 1); // Disable animations
user_pref("javascript.options.wasm", true); // Web assembly
user_pref("full-screen-api.enabled", true); // Fullscreen api
user_pref("full-screen-api.transition-duration.enter", 0 0); // Fade-in animation length
user_pref("full-screen-api.transition-duration.leave", 0 0); // Fade-out animation length
user_pref("full-screen-api.warning.timeout", 0); // Disable "playing in fullscreen" warning
user_pref("media.wmf.hevc.enabled", 1); // h.265 hwdec (needs a system codec installed)
user_pref("browser.tabs.hoverPreview.enabled", false);
user_pref("browser.tabs.hoverPreview.showThumbnails", false);

// address bar
user_pref("browser.search.suggest.enabled", false); // No search suggestions
user_pref("browser.search.update", false); // Disable search engine changes
user_pref("browser.urlbar.autoFill", true);
user_pref("browser.urlbar.autocomplete.enabled", false);
user_pref("browser.urlbar.maxRichResults", 10);
user_pref("browser.urlbar.speculativeConnect.enabled", false); // Disable autocomplete URLs
user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.history", true);
user_pref("browser.urlbar.suggest.openpage", true);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.oneOffSearches", false);
user_pref("keyword.enabled", false); // Disable URLbar search by default
user_pref("browser.fixup.alternate.enabled", false);
user_pref("apz.keyboard.enabled", false);
user_pref("browser.urlbar.openViewOnFocus", false);      // Disable enlargement
user_pref("browser.urlbar.disableExtendForTests", true); // ^^ (also disables dropdown)
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.suggest.weather", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.addons", false);
user_pref("browser.urlbar.resultMenu", false); // Remove menu button appearing on each url suggestion
user_pref("browser.urlbar.resultMenu.keyboardAccessible", false); // Don't focus ^ area with the `tab` button
user_pref("browser.urlbar.groupLabels.enabled", false); // Remove "Firefox Suggest" label in url suggestions
user_pref("browser.urlbar.trimURLs", false);
user_pref("browser.urlbar.suggest.quickactions", false);

// Local Data Storage
user_pref("browser.bookmarks.max_backups", 1); // no. of bookmark backups
user_pref("browser.cache.disk.enable", false); // Disk cache
user_pref("browser.cache.disk_cache_ssl", false); // ^
user_pref("browser.cache.disk.smart_size.enabled", false); // ^
user_pref("browser.cache.disk.capacity", 553600); // Disk cache size in KiB
user_pref("browser.sessionstore.interval", 3600000); // Write browser state every hour
user_pref("browser.cache.memory.enable", true); // Memory cache
user_pref("browser.cache.memory.capacity", 16464843); // Memory cache size in KiB; ~15.7GiB
user_pref("browser.cache.offline.enable", false); // Offline cache
user_pref("browser.formfill.enable", false);
user_pref("browser.library.activity-stream.enabled", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.enabled", false); // Disable newtab page
user_pref("browser.privatebrowsing.autostart", false); // Always private mode
user_pref("browser.sessionstore.max_tabs_undo", 25); // no. of tabs in "undo close tab"
user_pref("browser.sessionstore.privacy_level", 0);
user_pref("browser.startup.homepage_override.mstone", "ignore"); // Ignore welcome page
user_pref("signon.autofillForms", false);
user_pref("signon.rememberSignons", false); // Disable passwords
user_pref("startup.homepage_override_url", "");
user_pref("startup.homepage_welcome_url", "");

// Network
user_pref("browser.send_pings", false); // Default
user_pref("browser.send_pings.require_same_host", true);
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false); // Disable captive portal
user_pref("network.connectivity-service.enabled", false);
user_pref("network.dns.disablePrefetch", true); // Disable DNS prefetching
user_pref("network.predictor.enabled", false); // Disable predictor
user_pref("network.prefetch-next", false); // Disable link prefetching
user_pref("network.trr.bootstrapAddress", "172.64.41.4");
user_pref("security.mixed_content.block_display_content", true);
user_pref("security.mixed_content.block_active_content", true);
user_pref("network.protocol-handler.external.mailto", false);
user_pref("network.dns.blockDotOnion", true); // Reject .onion before passing to dns
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.trr.mode", 3); // DNS over HTTPS; 2=increased, 3=full, 5=off
//user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
//user_pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");
// user_pref("network.trr.uri", "https://dns.controld.com/comss");
// user_pref("network.trr.custom_uri", "https://dns.controld.com/comss");
// user_pref("network.trr.uri", "https://freedns.controld.com/p0");
// user_pref("network.trr.custom_uri", "https://freedns.controld.com/p0");
// user_pref("network.trr.uri", "https://dns.comss.one/dns-query");
// user_pref("network.trr.custom_uri", "https://dns.comss.one/dns-query");
// user_pref("network.trr.uri", "https://dns.malw.link/dns-query");
// user_pref("network.trr.custom_uri", "https://dns.malw.link/dns-query");
// user_pref("network.trr.uri", "https://5u35p8m9i7.cloudflare-gateway.com/dns-query");
// user_pref("network.trr.custom_uri", "https://5u35p8m9i7.cloudflare-gateway.com/dns-query");
// user_pref("network.trr.uri", "https://dns.geohide.ru:8444/dns-query");
// user_pref("network.trr.custom_uri", "https://dns.geohide.ru:8444/dns-query");
user_pref("network.trr.uri", "https://127.0.0.1:3000/dns-query");
user_pref("network.trr.custom_uri", "https://127.0.0.1:3000/dns-query");
user_pref("network.dns.use_https_rr_as_altsvc", true);
user_pref("network.proxy.type", 0); // Proxy; 0=disabled; 1=manual (options below)
user_pref("network.proxy.socks", "127.0.0.1"); // Proxy address
user_pref("network.proxy.socks_port", 2080); // 9050=tor; 9051=torbrowser; 1080=ss; 2080=v2ray
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.proxy.no_proxies_on", "http://192.168.1.1/,.services.mozilla.com,accounts.firefox.com");
user_pref("dom.security.https_only_mode", true); // Upgrade to https and warn if only http is available
user_pref("dom.security.https_only_mode_ever_enabled", true); // ^

// Fingerprinting
user_pref("beacon.enabled", false); // Disable beacon
user_pref("browser.search.geoip.url", "");
user_pref("dom.battery.enabled", false); // Disable battery status
user_pref("dom.event.clipboardevents.enabled", false); // Prevent websites from manipulating clipboard contents
user_pref("dom.allow_cut_copy", false); // ^ Same as above, using deprecated document.execCommand()
user_pref("dom.push.enabled", false); // Disable push notifications
user_pref("dom.webnotifications.enabled", false); // Disable desktop notifications
// https://techblog.willshouse.com/2012/01/03/most-common-user-agents/
// user_pref("general.useragent.override", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:52.0) Gecko/20100101 Firefox/52.0"); // override UA
user_pref("geo.enabled", false); // Disable geolocation
user_pref("geo.wifi.uri", "");
user_pref("geo.provider.network.url", "");
user_pref("geo.provider-country.network.url", "");
user_pref("media.eme.enabled", false); // Disable EME for DRM content
user_pref("media.navigator.enabled", false); // Mic and camera
user_pref("media.peerconnection.enabled", false); // WebRTC
user_pref("privacy.donottrackheader.enabled", true); // Send DNT header
user_pref("privacy.resistFingerprinting", false); // RFP (breaks a lot of websites)
user_pref("privacy.trackingprotection.enabled", false); // Redundant with extensions
user_pref("privacy.trackingprotection.cryptomining.enabled", false); // ^
user_pref("privacy.trackingprotection.fingerprinting.enabled", false); // ^
user_pref("privacy.trackingprotection.pbmode.enabled", false); // ^
user_pref("webgl.disabled", false); // WebGL
user_pref("media.webspeech.synth.enabled", false); // Disable speech synthesis
user_pref("privacy.spoof_english", 0);

// Updates
user_pref("app.update.auto", false); // Disable autoinstall of FF updates
user_pref("extensions.systemAddon.update.enabled", false); // Disable system add-ons updates
user_pref("extensions.systemAddon.update.url", "");
user_pref("extensions.update.autoUpdateDefault", false); // Disable autoinstall of extension updates
user_pref("extensions.update.enabled", false); // Disable autochecking of extension updates

// Telemetry
user_pref("extensions.shield-recipe-client.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("app.normandy.enabled", false); // Disable shield telemetry
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.ping-centre.telemetry", false); // Disable ping telemetry
user_pref("browser.tabs.crashReporting.sendReport", false); // Disable crash reports
user_pref("browser.crashReports.unsubmittedCheck.enabled", false);
user_pref("datareporting.healthreport.infoURL", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false); // Disable all technical data
user_pref("datareporting.policy.firstRunURL", "");
user_pref("permissions.manager.defaultsUrl", "");
user_pref("security.ssl.errorReporting.enabled", false); // Disable SSL error reporting
user_pref("security.ssl.errorReporting.url", "");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.cachedClientID", "");
user_pref("toolkit.telemetry.enabled", false); // Locked preference
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.hybridContent.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.unified", false); // Disable FF telemetry
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("browser.selfsupport.url", "");
user_pref("loop.logDomains", false);
user_pref("experiments.enabled", false);
user_pref("experiments.manifest.uri", 0);
user_pref("experiments.supported", false);
user_pref("experiments.activeExperiment", false);
user_pref("network.allow-experiments", false);
user_pref("toolkit.telemetry.cachedClientID", "");

// "Features"
user_pref("browser.uitour.enabled", false); // Disable UITour
user_pref("browser.uitour.url", "");
user_pref("extensions.formautofill.available", "off"); // Disable autofill
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("extensions.getAddons.discovery.api_url", "");
user_pref("extensions.htmlaboutaddons.discover.enabled", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false); // No add-on recommendations
user_pref("extensions.recommendations.themeRecommendationUrl", ""); // No theme recommendations
user_pref("extensions.pocket.api", "");
user_pref("extensions.pocket.enabled", false); // Disable pocket
user_pref("extensions.pocket.oAuthConsumerKey", "");
user_pref("extensions.pocket.site", "");
user_pref("extensions.screenshots.disabled", true); // Disable screenshots
user_pref("extensions.screenshots.upload-disabled", true);
user_pref("extensions.webcompat-reporter.enabled", false); // Disable "report this site"
user_pref("extensions.fxmonitor.enabled", false); // Disable fxmonitor
user_pref("extensions.webservice.discoverURL", "");
user_pref("identity.fxaccounts.auth.uri", "");
user_pref("identity.fxaccounts.enabled", false); // Disable FF accounts
user_pref("identity.fxaccounts.pairing.enabled", false);
user_pref("identity.fxaccounts.remote.pairing.uri", "");
user_pref("media.gmp-gmpopenh264.autoupdate", false);
user_pref("media.gmp-gmpopenh264.enabled", false); // OpenH264 for WebRTC
user_pref("media.gmp-gmpopenh264.visible", false); // ^
user_pref("media.gmp-manager.url", "");            // ^
user_pref("media.gmp-provider.enabled", false);    // ^
user_pref("media.gmp-widevinecdm.enabled", false); // Disable Widevine CDM
user_pref("media.gmp-widevinecdm.visible", false); // ^
user_pref("webchannel.allowObject.urlWhitelist", "");
user_pref("devtools.debugger.remote-enabled", false); // Disable remote debugging
user_pref("devtools.chrome.enabled", false);          // ^
user_pref("devtools.debugger.force-local", true);     // ^
user_pref("pdfjs.disabled", true); // Disable pdfjs
user_pref("devtools.webide.enabled", false);                 // Disable webIDE
user_pref("devtools.webide.autoinstallADBHelper", false);    // ^
user_pref("devtools.webide.autoinstallFxdtAdapters", false); // ^
user_pref("browser.translations.enable", false);             // Disable web page translation
user_pref("browser.translations.automaticallyPopup", false); // ^
user_pref("browser.translations.panelShown", false);         // ^

// Google Safe Browsing
user_pref("browser.safebrowsing.allowOverride", false);
user_pref("browser.safebrowsing.blockedURIs.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);
user_pref("browser.safebrowsing.downloads.remote.block_dangerous", false);
user_pref("browser.safebrowsing.downloads.remote.block_dangerous_host", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.url", "");
user_pref("browser.safebrowsing.provider.google4.advisoryURL", "");
user_pref("browser.safebrowsing.provider.google4.dataSharingURL", "");
user_pref("browser.safebrowsing.provider.google4.gethashURL", "");
user_pref("browser.safebrowsing.provider.google4.reportMalwareMistakeURL", "");
user_pref("browser.safebrowsing.provider.google4.reportPhishMistakeURL", "");
user_pref("browser.safebrowsing.provider.google4.reportURL", "");
user_pref("browser.safebrowsing.provider.google4.updateURL", "");
user_pref("browser.safebrowsing.provider.google.advisoryURL", "");
user_pref("browser.safebrowsing.provider.google.gethashURL", "");
user_pref("browser.safebrowsing.provider.google.reportMalwareMistakeURL", "");
user_pref("browser.safebrowsing.provider.google.reportPhishMistakeURL", "");
user_pref("browser.safebrowsing.provider.google.reportURL", "");
user_pref("browser.safebrowsing.provider.google.updateURL", "");
user_pref("browser.safebrowsing.provider.mozilla.gethashURL", "");
user_pref("browser.safebrowsing.provider.mozilla.updateURL", "");
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.reportPhishURL", "");

// Mozilla Blocklist
user_pref("extensions.blocklist.enabled", false); // Disable blocklist
user_pref("extensions.blocklist.url", "");
user_pref("services.blocklist.addons.collection", ""); // More blocklist settings
user_pref("services.blocklist.bucket", "");
user_pref("services.blocklist.gfx.collection", "");
user_pref("services.blocklist.pinning.bucket", "");
user_pref("services.blocklist.pinning.collection", "");
user_pref("services.blocklist.pinning.enabled", false);
user_pref("services.blocklist.plugins.collection", "");
user_pref("services.settings.default_bucket", ""); // Disable contacting content server (BREAKS URL BAR IN 78)
user_pref("services.settings.security.onecrl.bucket", "");
user_pref("services.settings.security.onecrl.collection", "");
user_pref("services.settings.server", ""); // Disable contacting settings server

// Scrollbars
user_pref("widget.non-native-theme.scrollbar.style", 5);
user_pref("ui.useOverlayScrollbars", 1);

// arkenfox ESR 102 -> 115
user_pref("browser.tabs.firefox-view", false);
user_pref("network.http.referer.XOriginPolicy", 0); // 0=Default; 2=Send referer only on same-origin
user_pref("network.http.referer.XOriginTrimmingPolicy", 0); // 0=full URI (default); 1=scheme+host+port+path; 2=scheme+host+port
user_pref("network.cookie.cookieBehavior", 0); // 5=total cookie protection; 0=allow all
// user_pref("privacy.firstparty.isolate", false); // Restrict data to domain level; true=UNMAINTAINED
user_pref("privacy.partition.serviceWorkers", true); // State partitioning of service workers
// user_pref("dom.serviceWorkers.enabled", false); // Isolated with ^
user_pref("privacy.partition.always_partition_third_party_non_cookie_storage", true);
user_pref("privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage", false);
user_pref("privacy.partition.network_state.ocsp_cache", true);
user_pref("services.sync.prefs.sync.signon.management.page.breach-alerts.enabled", false);
user_pref("signon.management.page.breach-alerts.enabled", false);
user_pref("signon.management.page.breachAlertUrl", "");
user_pref("network.http.http3.enable", true); // HTTP/3 support
user_pref("network.http.http3.enable_kyber", true); // Kyber KEM
user_pref("security.tls.enable_kyber", true); // ^^
user_pref("network.dns.echconfig.enabled", true); // Encrypted Client Hello
user_pref("network.security.esni.enabled", true); // ^^
user_pref("network.dns.http3_echconfig.enabled", true); // ^^
user_pref("network.http.http3.version_negotiation.enabled", true); // ^^
user_pref("browser.vpn_promo.enabled", false);
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("browser.contentblocking.report.vpn.url", "");
user_pref("browser.contentblocking.report.vpn-promo.url", "");

// arkenfox ESR 115 -> 128
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines", "YouTube");
user_pref("browser.contentanalysis.enabled", false);
user_pref("browser.contentanalysis.default_allow", false);
user_pref("browser.contentanalysis.default_result", 0);
user_pref("geo.provider.use_gpsd", false);
user_pref("geo.provider.use_geoclue", false);
user_pref("browser.shopping.experience2023.enabled", false);
user_pref("network.gio.supported-protocols", "");
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.recentsearches.featureGate", false);
user_pref("browser.urlbar.trending.requireSearchMode", false);
user_pref("browser.urlbar.addons.featureGate", false);
user_pref("browser.urlbar.mdn.featureGate", false);
user_pref("browser.urlbar.pocket.featureGate", false);
user_pref("browser.urlbar.weather.featureGate", false);
user_pref("browser.urlbar.yelp.featureGate", false);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);

// arkenfox ESR 128 -> 140
user_pref("browser.newtabpage.activity-stream.discoverystream.reportAds.enabled", false);
user_pref("browser.newtabpage.activity-stream.telemetry.privatePing.enabled", false);
user_pref("extensions.dataCollectionPermissions.enabled", false);
user_pref("privacy.antitracking.isolateContentScriptResources", false);
user_pref("network.cookie.cookieBehavior.optInPartitioning", false);
user_pref("privacy.baselineFingerprintingProtection", false);
user_pref("privacy.baselineFingerprintingProtection.granularOverrides", "");
user_pref("privacy.baselineFingerprintingProtection.overrides", "");
user_pref("toolkit.aboutLogging.uploadProfileToCloud", false);
user_pref("browser.urlbar.fakespot.featureGate", false);
user_pref("widget.non-native-theme.use-theme-accent", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.urlbar.amp.featureGate", false);
user_pref("browser.urlbar.wikipedia.featureGate", false);
user_pref("security.csp.reporting.enabled", false);
user_pref("privacy.query_stripping.strip_on_share.enabled", false)

