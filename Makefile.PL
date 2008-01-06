use strict;
use ExtUtils::MakeMaker;
use lib qw( lib );
use Lingua::JA::Romanize::DictJA;

Lingua::JA::Romanize::DictJA->update();

my $opt = {
    NAME                => 'Lingua::JA::Romanize::Japanese',
    VERSION_FROM        => 'lib/Lingua/JA/Romanize/Japanese.pm',
    PREREQ_PM           => {
        'Test::More'    => '0',
	'DB_File'	=> '0',
    },
};

WriteMakefile( %$opt );
