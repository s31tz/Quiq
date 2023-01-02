use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'Quiq',
    VERSION_FROM => 'lib/Quiq.pm',
    MIN_PERL_VERSION => 5.16.0,
    BUILD_REQUIRES => {
        ExtUtils::MakeMaker => 6.48, # wg. MIN_PERL_VERSION
    },
    PREREQ_PM => {
        # CGI::SpeedyCGI => 0,
        Data::Printer => 0,
        DB_File => 0,
        DBD::SQLite => 0,
        DBI => 0,
        Excel::Writer::XLSX => 0,
        Expect => 0,
        File::Rsync => 0.49,
        File::Slurp => 0,
        # If building of Filesys::SmbClient fails, try to build it by hand:
        #     $ perl Makefile.PL CCFLAGS="-DHAVE_CLOSEFN"; make && make install
        Filesys::SmbClient => 0,
        GD => 0,
        HTML::Tree => 0,
        HTTP::Request => 0,
        Image::Size => 0,
        JSON => 0,
        LWP::UserAgent => 0,
        Mojolicious::Plugin => 0,
        Net::LDAP => 0,
        Net::SFTP::Foreign => 0,
        Net::SSH::Perl => 0,
        Plack => 0,
        Pod::WSDL => 0,
        SOAP::Transport::HTTP => 0,
        Stat::lsMode => 0,
        Time::Zone => 0,
        WWW::Mechanize => 0,
        XML::LibXML => 0,
        XML::Twig => 0,
    },
    ABSTRACT_FROM => 'lib/Quiq.pm',
    AUTHOR => 'Frank Seitz <fs@fseitz.de>',
    LICENSE => 'perl_5',
    clean => { FILES => 'Quiq-*' },
    test => {
        RECURSIVE_TEST_FILES => 1,
    },
    META_MERGE => {
        'meta-spec' => {
            version => 2,
        },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/s31tz/Quiq.git',
                web  => 'https://github.com/s31tz/Quiq',
            },
        },
    },
    META_ADD => {
        provides => {
            __MODULES__
        },
    },
);

# eof
