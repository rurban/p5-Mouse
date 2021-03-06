#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 32;
use Test::Exception;

use lib 't/lib';
use Test::Mouse;
use MooseCompat;

=pod

Check for repeated inheritance causing
a method conflict (which is not really
a conflict)

=cut

{
    package Role::Base;
    use Mouse::Role;

    sub foo { 'Role::Base::foo' }

    package Role::Derived1;
    use Mouse::Role;

    with 'Role::Base';

    package Role::Derived2;
    use Mouse::Role;

    with 'Role::Base';

    package My::Test::Class1;
    use Mouse;

    ::lives_ok {
        with 'Role::Derived1', 'Role::Derived2';
    } '... roles composed okay (no conflicts)';
}

ok(Role::Base->meta->has_method('foo'), '... have the method foo as expected');
ok(Role::Derived1->meta->has_method('foo'), '... have the method foo as expected');
ok(Role::Derived2->meta->has_method('foo'), '... have the method foo as expected');
ok(My::Test::Class1->meta->has_method('foo'), '... have the method foo as expected');

is(My::Test::Class1->foo, 'Role::Base::foo', '... got the right value from method');

=pod

Check for repeated inheritance causing
a method conflict with method modifiers
(which is not really a conflict)

=cut

{
    package Role::Base2;
    use Mouse::Role;

    override 'foo' => sub { super() . ' -> Role::Base::foo' };

    package Role::Derived3;
    use Mouse::Role;

    with 'Role::Base2';

    package Role::Derived4;
    use Mouse::Role;

    with 'Role::Base2';

    package My::Test::Class2::Base;
    use Mouse;

    sub foo { 'My::Test::Class2::Base' }

    package My::Test::Class2;
    use Mouse;

    extends 'My::Test::Class2::Base';

    ::lives_ok {
        with 'Role::Derived3', 'Role::Derived4';
    } '... roles composed okay (no conflicts)';
}

ok(Role::Base2->meta->has_override_method_modifier('foo'), '... have the method foo as expected');
ok(Role::Derived3->meta->has_override_method_modifier('foo'), '... have the method foo as expected');
ok(Role::Derived4->meta->has_override_method_modifier('foo'), '... have the method foo as expected');
ok(My::Test::Class2->meta->has_method('foo'), '... have the method foo as expected');
{
local $TODO = 'Not a Mouse::Meta::Method::Overriden';
isa_ok(My::Test::Class2->meta->get_method('foo'), 'Mouse::Meta::Method::Overridden');
}
ok(My::Test::Class2::Base->meta->has_method('foo'), '... have the method foo as expected');
{
local $TODO = 'Not a Class::MOP::Method';
isa_ok(My::Test::Class2::Base->meta->get_method('foo'), 'Class::MOP::Method');
}
is(My::Test::Class2::Base->foo, 'My::Test::Class2::Base', '... got the right value from method');
is(My::Test::Class2->foo, 'My::Test::Class2::Base -> Role::Base::foo', '... got the right value from method');

=pod

Check for repeated inheritance of the
same code. There are no conflicts with
before/around/after method modifiers.

This tests around, but should work the
same for before/afters as well

=cut

{
    package Role::Base3;
    use Mouse::Role;

    around 'foo' => sub { 'Role::Base::foo(' . (shift)->() . ')' };

    package Role::Derived5;
    use Mouse::Role;

    with 'Role::Base3';

    package Role::Derived6;
    use Mouse::Role;

    with 'Role::Base3';

    package My::Test::Class3::Base;
    use Mouse;

    sub foo { 'My::Test::Class3::Base' }

    package My::Test::Class3;
    use Mouse;

    extends 'My::Test::Class3::Base';

    ::lives_ok {
        with 'Role::Derived5', 'Role::Derived6';
    } '... roles composed okay (no conflicts)';
}

ok(Role::Base3->meta->has_around_method_modifiers('foo'), '... have the method foo as expected');
ok(Role::Derived5->meta->has_around_method_modifiers('foo'), '... have the method foo as expected');
ok(Role::Derived6->meta->has_around_method_modifiers('foo'), '... have the method foo as expected');
ok(My::Test::Class3->meta->has_method('foo'), '... have the method foo as expected');
{
local $TODO = 'Not a Class::MOP::Method::Wrapped';
isa_ok(My::Test::Class3->meta->get_method('foo'), 'Class::MOP::Method::Wrapped');
}
ok(My::Test::Class3::Base->meta->has_method('foo'), '... have the method foo as expected');
{
local $TODO = 'Not a Class::MOP::Method';
isa_ok(My::Test::Class3::Base->meta->get_method('foo'), 'Class::MOP::Method');
}
is(My::Test::Class3::Base->foo, 'My::Test::Class3::Base', '... got the right value from method');
is(My::Test::Class3->foo, 'Role::Base::foo(My::Test::Class3::Base)', '... got the right value from method');

=pod

Check for repeated inheritance causing
a attr conflict (which is not really
a conflict)

=cut

{
    package Role::Base4;
    use Mouse::Role;

    has 'foo' => (is => 'ro', default => 'Role::Base::foo');

    package Role::Derived7;
    use Mouse::Role;

    with 'Role::Base4';

    package Role::Derived8;
    use Mouse::Role;

    with 'Role::Base4';

    package My::Test::Class4;
    use Mouse;

    ::lives_ok {
        with 'Role::Derived7', 'Role::Derived8';
    } '... roles composed okay (no conflicts)';
}

ok(Role::Base4->meta->has_attribute('foo'), '... have the attribute foo as expected');
ok(Role::Derived7->meta->has_attribute('foo'), '... have the attribute foo as expected');
ok(Role::Derived8->meta->has_attribute('foo'), '... have the attribute foo as expected');
ok(My::Test::Class4->meta->has_attribute('foo'), '... have the attribute foo as expected');

is(My::Test::Class4->new->foo, 'Role::Base::foo', '... got the right value from method');
