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
    ok( $c4 =~ /(^|\W)kan(\W|$)/, "char: kanji kan [$c4]" );

    my $c5 = $roman->chars("hello, world!");
    $c5 =~ s/\s+//g;
    is( $c5 , "hello,world!", "chars: hello [$c5]" );

    my $c6 = $roman->chars("\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e");
    $c6 =~ s/\s+//g;
    ok( $c6 =~ /^(nihongo|nippongo)$/, "chars: nihongo [$c6]" );

    my @t1 = $roman->string("\xE6\xBC\xA2\xE5\xAD\x97");
    ok( $t1[0][1] =~ /(^|\W)kanji(\W|$)/, "string: okuri-nashi kanji [$t1[0][1]]" );

    my @t2 = $roman->string("\xE7\xAC\x91\xE3\x81\x86");
    ok( $t2[0][1] =~ /(^|\W)wara(u)?(\W|$)/, "string: okuri-ari warau [$t2[0][1]]" );

    my @t3 = $roman->string("\xE6\x9C\x89\xE3\x82\x8B");
    ok( $t3[0][1] =~ /(^|\W)a(ru)?(\W|$)/, "string: okuri-ari aru [$t3[0][1]]" );

    my @t4 = $roman->string("\xE6\x9C\x89");
    ok( $t4[0][1] =~ /(^|\W)yuu(\W|$)/, "string: okuri-nashi yuu [$t4[0][1]]" );

    my @t5 = $roman->string("\xE5\xB7\xAE\xE5\x87\xBA\xE3\x81\x99");
    ok( $t5[0][1] =~ /(^|\W)sashida(su)?(\W|$)/, "string: okuri-ari sashidasu [$t5[0][1]]" );

    my @t6 = $roman->string("\xE5\xB7\xAE\xE5\x87\xBA\xE4\xBA\xBA");
    ok( $t6[0][1] =~ /(^|\W)sashidashinin(\W|$)/, "string: okuri-nashi sashidashinin [$t6[0][1]]" );
}
# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------
