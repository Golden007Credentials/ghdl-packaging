# This does not work yet.
# There is a wild calling orgy between grt and e~xx.o going on
# grt calls into e~xx.o for __ghdl_ELABORATE and various std__*
# but grt.ver unglobals all except VPI symbols

%global gccver 4.3.4
%global ghdlver 0.28
%global ghdlsvnver 133

Summary: A VHDL simulator, using the GCC technology
Name: ghdl
Version: %{ghdlver}
Release: 0.%{ghdlsvnver}svn.0%{?dist}
License: GPLv2+
Group: Development/Languages
URL: http://ghdl.free.fr/
# HOWTO create source files from ghdl SVN at https://gna.org/projects/ghdl/
# check out the SVN repo
# cd translate/gcc/
# ./dist.sh sources
Source0: ftp://gcc.gnu.org/pub/gcc/releases/gcc-%{gccver}/gcc-core-%{gccver}.tar.bz2
Source100: http://ghdl.free.fr/ghdl-%{ghdlver}.tar.bz2
Patch100: ghdl-svn%{ghdlsvnver}.patch
Patch103: ghdl-noruntime.patch
Patch104: ghdl-svn110-libgnat44.patch
Patch105: ghdl-grtadac.patch
# Both following patches have been sent to upstream mailing list:
# From: Thomas Sailer <t.sailer@alumni.ethz.ch>
# To: ghdl-discuss@gna.org
# Date: Thu, 02 Apr 2009 15:36:00 +0200
# https://gna.org/bugs/index.php?13390
Patch106: ghdl-ppc64abort.patch
# https://gna.org/bugs/index.php?13389
Patch107: ieee-mathreal.patch
Patch110: grt-so.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires(post): /sbin/install-info
Requires(preun): /sbin/install-info
Requires: gcc
# (Build)Requires from fc gcc41 package
%global multilib_64_archs sparc64 ppc64 s390x x86_64
%ifarch s390x
%global multilib_32_arch s390
%endif
%ifarch sparc64
%global multilib_32_arch sparc
%endif
%ifarch ppc64
%global multilib_32_arch ppc
%endif
%ifarch x86_64
%global multilib_32_arch i386
%endif
# Need binutils with -pie support >= 2.14.90.0.4-4
# Need binutils which can omit dot symbols and overlap .opd on ppc64 >= 2.15.91.0.2-4
# Need binutils which handle -msecure-plt on ppc >= 2.16.91.0.2-2
# Need binutils which support .weakref >= 2.16.91.0.3-1
BuildRequires: binutils >= 2.16.91.0.3-1
BuildRequires: zlib-devel, gettext, bison, flex, texinfo, gawk
# Make sure pthread.h doesn't contain __thread tokens
# Make sure glibc supports stack protector
BuildRequires: glibc-devel >= 2.3.90-2
%ifarch ppc ppc64 s390 s390x sparc sparcv9 alpha
# Make sure glibc supports TFmode long double
BuildRequires: glibc >= 2.3.90-35
%endif
# Ada requires Ada to build
BuildRequires: gcc-gnat >= 4.3, libgnat >= 4.3
# GCC build requirements
BuildRequires: gmp-devel >= 4.1, mpfr-devel >= 2.3.0
# Need .eh_frame ld optimizations
# Need proper visibility support
# Need -pie support
# Need --as-needed/--no-as-needed support
# On ppc64, need omit dot symbols support and --non-overlapping-opd
# Need binutils that owns /usr/bin/c++filt
# Need binutils that support .weakref
Requires: binutils >= 2.16.91.0.3-1
# Make sure gdb will understand DW_FORM_strp
Conflicts: gdb < 5.1-2
Requires: glibc-devel >= 2.2.90-12
%ifarch ppc ppc64 s390 s390x sparc sparcv9 alpha
# Make sure glibc supports TFmode long double
Requires: glibc >= 2.3.90-35
%endif

Requires: ghdl-devel = %{version}-%{release}

# Make sure we don't use clashing namespaces
%global _vendor fedora_ghdl

%global _gnu %{nil}
%ifarch sparc
%global gcc_target_platform sparc64-%{_vendor}-%{_target_os}
%endif
%ifarch ppc
%global gcc_target_platform ppc64-%{_vendor}-%{_target_os}
%endif
%ifnarch sparc ppc
%global gcc_target_platform %{_target_platform}
%endif

# do not strip libgrt.a -- makes debugging tedious otherwise
%global __os_install_post %(echo '%{__os_install_post}' | sed -e 's#/usr/lib/rpm/redhat/brp-strip-static-archive .*##g')

%global all_x86 %{ix86} x86_64

%description
GHDL is a VHDL simulator, using the GCC technology. VHDL is a language
standardized by the IEEE, intended for developing electronic systems. GHDL
implements the VHDL language according to the IEEE 1076-1987 or the IEEE
1076-1993 standard. It compiles VHDL files and creates a binary that simulates
(or executes) your design. GHDL does not do synthesis: it cannot translate your
design into a netlist.

Since GHDL is a compiler (i.e., it generates object files), you can call
functions or procedures written in a foreign language, such as C, C++, or
Ada95.

%package devel
Summary: GHDL libraries
Group: Development/Libraries
# rhbz #316311
Requires: zlib-devel, libgnat >= 4.3
Obsoletes: ghdl-grt

%description devel
This package contains the runtime libraries needed to link ghdl-compiled
object files into simulator executables. This package also contains sources
and precompiled binaries for standard VHDL packages.

%ifarch %{all_x86}
%package libs
Summary: GHDL runtime libraries
Group: Development/Libraries

%description libs
This package contains the runtime libraries needed to run ghdl-compiled
simulator executables. grt contains the simulator kernel that tracks
signal updates and schedules processes.
%endif

%ifarch x86_64
%package libs32
Summary: GHDL 32bit runtime libraries
Group: Development/Libraries

%description libs32
This package contains the runtime libraries needed to run ghdl-compiled
simulator executables. grt contains the simulator kernel that tracks
signal updates and schedules processes. This package is needed to compile
32bit executables with ghdl -m32.
%endif



%prep
%setup -q -n gcc-%{gccver} -T -b 0 -a 100
pushd ghdl-%{ghdlver}
%patch100 -p1
%patch103 -p0 -b .noruntime
%patch107 -p0 -b .ieeemathreal
%patch110 -p0 -b .grtso
%{__mv} vhdl ../gcc/
popd
#patch102 -p1 -b .makeinfo
%patch104 -p0 -b .libgnat44
%patch105 -p1 -b .grtadac
%patch106 -p0 -b .ppc64abort

%build
%{__rm} -fr obj-%{gcc_target_platform}
%{__mkdir} obj-%{gcc_target_platform}
pushd obj-%{gcc_target_platform}

# Flag settings cribbed from gcc package
OPT_FLAGS=$(echo %{optflags} | %{__sed} \
        -e 's/\(-Wp,\)\?-D_FORTIFY_SOURCE=[12]//g' \
        -e 's/-m64//g;s/-m32//g;s/-m31//g' \
%ifarch sparc sparc64
        -e 's/-mcpu=ultrasparc/-mtune=ultrasparc/g' \
%endif
        -e 's/[[:blank:]]\+/ /g')

# These compiler flags in rawhide seem to break the build, so get rid of them
OPT_FLAGS=$(echo $OPT_FLAGS | %{__sed} \
%ifarch i386 i486 i586 i686
        -e 's/-mtune=atom/-mtune=pentium4/g' \
%endif
%ifarch x86_64
        -e 's/-mtune=generic/-mtune=nocona/g' \
%endif
        -e 's/-fstack-protector//g ' \
        -e 's/--param=ssp-buffer-size=[0-9]*//g')

# gcc -m32 fails, so we disable multilibbing.
# so far multilib isn't very valuable, as the VHDL libraries aren't multilibbed
# either; Bug 174731
export CFLAGS="$OPT_FLAGS"
export XCFLAGS="$OPT_FLAGS"
export TCFLAGS="$OPT_FLAGS"
#configure --enable-languages=vhdl
../configure \
        --program-prefix=%{?_program_prefix} \
        --prefix=%{_prefix} \
        --exec-prefix=%{_exec_prefix} \
        --bindir=%{_bindir} \
        --sbindir=%{_sbindir} \
        --sysconfdir=%{_sysconfdir} \
        --datadir=%{_datadir} \
        --includedir=%{_includedir} \
        --libdir=%{_libdir} \
        --libexecdir=%{_libexecdir} \
        --localstatedir=%{_localstatedir} \
        --sharedstatedir=%{_sharedstatedir} \
        --mandir=%{_mandir} \
        --infodir=%{_infodir} \
        --with-bugurl=http://bugzilla.redhat.com/bugzilla \
        --enable-languages=vhdl \
        %{!?_without_mock:--disable-multilib} \
        --enable-shared \
        --enable-threads=posix \
        --enable-checking=release \
        --with-system-zlib \
        --enable-__cxa_atexit \
        --disable-libunwind-exceptions \
        --disable-libgcj \
%ifarch sparc
        --host=%{gcc_target_platform} \
        --build=%{gcc_target_platform} \
        --target=%{gcc_target_platform} \
        --with-cpu=v7
%endif
%ifarch ppc
        --host=%{gcc_target_platform} \
        --build=%{gcc_target_platform} \
        --target=%{gcc_target_platform} \
        --with-cpu=default32
%endif
%ifnarch sparc ppc
        --host=%{gcc_target_platform} \
        --build=%{gcc_target_platform}
%endif

# Parallel make doesn't work, so not using %{?_smp_mflags}
#{__make} all-host
%{__make}

popd

%install
%{__rm} -rf %{buildroot}
%{__make} -C obj-%{gcc_target_platform} DESTDIR=%{buildroot} install-host

%ifarch %{all_x86}
pushd obj-%{gcc_target_platform}/gcc/vhdl
make grt-clean
make GRT_ADD_FLAGS="-g -O2 -fPIC" GNATVER=4.4 grt-so
%{__install} -d %{buildroot}%{_libdir}
%{__install} libghdlgrt.so* %{buildroot}%{_libdir}
pushd %{buildroot}%{_libdir}
%{__ln_s} libghdlgrt.so* libghdlgrt.so
popd
pushd %{buildroot}/%{_libdir}/gcc/%{gcc_target_platform}/%{gccver}/vhdl/lib
%{__sed} -e 's,@/libgrt.a,-lghdlgrt,g' < grt.lst > grt.lst.1
%{__mv} grt.lst.1 grt.lst
popd
popd

%ifarch x86_64
pushd obj-%{gcc_target_platform}/gcc/vhdl
make grt-clean
make GRT_ADD_FLAGS="-g -O2 -fPIC -m32" GNATVER=4.4 GRT_TARGET_OBJS="i386.o linux.o times.o" grt-so
%{__install} -d %{buildroot}%{_exec_prefix}/lib
%{__install} libghdlgrt.so* %{buildroot}%{_exec_prefix}/lib
pushd %{buildroot}%{_exec_prefix}/lib
%{__ln_s} libghdlgrt.so* libghdlgrt.so
popd
popd
%endif
%endif

%ifarch x86_64
pushd obj-%{gcc_target_platform}/gcc/vhdl
P32=%{buildroot}/%{_libdir}/gcc/%{gcc_target_platform}/%{gccver}/vhdl/lib/32/
%{__install} -d ${P32}
make ghdllibs-clean
%if %{!?_without_mock:0}%{?_without_mock:1}
make grt-clean
make GRT_FLAGS="-m32 -O -g" GRT_TARGET_OBJS="i386.o linux.o times.o" ghdllib
make grt.lst
%{__sed} -e 's,@/libgrt.a,-lghdlgrt,g' < grt.lst > grt.lst.1
%{__install} -m 644 libgrt.a ${P32}/libgrt.a
%{__install} -m 644 grt.lst.1 ${P32}/grt.lst
%{__install} -m 644 grt.ver ${P32}/grt.ver
%endif
PDIR=`pwd`
pushd ${P32}/../..
%{__install} -d lib/32/v93
%{__install} -d lib/32/v87
%{__make} -f ${PDIR}/Makefile REL_DIR=../../../.. \
         LIBSRC_DIR="src" LIB93_DIR=lib/32/v93 LIB87_DIR=lib/32/v87 \
         ANALYZE="${PDIR}/../ghdl -a -m32 --GHDL1=${PDIR}/../ghdl1 --ieee=none" \
         std.v93 std.v87 ieee.v93 ieee.v87 synopsys.v93 synopsys.v87 mentor.v93
popd
../ghdl1 -m32 --std=87 -quiet -o std_standard.s --compile-standard
../xgcc -m32 -c -o std_standard.o std_standard.s
%{__mv} std_standard.o ${P32}/v87/std/std_standard.o
../ghdl1 -m32 --std=93 -quiet -o std_standard.s --compile-standard
../xgcc -m32 -c -o std_standard.o std_standard.s
%{__mv} std_standard.o ${P32}/v93/std/std_standard.o
popd
%endif

# Add additional libraries to link
(
echo "-lm"
%ifarch x86_64
echo "-ldl"
%endif
) >> %{buildroot}%{_libdir}/gcc/%{gcc_target_platform}/%{gccver}/vhdl/lib/grt.lst

# Remove files not to be packaged
pushd %{buildroot}
%{__rm} -f \
        .%{_bindir}/{cpp,gcc,gccbug,gcov} \
        .%{_bindir}/%{gcc_target_platform}-gcc{,-%{gccver}} \
        .%{_includedir}/mf-runtime.h \
        .%{_libdir}/libiberty* \
        .%{_infodir}/dir \
        .%{_infodir}/{cpp,cppinternals,gcc,gccinstall,gccint}.info* \
        .%{_datadir}/locale/*/LC_MESSAGES/{gcc,cpplib}.mo \
        .%{_mandir}/man1/{cpp,gcc,gcov}.1* \
        .%{_mandir}/man7/{fsf-funding,gfdl,gpl}.7* \
        .%{_exec_prefix}/lib/libgcc_s.* \
        .%{_exec_prefix}/lib/libmudflap.* \
        .%{_exec_prefix}/lib/libmudflapth.* \
        .%{_libdir}/32/libiberty.a
# Remove crt/libgcc, as ghdl invokes the native gcc to perform the linking
%{__rm} -f \
        .%{_libdir}/gcc/%{gcc_target_platform}/%{gccver}/crt* \
        .%{_libdir}/gcc/%{gcc_target_platform}/%{gccver}/libgc* \
        .%{_libexecdir}/gcc/%{gcc_target_platform}/%{gccver}/{cc1,collect2}

# Remove directory hierarchies not to be packaged
%{__rm} -rf \
        .%{_libdir}/gcc/%{gcc_target_platform}/%{gccver}/{include,install-tools} \
        .%{_libexecdir}/gcc/%{gcc_target_platform}/%{gccver}/install-tools

popd

# copy v08 libraries from v93 for now
P64=%{buildroot}/%{_libdir}/gcc/%{gcc_target_platform}/%{gccver}/vhdl/lib/
%{__cp} -rv ${P64}v93 ${P64}v08
%{__mv} ${P64}v08/std/std-obj93.cf ${P64}v08/std/std-obj08.cf
%{__mv} ${P64}v08/ieee/ieee-obj93.cf ${P64}v08/ieee/ieee-obj08.cf
%{__mv} ${P64}v08/mentor/ieee-obj93.cf ${P64}v08/mentor/ieee-obj08.cf
%{__mv} ${P64}v08/synopsys/ieee-obj93.cf ${P64}v08/synopsys/ieee-obj08.cf
%ifarch x86_64
%{__cp} -rv ${P32}v93 ${P32}v08
%{__mv} ${P32}v08/std/std-obj93.cf ${P32}v08/std/std-obj08.cf
%{__mv} ${P32}v08/ieee/ieee-obj93.cf ${P32}v08/ieee/ieee-obj08.cf
%{__mv} ${P32}v08/mentor/ieee-obj93.cf ${P32}v08/mentor/ieee-obj08.cf
%{__mv} ${P32}v08/synopsys/ieee-obj93.cf ${P32}v08/synopsys/ieee-obj08.cf
%endif

%clean
%{__rm} -rf %{buildroot}

%post
[ -f %{_infodir}/ghdl.info.gz ] && \
        /sbin/install-info %{_infodir}/ghdl.info.gz %{_infodir}/dir || :

%preun
[ -f %{_infodir}/ghdl.info.gz ] && [ $1 = 0 ] && \
        /sbin/install-info --delete %{_infodir}/ghdl.info.gz %{_infodir}/dir || :

%files
%defattr(-,root,root,-)
%doc ghdl-%{ghdlver}/COPYING
%{_bindir}/ghdl
%{_infodir}/ghdl.info.gz
# Need to own directory %{_libexecdir}/gcc even though we only want the
# %{gcc_target_platform}/%{gccver} subdirectory
%{_libexecdir}/gcc/
%{_mandir}/man1/*

%files devel
%defattr(-,root,root,-)
# Need to own directory %{_libdir}/gcc even though we only want the
# %{gcc_target_platform}/%{gccver} subdirectory
%{_libdir}/gcc/
%ifarch %{all_x86}
%{_libdir}/libghdlgrt.so
%endif
%ifarch x86_64
%{_exec_prefix}/lib/libghdlgrt.so
%endif

%ifarch %{all_x86}
%files libs
%defattr(-,root,root,-)
%{_libdir}/libghdlgrt.so.*
%endif

%ifarch x86_64
%files libs32
%defattr(-,root,root,-)
%{_exec_prefix}/lib/libghdlgrt.so.*
%endif


%changelog
* Wed Dec 16 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.28-0.133svn.0
- update to svn133
- drop upstreamed patches

* Mon Dec 14 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.28-0.131svn.2
- Process Timeout Chain bugfix
- --trace-signals memory leak fix

* Wed Dec  2 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.28-0.131svn.1
- copy v08 libraries instead of symlink

* Wed Dec  2 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.28-0.131svn.0
- update to 0.28/svn131
- symlink v08 libraries to v93 for now

* Wed Sep 23 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.28-0.130svn.0
- update to 0.28/svn130

* Sun Sep 20 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.126svn.0
- update to svn126

* Sun Jul 26 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.8
- this gcc does not understand -mtune=atom

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.27-0.110svn.7.1
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Tue May 26 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.7
- fix bug in std.textio.read (string)

* Wed Apr  2 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.6
- actually add the patch

* Wed Apr  1 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.5
- make ieee.math_real more standards compliant

* Sun Mar 15 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.4
- gnat version is now 4.4

* Tue Feb 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.27-0.110svn.3.1
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Fri Feb 13 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.3
- prevent ppc64 abort due to unknown language type

* Fri Feb 13 2009 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.2
- rebuild with ppc64

* Thu Oct  9 2008 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.1
- rebuild

* Tue Oct  7 2008 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.110svn.0
- update to svn110

* Tue Oct  7 2008 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.27-0.105svn.0
- update to svn105

* Mon Jun  2 2008 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.26-0.98svn.0
- update to svn98

* Fri May 16 2008 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.26-0.94svn.7
- update to svn94

* Sun Jan  6 2008 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.7
- disable Pragma No_Run_Time; it does not seem to make much sense and causes
  problems with gcc-4.3

* Mon Oct  8 2007 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.6
- ghdl-grt requires zlib-devel (rhbz 316311)
- make it build with makeinfo >= 4.10

* Fri Aug 24 2007 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.5
- excludearch ppc64

* Fri Aug 24 2007 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.4
- fix BR

* Fri Aug 24 2007 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.3
- fix license tag

* Fri Jan  5 2007 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.2
- do not try to set user/group during install

* Fri Jan  5 2007 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.1
- back out hunks that cause build failures
- un-exclude ppc

* Mon Nov 20 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.89svn.0
- update to svn89

* Fri Oct  6 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.73svn.0
- update to svn73

* Thu Oct  5 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.71svn.1
- bump release

* Thu Oct  5 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.71svn.0
- update to svn71

* Sun Aug 27 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.25-0.61svn.0
- update to svn61

* Sun Aug  6 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.24-0.60svn.0
- update to svn60

* Tue Jul 11 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.24-0.59svn.2
- rebuild

* Mon Jul 10 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.24-0.59svn.1
- add missing manpage

* Mon Jul 10 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.24-0.59svn.0
- update to svn59

* Sun Jun 25 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.23-0.58svn.0
- update to svn58

* Tue Jun 20 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.23-0.57svn.0
- update to svn57

* Fri Mar 24 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.50svn.1
- do not require /lib/libc.so.* on x86_64, this does not work under mock

* Wed Mar 22 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.50svn.0
- update to svn50, to fix x86_64 breakage
- move grt (ghdl runtime library) into separate package, to allow parallel
  install of i386 and x86_64 grt on x86_64 machines, thus making -m32 work
- back to using FSF gcc as base compiler sources, using core gcc sources
  causes segfaults during library compile on x86_64

* Sun Mar 19 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.49svn.1
- use core gcc as base compiler sources

* Thu Mar 16 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.49svn.0
- update to svn49, using gcc 4.1.0

* Mon Mar  6 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.40svn.0
- update to svn40, to fix an array bounds checking bug apparently
  introduced in svn39

* Thu Feb 16 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.39svn.0
- update to svn39, to fix some constant bugs

* Wed Feb 14 2006 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.38svn.1
- rebuild with new compiler for FC5

* Wed Dec 21 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.22-0.38svn.0
- update to svn38, to fix a ghw output bug

* Sun Dec 18 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-1
- update to 0.21

* Thu Dec 15 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-0.35svn.1
- update to svn35 for more x86_64 "Ada cannot portably call C vararg functions"
  fixes
- first stab at -m32 library building

* Sat Dec 10 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-0.33svn.1
- update to svn33, to fix x86_64 issues (real'image, -m32)
- rpmbuild option --without mock enables multilib builds

* Mon Dec  5 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-0.24svn.3
- disable multilib and remove exclude of x86_64

* Thu Dec  1 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-0.24svn.2
- Exclude ppc because gcc-gnat is missing
- Exclude x86_64 because of mock build issues

* Fri Nov 25 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-0.24svn.1
- update to SVN rev 24
- remove additional files to fix x86_64 build

* Tue Nov 22 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-0.23svn.1
- update to SVN rev 23

* Mon Nov 14 2005 Paul Howarth <paul@city-fan.org> - 0.21-0.21.1
- spec file cosmetic cleanups
- incorporate some architecture tweaks from gcc package
- remove files we don't want packaged so that we can turn the unpackaged file
  check back on
- use fedora_ghdl as the machine vendor name to avoid namespace clashes with
  other packages
- own {%%{_libdir},%%{_libexecdir}}/gcc directories since this package does not
  depend on gcc
- add buildreq texinfo, needed to make info file
- don't include README, which is aimed at building ghdl rather than using it
- remove install-tools and munged header files, not needed for ghdl
- only run install-info if the info file is installed
- patch ghdl.texi to include info dir entry

* Fri Nov 11 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.21-0.21
- update to 0.21pre, svn rev 21
- incorporate changes from Paul Howarth

* Sat Mar 12 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.18-1
- update to 0.18

* Sat Feb 26 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.17-1
- update to 0.17

* Tue Feb  8 2005 Thomas Sailer <t.sailer@alumni.ethz.ch> - 0.16-1
- Initial build.

