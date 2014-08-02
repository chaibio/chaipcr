#!/bin/sh
#
# This script downloads, patches and prepares the kernel sources for BeagleBone
# (Black) kernels distributed by http://rcn-ee.net in order to enable you to
# compile kernel modules right on the BeagleBone: After installing the kernel
# sources with this script, you should be able to build kernel modules via
# their respective makefile.
#
# Note that this will only work for those kernels for which rcn-ee has a
# kernel-headers package as well – This should be the case for most older
# and some newer kernels, but there was a time where the kernel-headers package
# was missing from the distributions. The script will notify you if you want
# to run it for a kernel for which no kernel-headers package is available.
#
# By default, the script will prepare the sources for the currently running
# kernel. However, you can also specify a different kernel version as the
# first script argument.
#
# Oh, and also ensure that you have all the necessary dependencies installed,
# since the script doesn't check: gcc, make and all the usual suspects for
# building kernel-related things. 
#
# The script tries to determine your linux distribution automatically, but
# if that fails or you want to manually specify one, edit the DIST variable
# at the top of the script.
#
# I've only tested this on Ubuntu, but it should probably also work with
# Debian.
#

DIST=""

BASE_URL="http://rcn-ee.net/deb"
OFFICIAL_KERNEL_BASE_URL="https://www.kernel.org/pub/linux/kernel"

KVER=$(uname -r)
MAIN_KVER=$(echo ${KVER} | sed -nE 's/^(([0-9]+\.?)+).*/\1/gp')
TEMPDIR=$1

if [ -z "$1" ]
  then
    echo "No argument supplied. Using default temporary directory."
    TEMPDIR=$(mktemp -d)
fi

if [ ! -d TEMPDIR ]; then
	echo "temp directory does not exist. exiting"
	exit 0;
fi

DDIR="${TEMPDIR}"

clean_up () {
	rm -rf "${DDIR}"
}

notif () {
	echo "\033[1;34m${1}\033[0m${2}"
}

fail () {
	echo "\033[1;31m${1}\033[0m${2}"
	clean_up
	exit 0
}

checks () {
	if [ -d "/usr/src/linux-${KVER}" ]; then
		notif "directory /usr/src/linux-${KVER} already exists. nothing to do!"
		exit 0
	fi
	
	if ! [ $(id -u) = 0 ]; then
	   fail "You need to be root to run this (or use sudo)."
	fi
}

determine_dist () {
	#lsb_release: is not installed by default when using debian's debootstrap script.
	if [ -z "${DIST}" ]; then
		has_lsb_release=$(which lsb_release 2>/dev/null)
		if [ "${has_lsb_release}" ] ; then
			release=$(lsb_release -cs)
			dpkg_arch=$(dpkg --print-architecture)
			DIST="${release}-${dpkg_arch}"
		fi
	fi
	
	if [ -z "${DIST}" ]; then
		fail "failed to determine linux distro: either install lsb-release (apt-get install lsb-release) or specify distribution manually at the top of this script, as \$DIST."
	fi
	
	RURL="${BASE_URL}/${DIST}/v${KVER}"
	
	notif "using linux distribution: " "${DIST}"
}

get_rcn_kernel_header_package () {
	notif "getting file listing from ${RURL}/..."
	wget --directory-prefix="${DDIR}" "${RURL}/"

	KPATCH=$(cat ${DDIR}/index.html  | grep "patch" | sed -nE 's/ *<a href=\"([^\"]+)\".*/\1/p')
	HDR_DEB=$(cat ${DDIR}/index.html  | grep "linux-headers" | sed -nE 's/ *<a href=\"([^\"]+)\".*/\1/p')

	if [ -n "${HDR_DEB}" ]; then
		notif "getting kernel headers from ${RURL}/${HDR_DEB}..."
		wget --directory-prefix="${DDIR}" "${RURL}/${HDR_DEB}"
	else
		fail "no kernel header package found for ${KVER}, try another kernel."
	fi

	if [ -n "${KPATCH}" ]; then
		notif "getting kernel patch from ${RURL}/${KPATCH}..."
		wget --directory-prefix="${DDIR}" "${RURL}/${KPATCH}"
	else
		fail "no kernel patch found for ${KVER}, try another kernel."
	fi
}

unpack_rcn_kernel_header_package () {
	notif "unpacking ${HDR_DEB}"
	notif
	
	dpkg -x "${DDIR}/${HDR_DEB}" "${DDIR}/kheaders"

	KCONFIG="${DDIR}/kheaders/usr/src/linux-headers-${KVER}/.config"
	SYMVERS="${DDIR}/kheaders/usr/src/linux-headers-${KVER}/Module.symvers"

	if [ ! -f "${KCONFIG}" ]; then
		fail "kernel headers package doesn't include .config, try another kernel."
	fi

	if [ ! -f "${SYMVERS}" ]; then
		fail "kernel headers package doesn't include Module.symvers, try another kernel."
	fi
}

get_official_kernel_source () {	
	if [ -n "$(echo ${MAIN_KVER} | sed -nE 's/(3\.)+.*/\1/p')" ]; then
		MAIN_KERNEL_URL="${OFFICIAL_KERNEL_BASE_URL}/v3.x/linux-${MAIN_KVER}.tar.bz2"
	else
		MAIN_KERNEL_URL="${OFFICIAL_KERNEL_BASE_URL}/v$(echo ${MAIN_KVER} | sed -nE 's/([0-9]+\.[0-9]+).*/\1/p')/linux-${MAIN_KVER}.tar.bz2"
	fi

	notif "getting official kernel source from ${MAIN_KERNEL_URL}..."

	wget --directory-prefix="${DDIR}" "${MAIN_KERNEL_URL}"

	notif "unpacking official kernel source..."
	sleep 1

	tar xvfj "${DDIR}/linux-${MAIN_KVER}.tar.bz2" --directory "${DDIR}"
}

patch_kernel_source () {
	ZCAT="zcat"
	
	has_gzcat=$(which gzcat 2>/dev/null)
	if [ "${has_gzcat}" ] ; then
			ZCAT="${has_gzcat}"
	fi

	notif "applying patch ${KPATCH} to linux-${MAIN_KVER}..."
	sleep 1

	$ZCAT "${DDIR}/${KPATCH}" | patch -d "${DDIR}/linux-${MAIN_KVER}" -p1
}

install_kernel_source () {
	notif "moving kernel source to /usr/src/linux-${KVER}..."

	mkdir -p /usr/src/
	rm -rf "/usr/src/linux-${KVER}"

	mv "${DDIR}/linux-${MAIN_KVER}"	"/usr/src/linux-${KVER}"
	mv "${SYMVERS}" "/usr/src/linux-${KVER}/Module.symvers"
	mv "${KCONFIG}" "/usr/src/linux-${KVER}/.config"

	mkdir -p "/lib/modules/${KVER}"
	rm -f "/lib/modules/${KVER}/build"
	ln -s "/usr/src/linux-${KVER}" "/lib/modules/${KVER}/build"
}

prepare_kernel_source () {
	notif "preparing kernel source at /usr/src/linux-${KVER}..."
	
	CURPWD=$PWD

	cd "/usr/src/linux-${KVER}"

	make oldconfig
	make prepare
	make scripts

	cd "${CURPWD}"
}

if [ ! -z ${1} ]; then
	KVER="${1}"
fi

notif "installing kernel sources for ${KVER}..."
notif

checks
determine_dist
get_rcn_kernel_header_package
unpack_rcn_kernel_header_package
get_official_kernel_source
patch_kernel_source
install_kernel_source
prepare_kernel_source
clean_up

notif "done: kernel sources for ${KVER} are now installed."
notif "you should be able to compile kernel modules."

exit 0

