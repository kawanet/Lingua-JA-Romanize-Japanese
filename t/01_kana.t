# ----------------------------------------------------------------
    use strict;
    use Test::More tests => 7;
    BEGIN { use_ok('Lingua::JA::Romanize::Kana'); };
# ----------------------------------------------------------------
{
    my $roman = Lingua::JA::Romanize::Kana->new();
    ok( ref $roman, "new" );

    ok( (! defined $roman->char("a")), "ascii" );
    is( $roman->char("\xE3\x81\xB2"), "hi", "hiragana hi" );
    is( $roman->char("\xE3\x82\xAB"), "ka", "katakana ka" );

    my @list = $roman->string("\xE3\x81\x8B\xE3\x81\xAA");
    is( $list[0]->[1], "ka", "ka" );
    is( $list[1]->[1], "na", "na" );
}
# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------
