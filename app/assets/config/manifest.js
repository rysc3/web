//= link application.css
//= link site.js
//= link_tree ../images
//= link_tree ../fonts
//
// Entry points are named outright, and the stylesheet/javascript directories
// are deliberately NOT walked.
//
// link_directory ../stylesheets .css compiles every file in that folder on
// its own, Sass partials included — and a partial that reads a variable from
// a sibling (_masthead.scss uses $tooth from _grain.scss) cannot compile
// alone. That raises mid-walk, and the walk dies with it, so application.css
// never gets linked and the layout fails with "was not declared to be
// precompiled". It only showed up on a cold build, because a warm
// tmp/cache/assets kept serving the last good link set.
//
// Partials are meaningless on their own; application.scss imports them in
// the right order. Only the entry point needs to be precompiled.
//
// Directives must stay in one unbroken comment block — Sprockets stops
// reading at the first blank line.
