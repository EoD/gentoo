# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools qmake-utils

DESCRIPTION="GPS waypoints, tracks and routes converter"
HOMEPAGE="http://www.gpsbabel.org/"
SRC_URI="
	https://dev.gentoo.org/~asturm/${P}.tar.gz
	doc? ( http://www.gpsbabel.org/style3.css -> gpsbabel.org-style3.css )"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"
IUSE="doc"

RDEPEND="
	dev-libs/expat
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwebchannel:5
	dev-qt/qtwebengine:5[widgets]
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	sci-libs/shapelib:=
	sys-libs/zlib[minizip]
	virtual/libusb:0
"
DEPEND="${RDEPEND}
	dev-qt/linguist-tools:5
	doc? (
		dev-lang/perl
		dev-libs/libxslt
		app-text/docbook-xml-dtd:4.1.2
	)
"

DOCS=( AUTHORS README.{contrib,igc,mapconverter,md,xmapwpt} )

PATCHES=(
	"${FILESDIR}/${PN}-1.4.3-fix_binary_name.patch"
	"${FILESDIR}/${P}-disable_statistic_uploading.patch"
	"${FILESDIR}/${P}-disable_update_check.patch"
	"${FILESDIR}/${P}-disable_version_check.patch"
	"${FILESDIR}/${P}-use_system_shapelib.patch"
	"${FILESDIR}/${P}-use_system_zlib.patch"
	"${FILESDIR}/${P}-xmldoc.patch"
)

RESTRICT="test" # bug 421699

src_prepare() {
	default

	# remove bundled libs and cleanup
	rm -r shapelib zlib || die
	sed -i -e "s: zlib\/[a-z]*\.h::g" Makefile.in || die

	mv configure.in configure.ac || die
	sed -i -e "/^configure:/s/configure.in/configure.ac/" Makefile.in || die

	use doc && cp "${DISTDIR}/gpsbabel.org-style3.css" "${S}"

	eautoreconf
}

src_configure() {
	econf \
		$(use_with doc doc "${S}"/doc/manual) \
		LRELEASE=$(qt5_get_bindir)/lrelease \
		LUPDATE=$(qt5_get_bindir)/lupdate \
		QMAKE=$(qt5_get_bindir)/qmake \
		--with-zlib=system

	pushd "${S}/gui" > /dev/null || die
	lrelease *.ts || die
	eqmake5
	popd > /dev/null
}

src_compile() {
	default

	pushd "${S}/gui" > /dev/null || die
	emake
	popd > /dev/null

	if use doc; then
		perl xmldoc/makedoc || die
		emake gpsbabel.html
	fi
}

src_install() {
	use doc && HTML_DOCS=( "${S}"/${PN}.html "${S}"/${PN}.org-style3.css )

	default

	dobin gui/objects/gpsbabelfe
	insinto /usr/share/${PN}/translations/
	doins gui/gpsbabel*_*.qm
	newicon gui/images/appicon.png ${PN}.png
	make_desktop_entry gpsbabelfe ${PN} ${PN} "Science;Geoscience"
}
