use strict;
use ExtUtils::MakeMaker;

{
    local $@;
    eval {
        use lib qw( lib );
        use Lingua::JA::Romanize::DictJA;
        Lingua::JA::Romanize::DictJA->update();
    };
    warn "**** $@" if $@;
}

my $opt = {
    NAME                    =>  'Lingua::JA::Romanize::Japanese',
    VERSION_FROM            =>  'lib/Lingua/JA/Romanize/Japanese.pm',
    PREREQ_PM               =>  {
        'Test::More'        =>  '0',
        'DB_File'           =>  '0',
        'LWP::UserAgent'    =>  '0',
    },
};

my $PERL581 = 1 if ( $] >= 5.008001 );
$opt->{PREREQ_PM}->{Jcode} = '0' unless $PERL581;

WriteMakefile( %$opt );
