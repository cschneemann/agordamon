#
# spec file for package perl-Nmap-Parser
#
# Copyright (c) 2012 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           perl-agordamon
Version:        0.23.5
Release:        0
Summary:        Agordamon Perl module
License:        GPLv3
Group:          Development/Libraries/Perl
Url:            http://www.b1-systems.de
Source:         agordamon-%{version}.tar.xz
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  perl
%if 0%{?suse_version} < 1120 
BuildRequires: perl-macros 
%endif

%{perl_requires}

%description
This package contains the agordamon Perl modules.

%prep
%setup -q -n agordamon-%{version} 

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
%{__make} %{?_smp_mflags}

%check
#%%{__make} test

%install
%perl_make_install
%perl_process_packlist
%perl_gen_filelist

%files -f %{name}.files
%defattr(-,root,root,755)

%changelog
