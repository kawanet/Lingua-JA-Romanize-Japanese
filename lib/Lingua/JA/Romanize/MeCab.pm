=head1 NAME

Lingua::JA::Romanize::MeCab - Romanization of Japanese language with MeCab

=head1 SYNOPSIS

    use Lingua::JA::Romanize::MeCab;

    my $conv = Lingua::JA::Romanize::MeCab->new();
    my $roman = $conv->char( $kanji );
    printf( "<ruby><rb>%s</rb><rt>%s</rt></ruby>", $kanji, $roman );

    my @array = $conv->string( $string );
    foreach my $pair ( @array ) {
        my( $raw, $ruby ) = @$pair;
        if ( defined $ruby ) {
            printf( "<ruby><rb>%s</rb><rt>%s</rt></ruby>", $raw, $ruby );
        } else {
            print $raw;
        }
    }

=head1 DESCRIPTION

This is MeCab version of L<Lingua::JA::Romanize::Japanese> module.
MeCab's Perl binding, MeCab.pm, is required.

=head1 UTF-8 DICTIONARY

If MeCab's dictionary is generated with UTF8, --with-charset=utf8,
use Lingua::JA::Romanize::MeCab::UTF8->new()
instead of Lingua::JA::Romanize::MeCab->new().

=head1 SEE ALSO

L<Lingua::JA::Romanize::Japanese>

http://mecab.sourceforge.jp/ (Japanese)

=head1 AUTHOR

Yusuke Kawasaki, http://www.kawa.net/

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2006-2007 Yusuke Kawasaki. All rights reserved.
This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut
# ----------------------------------------------------------------
package Lingua::JA::Romanize::MeCab;
use strict;
use Carp;
use MeCab;
use Lingua::JA::Romanize::Kana;
use vars qw( $VERSION );
$VERSION = "0.15";

# ----------------------------------------------------------------
sub new {
    my $package = shift;
    my $self    = {};
    &require_encode_or_jcode();
    $self->{mecab} = MeCab::Tagger->new(@_);
    $self->{kana}  = Lingua::JA::Romanize::Kana->new();
    $self->{jcode} = Jcode->new("") unless ( $] > 5.008 );
    bless $self, $package;
    $self;
}

sub char {
    my $self  = shift;
    my $src   = shift;
    my $roman = $self->{kana}->char($src);
    return $roman if $roman;
    my $pair =
      ( $self->string($src) )[0];    # need loop for nodes which have surface
    return if ( scalar @$pair == 1 );
    return $pair->[1];
}

sub chars {
    my $self  = shift;
    my @array = $self->string(shift);
    join( " ", map { $#$_ > 0 ? $_->[1] : $_->[0] } @array );
}

sub string {
    my $self  = shift;
    my $src   = $self->from_utf8(shift);
    my $array = [];

    my $node = $self->{mecab}->parseToNode($src);
    for ( ; $node ; $node = $node->{next} ) {
        next unless defined $node->{surface};
    next unless length( $node->{surface} );
        my $midasi = $self->to_utf8( $node->{surface} );
        my $kana = ( split( /,/, $node->{feature} ) )[7];
        $kana = $self->to_utf8($kana) if defined $kana;
        my @array = $self->{kana}->string($kana) if $kana;
        my $roman = join( "", map { $_->[1] } grep { $#$_ > 0 } @array )
          if scalar @array;
        my $pair = $roman ? [ $midasi, $roman ] : [$midasi];
        push( @$array, $pair );
    }

    $self->{kana}->normalize($array);
}

sub require_encode_or_jcode {
    if ( $] > 5.008 ) {
        return if defined $Encode::VERSION;
        require Encode;
    }
    else {
        return if defined $Jcode::VERSION;
        local $@;
        eval { require Jcode; };
        Carp::croak "Jcode.pm is required on Perl $]\n" if $@;
    }
}

*from_utf8 = \&Lingua::JA::Romanize::MeCab::EUC::from_utf8;
*to_utf8 = \&Lingua::JA::Romanize::MeCab::EUC::to_utf8;

# ----------------------------------------------------------------
package Lingua::JA::Romanize::MeCab::UTF8;
use strict;
use vars qw( @ISA );
@ISA = qw( Lingua::JA::Romanize::MeCab );

sub from_utf8 {
    $_[1];              # no need to encode
}

sub to_utf8 {
    $_[1];              # no need to decode
}

# ----------------------------------------------------------------
package Lingua::JA::Romanize::MeCab::EUC;
use strict;
use vars qw( @ISA );
@ISA = qw( Lingua::JA::Romanize::MeCab );

sub from_utf8 {
    my $self = shift;
    my $src  = shift;
    if ( $] > 5.008 ) {
        Encode::from_to( $src, "UTF-8", "EUC-JP" );
    }
    else {
        $src = $self->{jcode}->set( \$src, "utf8" )->euc();
    }
    $src;
}

sub to_utf8 {
    my $self = shift;
    my $src  = shift;
    if ( $] > 5.008 ) {
        Encode::from_to( $src, "EUC-JP", "UTF-8" );
    }
    else {
        $src = $self->{jcode}->set( \$src, "euc" )->utf8();
    }
    $src;
}

# ----------------------------------------------------------------
package Lingua::JA::Romanize::MeCab::SJIS;
use strict;
use vars qw( @ISA );
@ISA = qw( Lingua::JA::Romanize::MeCab );

sub from_utf8 {
    my $self = shift;
    my $src  = shift;
    if ( $] > 5.008 ) {
        Encode::from_to( $src, "UTF-8", "CP932" );
    }
    else {
        $src = $self->{jcode}->set( \$src, "utf8" )->sjis();
    }
    $src;
}

sub to_utf8 {
    my $self = shift;
    my $src  = shift;
    if ( $] > 5.008 ) {
        Encode::from_to( $src, "CP932", "UTF-8" );
    }
    else {
        $src = $self->{jcode}->set( \$src, "sjis" )->utf8();
    }
    $src;
}

# ----------------------------------------------------------------
1;
