# ----------------------------------------------------------------
    use strict;
    use Test::More tests => 14;
# ----------------------------------------------------------------
SKIP: {
    local $@;
    eval { require Juman; };
    skip( "Juman.pm is not available.", 14 ) if $@;
    my $found;
    foreach my $path ( split( /:/, $ENV{PATH} )) {
		my $test = "$path/juman";
        $found = $test if ( -x $test );
    }
    warn " juman command found: $found\n" if $found;
    warn " \$JUMANSERVER=$ENV{JUMANSERVER}\n" if $ENV{JUMANSERVER};
    if ( ! $found && ! $ENV{JUMANSERVER} ) {
        skip( "JUMAN is not available.", 14 );
    }
    use_ok('Lingua::JA::Romanize::Juman');
    my $roman = Lingua::JA::Romanize::Juman->new();
    &test_ja( $roman );
}
# ----------------------------------------------------------------
sub test_ja {
    my $roman = shift;
    ok( ref $roman, "new" );

    ok( (! defined $roman->char("a")), "char: ascii" );
    is( $roman->char("\xE3\x81\xB2"), "hi", "char: hiragana hi" );
    is( $roman->char("\xE3\x82\xAB"), "ka", "char: katakana ka" );

    my $c4 = $roman->char("\xE6\xBC\xA2");
    like( $c4, qr/(^|\W)kan(\W|$)/, "char: kanji kan" );

    my $c5 = $roman->chars("hello, world!");
    $c5 =~ s/\s+//g;
    is( $c5 , "hello,world!", "chars: hello" );

    my $c6 = $roman->chars("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e");
    $c6 =~ s/\s+//g;
    like( $c6, qr/^(nihongo|nippongo)$/, "chars: nihongo" );

    my @t1 = $roman->string("\xE6\xBC\xA2\xE5\xAD\x97");
    like( $t1[0][1], qr/(^|\W)kanji(\W|$)/, "string: okuri-nashi kanji" );

    my @t2 = $roman->string("\xE7\xAC\x91\xE3\x81\x86");
    like( $t2[0][1], qr/(^|\W)wara(u)?(\W|$)/, "string: okuri-ari warau" );

    my @t3 = $roman->string("\xE6\x9C\x89\xE3\x82\x8B");
    like( $t3[0][1], qr/(^|\W)a(ru)?(\W|$)/, "string: okuri-ari aru" );

    my @t4 = $roman->string("\xE6\x9C\x89");
    like( $t4[0][1], qr/(^|\W)yuu(\W|$)/, "string: okuri-nashi yuu" );

    my @t5 = $roman->string("\xE5\xB7\xAE\xE5\x87\xBA\xE3\x81\x99");
    like( $t5[0][1], qr/(^|\W)sashida(su)?(\W|$)/, "string: okuri-ari sashidasu" );

    my @t6 = $roman->string("\xE5\xB7\xAE\xE5\x87\xBA\xE4\xBA\xBA");
    like( $t6[0][1], qr/(^|\W)sashidashinin(\W|$)/, "string: okuri-nashi sashidashinin" );
}
# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------
