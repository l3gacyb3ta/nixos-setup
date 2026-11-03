# Go Mono rasterised to a PSF so the linux VT (and so tuigreet) can use it.
# pixelSize is glyph height; the M1 Pro panel is ~254dpi so it wants to be big.
{ runCommand, go-font, otf2bdf, bdf2psf, gzip, pixelSize ? 32 }:

runCommand "go-mono-psf-${toString pixelSize}" {
	nativeBuildInputs = [ otf2bdf bdf2psf gzip ];
} ''
	# otf2bdf exits 1 on success when some glyphs are missing, hence the ||
	otf2bdf -r 72 -p ${toString pixelSize} -c C \
		${go-font}/share/fonts/truetype/Go-Mono.ttf -o go.bdf || true
	test -s go.bdf

	# every glyph is one cell wide, but otf2bdf writes a fractional average
	# width that bdf2psf rejects, so pin it to the real cell width
	w=$(awk '/^FONTBOUNDINGBOX/ { print $2; exit }' go.bdf)
	sed -i "s/^AVERAGE_WIDTH .*/AVERAGE_WIDTH $((w * 10))/" go.bdf

	share=${bdf2psf}/share/bdf2psf
	mkdir -p $out/share/consolefonts
	bdf2psf --fb go.bdf $share/standard.equivalents \
		$share/ascii.set+$share/linux.set+$share/useful.set 512 \
		$out/share/consolefonts/GoMono-${toString pixelSize}.psf
	gzip -9 $out/share/consolefonts/*.psf
''
