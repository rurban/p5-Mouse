#!/usr/bin/perl

use strict;
use warnings;

use Test::More skip_all => '[TODO] a Moose class cannot extends a Mouse class';
use Test::More;

use Mouse::Spec;
BEGIN {
    eval{ require Moose && Moose->VERSION(Mouse::Spec->MooseVersion) };
    plan skip_all => "Moose $Mouse::Spec::MooseVersion required for this test" if $@;
}

use Test::Exception;

{
    package Foo;
    use Moose;

    has foo => (
        isa => "Int",
        is  => "rw",
    );

    package Bar;
    use Mouse;

    ::lives_ok { extends qw(Foo) } "extend Mouse class with Moose";

    ::lives_ok {
        has bar => (
            isa => "Str",
            is  => "rw",
        );
    } "new attr in subclass";

    package Gorch;
    use Mouse;

    ::lives_ok { extends qw(Foo) } "extend Mouse class with Moose";

    ::lives_ok {
        has '+foo' => (
            default => 3,
        );
    } "clone and inherit attr in subclass";

    package Quxx;
    use Moose;

    has quxx => (
        is => "rw",
        default => "lala",
    );

    package Zork;
    use Mouse;

    ::lives_ok { extends qw(Quxx) } "extend Mouse class with Moose";

    has zork => (
        is => "rw",
        default => 42,
    );
}

can_ok( Bar => "new" );

my $bar = eval { Bar->new };

ok( $bar, "got an object" );
isa_ok( $bar, "Bar" );
isa_ok( $bar, "Foo" );

can_ok( $bar, qw(foo bar) );

is( eval { $bar->foo }, undef, "no default value" );
is( eval { $bar->bar }, undef, "no default value" );

lives_and {
    is_deeply(
        [ sort map { $_->name } Bar->meta->get_all_attributes ],
        [ sort qw(foo bar) ],
        "attributes",
    );

    is( Gorch->new->foo, 3, "cloned and inherited attr's default" );
};

can_ok( Zork => "new" );

lives_and {
    my $zork = eval { Zork->new };

    ok( $zork, "got an object" );
    isa_ok( $zork, "Zork" );
    isa_ok( $zork, "Quxx" );

    can_ok( $zork, qw(quxx zork) );

    is( $bar->quxx, "lala", "default value" );
    is( $bar->zork, 42,     "default value" );
};

lives_and {
    my $zork = eval { Zork->new( zork => "diff", quxx => "blah" ) };

    ok( $zork, "got an object" );
    isa_ok( $zork, "Zork" );
    isa_ok( $zork, "Quxx" );

    can_ok( $zork, qw(quxx zork) );

    is( $bar->quxx, "blah", "constructor param" );
    is( $bar->zork, "diff", "constructor param" );
};

done_testing;
 