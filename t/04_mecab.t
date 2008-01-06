# ----------------------------------------------------------------
    use strict;
    use Test::More tests => 14;
# ----------------------------------------------------------------
SKIP: {
    local $@;
    eval { require MeCab; };
    skip( "MeCab.pm is not available.", 14 ) if $@;
    my $mecab;
    eval {
        $mecab = MeCab::Tagger->new(@_);
    };
    skip( "MeCab::Tagger is not available. $@", 14 ) unless ref $mecab;
    use_ok('Lingua::JA::Romanize::MeCab');
    my $roman = &detect_dict_code();
    &test_ja( $roman );
}
# ----------------------------------------------------------------
sub detect_dict_code {
    my $hash = {
        euc     =>  Lingua::JA::Romanize::MeCab::EUC->new(),
        utf8    =>  Lingua::JA::Romanize::MeCab::UTF8->new(),
        sjis    =>  Lingua::JA::Romanize::MeCab::SJIS->new(),
    };
    my $test = {
        namae   =>  "\xe5\x90\x8d\xe5\x89\x8d",
        ugoku   =>  "\xe5\x8b\x95\xe3\x81\x8f",
        hayai   =>  "\xe9\x80\x9f\xe3\x81\x84",
    };
    my $count = {};

    foreach my $code ( keys %$hash ) {
        $count->{$code} = 0;
        foreach my $str ( keys %$test ) {
            my $out = $hash->{$code}->chars( $test->{$str} );
            $count->{$code} ++ if ( $str eq $out );
        }
    }
    my $detect = ( sort {$count->{$b} <=> $count->{$a}} keys %$hash )[0];
    ok( $count->{$detect}, "charset detected: $detect" );
    $hash->{$detect};
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

#   my @t4 = $roman->string("\xE6\x9C\x89");
#   ok( $t4[0][1] =~ /(^|\W)yuu(\W|$)/, "string: okuri-nashi yuu [$t4[0][1]]" );

    my @t5 = $roman->string("\xE5\xB7\xAE\xE5\x87\xBA\xE3\x81\x99");
    ok( $t5[0][1] =~ /(^|\W)sashida(su)?(\W|$)/, "string: okuri-ari sashidasu [$t5[0][1]]" );

    my @t6 = $roman->string("\xE5\xB7\xAE\xE5\x87\xBA\xE4\xBA\xBA");
    ok( $t6[0][1] =~ /(^|\W)sashidashinin(\W|$)/, "string: okuri-nashi sashidashinin [$t6[0][1]]" );
}
# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------
