# ----------------------------------------------------------------
    use strict;
    use Test::More;
# ----------------------------------------------------------------
{
    plan tests => 11;
    use_ok('Lingua::JA::Romanize::Kana');
    &test_kana();
}
# ----------------------------------------------------------------
sub test_kana {
    my $roman = Lingua::JA::Romanize::Kana->new();
    ok( ref $roman, "new" );

    my $ascii = $roman->char("a");
    ok( ! defined $ascii, "char ascii a" );

    is( $roman->char("\xE3\x81\xB2"), "hi", "char hiragana hi" );
    is( $roman->char("\xE3\x82\xAB"), "ka", "char katakana ka" );

    my $chars = $roman->chars("\xE3\x81\x8B\xE3\x81\xAA");
    $chars =~ s/\s+//g;
    is( $chars, "kana", "chars kana" );

    my @t1 = $roman->string("\xE3\x81\x8B\xE3\x81\xAA");
    like( $t1[0]->[1], qr/^ka(na)?/, "string kana" );

    my @t2 = $roman->string("\xE3\x81\x8B-\xE3\x81\xAA");
    is( $t2[0]->[1], "ka", "string ka-na ka" );
    is( $t2[1]->[0], "-",  "string ka-na - 0" );
    ok( ! defined $t2[1]->[1], "string ka-na - 1" );
    is( $t2[2]->[1], "na", "string ka-na na" );
}
# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------
