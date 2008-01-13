use strict;
use ExtUtils::MakeMaker;
use lib qw( lib );
use Lingua::JA::Romanize::DictJA;

Lingua::JA::Romanize::DictJA->update();

my $PERL581 = 1 if ( $] >= 5.008001 );

my $opt = {
    NAME                => 'Lingua::JA::Romanize::Japanese',
    VERSION_FROM        => 'lib/Lingua/JA/Romanize/Japanese.pm',
    PREREQ_PM           => {
        'Test::More'    => '0',
        'DB_File'       => '0',
#       'Jcode'         => '0', # on Perl 5.8.0 or less
    },
};

$opt->{PREREQ_PM}->{Jcode} = '0' unless $PERL581;

my $mm = $ExtUtils::MakeMaker::VERSION;
$mm =~ s/[^\d\.]+//g;
$opt->{LICENSE} = 'perl' if ( $mm >= 6.3001 );

WriteMakefile( %$opt );
