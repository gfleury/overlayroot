Summary:	Dracut module to mount the root partition with a RW fs on top of a RO fs
Name:		dracut-modules-overlayroot
Version:	0.1
Release:	beta%{?dist}
License:	GPLv3
Group:		System Environment/Base
Source0:	https://github.com/gfleury/overlayroot/archive/v%{version}.zip	

Requires:	dracut
Requires:	util-linux

BuildArch:	noarch

%description
This dracut module will re-mount the root fs with overlayfs on top of the real  
root filesystem. Keeping the real root filesystem in read-only mode. All the 
writes and new data are written another filesystem (root-rw). 

%prep
# extract cloud-utils
%setup -q -n overlayroot-%{version}


%build


%install
make install DESTDIR=%{buildroot}/%{_datadir}


%files
%doc README.md
%if 0%{?fedora}
%dir %{_prefix}/lib/dracut/modules.d/50overlayroot
%{_prefix}/lib/dracut/modules.d/50overlayroot/overlayroot-dummy.sh
%{_prefix}/lib/dracut/modules.d/50overlayroot/overlayroot.sh
%{_prefix}/lib/dracut/modules.d/50overlayroot/module-setup.sh
%else
%if 0%{?amzn} || 0%{?rhel} || 0%{?centos}
%dir %{_prefix}/share/dracut/modules.d/50overlayroot
%{_prefix}/share/dracut/modules.d/50overlayroot/overlayroot-dummy.sh
%{_prefix}/share/dracut/modules.d/50overlayroot/overlayroot.sh
%{_prefix}/share/dracut/modules.d/50overlayroot/install
%endif
%endif


%changelog
* Wed Jan 15 2014 Lars Kellogg-Stedman <lars@redhat.com> - 0.20-3
- import into RHEL
