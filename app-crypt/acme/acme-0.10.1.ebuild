# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=(python{2_7,3_4,3_5})

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="https://github.com/certbot/certbot.git"
	inherit git-r3
	S=${WORKDIR}/${P}/${PN}
else
	SRC_URI="https://github.com/certbot/certbot/archive/v${PV}.tar.gz -> certbot-${PV}.tar.gz"
	KEYWORDS="~amd64 ~arm ~x86"
	S=${WORKDIR}/certbot-${PV}/acme
fi

inherit distutils-r1

DESCRIPTION="An implementation of the ACME protocol"
HOMEPAGE="https://github.com/certbot/certbot https://letsencrypt.org/"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="test"

RDEPEND=">=dev-python/cryptography-0.8[${PYTHON_USEDEP}]
	dev-python/mock[${PYTHON_USEDEP}]
	>=dev-python/pyopenssl-0.13[${PYTHON_USEDEP}]
	dev-python/pyrfc3339[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	>=dev-python/requests-2.4.1[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	virtual/python-dnspython"
DEPEND="test? ( ${RDEPEND} dev-python/nose[${PYTHON_USEDEP}] )
	>=dev-python/setuptools-1.0[${PYTHON_USEDEP}]"

python_test() {
	nosetests -w ${PN} || die
}
