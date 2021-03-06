# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit autotools eutils

MY_P="${P^g}"

DESCRIPTION="A Unix system friendly Scheme Interpreter"
HOMEPAGE="http://practical-scheme.net/gauche/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE="ipv6 libressl test"

RDEPEND="sys-libs/gdbm"
DEPEND="${RDEPEND}
	test? (
		!libressl? ( dev-libs/openssl:0 )
		libressl? ( dev-libs/libressl )
	)"
S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${PN}-rpath.patch
	"${FILESDIR}"/${PN}-gauche.m4.patch
	"${FILESDIR}"/${PN}-ext-ldflags.patch
	"${FILESDIR}"/${PN}-xz-info.patch
	"${FILESDIR}"/${PN}-rfc.tls.patch
	"${FILESDIR}"/${P}-libressl.patch
	"${FILESDIR}"/${P}-bsd.patch
	"${FILESDIR}"/${P}-unicode.patch
)

src_prepare() {
	default

	use ipv6 && sed -i "s/ -4//" ext/tls/ssltest-mod.scm

	eautoconf
}

src_configure() {
	econf \
		$(use_enable ipv6) \
		--with-libatomic-ops=no \
		--with-slib="${EPREFIX}"/usr/share/slib
}

src_test() {
	emake -j1 -s check
}

src_install() {
	emake DESTDIR="${D}" install-pkg install-doc
	dodoc AUTHORS ChangeLog HACKING README
}
